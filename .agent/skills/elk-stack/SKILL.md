---
name: ELK Stack
description: Skill for centralized logging with ELK Stack (Elasticsearch, Logstash, Kibana) — covering setup, index patterns, Logstash pipelines, Kibana dashboards, and log retention.
---

# ELK Stack Skill

## Overview
The **ELK Stack** (Elasticsearch + Logstash + Kibana) is the most popular centralized logging solution. Modern alternatives include **EFK** (Elasticsearch + Fluentd + Kibana) and **PLG** (Promtail + Loki + Grafana).

```
App Logs → Filebeat → Logstash → Elasticsearch → Kibana
                         │
                    Parse, enrich,
                    transform
```

---

## Docker Compose Setup

```yaml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.12.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=true
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.12.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5044:5044"    # Beats input
      - "5000:5000"    # TCP input
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.12.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - ELASTICSEARCH_USERNAME=kibana_system
      - ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.12.0
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    depends_on:
      - logstash

volumes:
  es_data:
```

---

## Logstash Pipeline

```ruby
# logstash/pipeline/main.conf

input {
  beats {
    port => 5044
  }
  tcp {
    port => 5000
    codec => json_lines
  }
}

filter {
  # Parse JSON logs
  if [message] =~ /^\{/ {
    json {
      source => "message"
    }
  }
  
  # Parse timestamp
  date {
    match => ["timestamp", "ISO8601"]
    target => "@timestamp"
  }
  
  # GeoIP from IP address
  if [ip] {
    geoip {
      source => "ip"
      target => "geoip"
    }
  }
  
  # Redact sensitive fields
  mutate {
    remove_field => ["password", "token", "apiKey", "authorization"]
  }
  
  # Add environment tag
  mutate {
    add_field => { "[@metadata][index]" => "logs-%{[service]}-%{+YYYY.MM.dd}" }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    user => "elastic"
    password => "${ELASTIC_PASSWORD}"
    index => "%{[@metadata][index]}"
  }
}
```

---

## Filebeat Configuration

```yaml
# filebeat/filebeat.yml
filebeat.inputs:
  - type: container
    paths:
      - '/var/lib/docker/containers/*/*.log'
    processors:
      - add_docker_metadata: ~
      - decode_json_fields:
          fields: ["message"]
          target: ""
          overwrite_keys: true

  - type: log
    paths:
      - '/var/log/app/*.log'
    json.keys_under_root: true
    json.add_error_key: true

output.logstash:
  hosts: ["logstash:5044"]

# Alternatively, direct to Elasticsearch:
# output.elasticsearch:
#   hosts: ["elasticsearch:9200"]
#   index: "logs-%{+yyyy.MM.dd}"
```

---

## Elasticsearch Index Template

```json
PUT _index_template/logs
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "index.lifecycle.name": "logs-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "level": { "type": "keyword" },
        "message": { "type": "text" },
        "service": { "type": "keyword" },
        "environment": { "type": "keyword" },
        "requestId": { "type": "keyword" },
        "traceId": { "type": "keyword" },
        "userId": { "type": "keyword" },
        "statusCode": { "type": "integer" },
        "duration_ms": { "type": "float" },
        "error.code": { "type": "keyword" },
        "error.message": { "type": "text" }
      }
    }
  }
}
```

---

## Index Lifecycle Management (ILM)

```json
PUT _ilm/policy/logs-policy
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": { "max_size": "10gb", "max_age": "1d" }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "shrink": { "number_of_shards": 1 },
          "forcemerge": { "max_num_segments": 1 }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "freeze": {}
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

---

## Useful Queries (Kibana / KQL)

```
# Find errors in auth service
service: "auth-service" AND level: "error"

# Slow requests (>1000ms)
duration_ms > 1000

# Specific request trace
requestId: "req-abc123"

# Failed logins in last 1 hour
message: "login_failed" AND @timestamp > now-1h

# 5xx errors by service
statusCode >= 500 AND statusCode < 600
```

## Best Practices
1. **Structured JSON logs** — parse at ingestion, not query time
2. **Index per service per day** — `logs-auth-service-2025.02.19`
3. **ILM policies** — auto-rotate, warm, cold, delete
4. **Separate hot/warm/cold nodes** — optimize storage costs
5. **Kibana dashboards** — error rate, latency percentiles, top errors
6. **Alerting** — Kibana alerts or ElastAlert for anomaly detection
7. **Security** — enable TLS, RBAC, redact PII before indexing
