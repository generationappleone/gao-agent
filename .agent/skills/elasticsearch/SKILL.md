---
name: Elasticsearch
description: Skill for full-text search with Elasticsearch — covering indexing, mappings, Query DSL, aggregations, analyzers, pagination, and integration with Node.js and Python.
---

# Elasticsearch Skill

## Overview
Elasticsearch is a distributed search and analytics engine built on Apache Lucene for full-text search, logging, and data analytics.

**Reference**: [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/)

## Index & Mapping
```json
PUT /products
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "custom_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "asciifolding", "edge_ngram_filter"]
        }
      },
      "filter": {
        "edge_ngram_filter": { "type": "edge_ngram", "min_gram": 2, "max_gram": 20 }
      }
    }
  },
  "mappings": {
    "properties": {
      "name": { "type": "text", "analyzer": "custom_analyzer", "fields": { "keyword": { "type": "keyword" } } },
      "description": { "type": "text" },
      "price": { "type": "float" },
      "category": { "type": "keyword" },
      "tags": { "type": "keyword" },
      "created_at": { "type": "date" },
      "location": { "type": "geo_point" }
    }
  }
}
```

## Query DSL
```json
// Full-text search with filters
POST /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "multi_match": { "query": "wireless headphone", "fields": ["name^3", "description"], "type": "best_fields", "fuzziness": "AUTO" } }
      ],
      "filter": [
        { "term": { "category": "electronics" } },
        { "range": { "price": { "gte": 10, "lte": 500 } } }
      ]
    }
  },
  "sort": [{ "_score": "desc" }, { "created_at": "desc" }],
  "from": 0, "size": 20,
  "highlight": { "fields": { "name": {}, "description": {} } },
  "aggs": {
    "categories": { "terms": { "field": "category", "size": 10 } },
    "price_ranges": { "range": { "field": "price", "ranges": [{ "to": 50 }, { "from": 50, "to": 200 }, { "from": 200 }] } }
  }
}
```

## Node.js Client
```typescript
import { Client } from "@elastic/elasticsearch";
const client = new Client({ node: "http://localhost:9200" });

// Index document
await client.index({ index: "products", id: "1", document: { name: "Headphones", price: 99.99, category: "electronics" } });

// Search
const result = await client.search({
  index: "products",
  query: { multi_match: { query: "headphones", fields: ["name", "description"] } },
});

// Bulk operations
const operations = products.flatMap(doc => [{ index: { _index: "products", _id: doc.id } }, doc]);
await client.bulk({ operations });
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Mappings first** | Define explicit mappings before indexing |
| **Keyword vs Text** | `keyword` for exact match, `text` for full-text |
| **Bulk API** | Use for batch indexing operations |
| **Pagination** | Use `search_after` for deep pagination |
| **Aliases** | Use index aliases for zero-downtime reindexing |
| **Analyzers** | Custom analyzers for language-specific search |
| **Shard sizing** | 10-50GB per shard for optimal performance |
| **Index lifecycle** | Use ILM policies for log data rotation |
