---
name: Elasticsearch
description: Skill for full-text search with Elasticsearch — covering indexing, mappings, Query DSL, aggregations, analyzers, pagination, and integration with Node.js and Python.
---

# Elasticsearch Skill

## Overview
Elasticsearch is a distributed, RESTful search and analytics engine built on Apache Lucene. It provides full-text search, structured search, analytics, and real-time data ingestion. Elasticsearch excels at searching large volumes of text with relevance scoring.

**References**:
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/)
- [Elasticsearch Node.js Client](https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/)
- [Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)

---

## Setup

```yaml
# docker-compose.yml
services:
  elasticsearch:
    image: elasticsearch:8.12.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -s http://localhost:9200 | grep -q 'cluster_name'"]
      interval: 10s
      timeout: 5s
      retries: 10

volumes:
  es_data:
```

```typescript
// src/lib/elasticsearch.ts
import { Client } from '@elastic/elasticsearch';

export const esClient = new Client({
  node: process.env.ELASTICSEARCH_URL || 'http://localhost:9200',
  maxRetries: 3,
  requestTimeout: 30000,
});
```

---

## Index Mapping with Custom Analyzers

```typescript
// src/search/setup.ts
export async function createProductIndex() {
  const indexName = 'products';

  const exists = await esClient.indices.exists({ index: indexName });
  if (exists) return;

  await esClient.indices.create({
    index: indexName,
    body: {
      settings: {
        number_of_shards: 1,
        number_of_replicas: 0,
        analysis: {
          analyzer: {
            product_analyzer: {
              type: 'custom',
              tokenizer: 'standard',
              filter: ['lowercase', 'product_stemmer', 'product_synonyms'],
            },
            autocomplete_analyzer: {
              type: 'custom',
              tokenizer: 'standard',
              filter: ['lowercase', 'edge_ngram_filter'],
            },
          },
          filter: {
            product_stemmer: { type: 'stemmer', language: 'english' },
            product_synonyms: {
              type: 'synonym',
              synonyms: ['laptop, notebook', 'phone, smartphone, mobile', 'headphone, earphone, headset'],
            },
            edge_ngram_filter: { type: 'edge_ngram', min_gram: 2, max_gram: 15 },
          },
        },
      },
      mappings: {
        properties: {
          name:        { type: 'text', analyzer: 'product_analyzer', fields: { autocomplete: { type: 'text', analyzer: 'autocomplete_analyzer' }, keyword: { type: 'keyword' } } },
          description: { type: 'text', analyzer: 'product_analyzer' },
          slug:        { type: 'keyword' },
          price:       { type: 'integer' },
          stock:       { type: 'integer' },
          category:    { type: 'keyword' },
          brand:       { type: 'keyword' },
          status:      { type: 'keyword' },
          rating:      { type: 'float' },
          ratingCount: { type: 'integer' },
          tags:        { type: 'keyword' },
          createdAt:   { type: 'date' },
        },
      },
    },
  });
}
```

---

## Indexing Documents

```typescript
// Bulk index products
export async function indexProducts(products: Product[]) {
  const operations = products.flatMap((product) => [
    { index: { _index: 'products', _id: product.id } },
    {
      name: product.name,
      description: product.description,
      slug: product.slug,
      price: product.price,
      stock: product.stock,
      category: product.category,
      brand: product.brand,
      status: product.status,
      rating: product.rating,
      ratingCount: product.ratingCount,
      tags: product.tags,
      createdAt: product.createdAt,
    },
  ]);

  const { errors, items } = await esClient.bulk({ refresh: true, operations });

  if (errors) {
    const errorItems = items.filter((item: any) => item.index?.error);
    console.error('Bulk index errors:', errorItems.length);
  }

  return { indexed: items.length / 2, errors: errors ? items.filter((i: any) => i.index?.error).length : 0 };
}
```

---

## Search

