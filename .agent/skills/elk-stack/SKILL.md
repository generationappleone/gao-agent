---
name: ELK Stack
description: Skill for centralized logging with ELK Stack (Elasticsearch, Logstash, Kibana) — covering setup, index patterns, Logstash pipelines, Kibana dashboards, and log retention.
---

# ELK Stack Skill

## Overview
The ELK Stack (Elasticsearch, Logstash, Kibana) is the standard for centralized logging and log analysis. Elasticsearch stores and indexes logs, Logstash collects and transforms log data, and Kibana provides visualization and dashboards. Filebeat is the lightweight log shipper.

**References**:
- [Elastic Documentation](https://www.elastic.co/guide/)
- [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/)

---

## Setup

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.12.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports: ["9200:9200"]
    volumes: [es_data:/usr/share/elasticsearch/data]

  kibana:
    image: docker.elastic.co/kibana/kibana:8.12.0
    ports: ["5601:5601"]
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200

  logstash:
    image: docker.elastic.co/logstash/logstash:8.12.0
    volumes: [./logstash.conf:/usr/share/logstash/pipeline/logstash.conf]
    depends_on: [elasticsearch]
```

---

## Logstash Pipeline

```ruby
# logstash.conf
input {
  beats { port => 5044 }
  tcp { port => 5000, codec => json }
}

filter {
  if [type] == "nginx" {
    grok { match => { "message" => '%{COMBINEDAPACHELOG}' } }
    date { match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"] }
    geoip { source => "clientip" }
  }

  if [type] == "app" {
    json { source => "message" }
    date { match => ["timestamp", "ISO8601"] }
    mutate { remove_field => ["@version", "host"] }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "%{[type]}-%{+YYYY.MM.dd}"
  }
}
```

---

## Application Logging (Node.js)

```typescript
import winston from 'winston';
import { ElasticsearchTransport } from 'winston-elasticsearch';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
  transports: [
    new winston.transports.Console(),
    new ElasticsearchTransport({
      level: 'info',
      clientOpts: { node: process.env.ELASTICSEARCH_URL || 'http://localhost:9200' },
      indexPrefix: 'myapp-logs',
    }),
  ],
});

// Usage
logger.info('Order created', { orderId: order.id, userId: user.id, total: order.total });
logger.error('Payment failed', { orderId, error: err.message });
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Structured logging** | JSON format for machine parsing |
| **Index patterns** | Date-based indices for retention |
| **Logstash filters** | grok for parsing, date for timestamps |
| **Filebeat** | Lightweight shipper for log files |
| **Kibana** | Dashboards, Discover, Lens for analysis |
| **ILM** | Index Lifecycle Management for retention |
| **Retention** | Auto-delete old indices (30/90 days) |
| **Correlation** | Use request IDs across services |
| **Alerts** | Kibana alerts for error spikes |
| **Security** | Enable xpack.security in production |

---

## Rules Integration
- **Collection**: Logstash/Filebeat for log shipping
- **Storage**: Elasticsearch with date-based indices
- **Analysis**: Kibana dashboards and Discover
- **Application**: Winston with Elasticsearch transport