```typescript
// src/search/product-search.ts
interface SearchOptions {
  query?: string;
  category?: string;
  brand?: string;
  priceMin?: number;
  priceMax?: number;
  rating?: number;
  sortBy?: string;
  page?: number;
  limit?: number;
}

export async function searchProducts(options: SearchOptions) {
  const { query, category, brand, priceMin, priceMax, rating, sortBy = 'relevance', page = 1, limit = 20 } = options;

  const must: any[] = [];
  const filter: any[] = [{ term: { status: 'active' } }];

  // Full-text search
  if (query) {
    must.push({
      multi_match: {
        query,
        fields: ['name^3', 'description', 'brand^2', 'tags^2'],
        type: 'best_fields',
        fuzziness: 'AUTO',
        prefix_length: 2,
      },
    });
  }

  // Filters
  if (category) filter.push({ term: { category } });
  if (brand) filter.push({ term: { brand } });
  if (priceMin || priceMax) {
    const range: any = {};
    if (priceMin) range.gte = priceMin;
    if (priceMax) range.lte = priceMax;
    filter.push({ range: { price: range } });
  }
  if (rating) filter.push({ range: { rating: { gte: rating } } });

  // Sort
  const sort: any[] = (() => {
    switch (sortBy) {
      case 'price_asc': return [{ price: 'asc' }];
      case 'price_desc': return [{ price: 'desc' }];
      case 'rating': return [{ rating: 'desc' }];
      case 'newest': return [{ createdAt: 'desc' }];
      default: return query ? [{ _score: 'desc' }] : [{ createdAt: 'desc' }];
    }
  })();

  const result = await esClient.search({
    index: 'products',
    body: {
      query: {
        bool: {
          must: must.length ? must : [{ match_all: {} }],
          filter,
        },
      },
      sort,
      from: (page - 1) * limit,
      size: limit,
      highlight: {
        fields: { name: {}, description: { fragment_size: 150 } },
        pre_tags: ['<mark>'],
        post_tags: ['</mark>'],
      },
      aggs: {
        categories: { terms: { field: 'category', size: 20 } },
        brands: { terms: { field: 'brand', size: 20 } },
        price_ranges: {
          range: {
            field: 'price',
            ranges: [
              { to: 100000, key: 'Under 100K' },
              { from: 100000, to: 500000, key: '100K - 500K' },
              { from: 500000, to: 1000000, key: '500K - 1M' },
              { from: 1000000, key: 'Over 1M' },
            ],
          },
        },
        avg_rating: { avg: { field: 'rating' } },
      },
    },
  });

  return {
    data: result.hits.hits.map((hit: any) => ({
      id: hit._id,
      ...hit._source,
      score: hit._score,
      highlight: hit.highlight,
    })),
    total: (result.hits.total as any).value,
    page,
    totalPages: Math.ceil((result.hits.total as any).value / limit),
    aggregations: {
      categories: (result.aggregations?.categories as any)?.buckets || [],
      brands: (result.aggregations?.brands as any)?.buckets || [],
      priceRanges: (result.aggregations?.price_ranges as any)?.buckets || [],
      avgRating: (result.aggregations?.avg_rating as any)?.value || 0,
    },
  };
}
```

---

## Autocomplete

```typescript
export async function autocomplete(query: string, limit = 10) {
  const result = await esClient.search({
    index: 'products',
    body: {
      query: {
        bool: {
          must: { match: { 'name.autocomplete': { query, operator: 'and' } } },
          filter: { term: { status: 'active' } },
        },
      },
      _source: ['name', 'slug', 'price', 'category'],
      size: limit,
    },
  });

  return result.hits.hits.map((hit: any) => ({
    id: hit._id,
    ...hit._source,
  }));
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Custom analyzers** | Synonyms, stemmer, edge_ngram for relevant results |
| **Multi-field** | Map text fields with keyword + autocomplete sub-fields |
| **Bulk indexing** | Use `_bulk` API for efficient document ingestion |
| **Faceted search** | Aggregations for categories, brands, price ranges |
| **Highlighting** | Return highlighted matches for UI display |
| **Fuzziness** | `AUTO` fuzziness for typo tolerance |
| **Boosting** | Field boosting (`name^3`) for relevance tuning |
| **Pagination** | `from/size` for simple pagination |
| **Filters** | Use `filter` context for exact matches (faster, cacheable) |
| **Refresh** | Use `refresh: true` only in tests; default in prod |

---

## Rules Integration
- **Index**: Custom analyzers (synonyms, stemmer, edge_ngram)
- **Search**: Multi-match with fuzzy, filters, highlight, sort
- **Aggregations**: Faceted search for categories, brands, price
- **Autocomplete**: Edge ngram analyzer for instant suggestions
- **Operations**: Bulk indexing with error handling
