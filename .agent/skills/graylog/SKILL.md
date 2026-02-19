---
name: Graylog
description: Skill for Graylog — centralized log management with search, dashboards, pipelines, alerts, and REST API for enterprise log analytics.
---

# Graylog — Centralized Log Management

## Overview
Graylog is an open-source centralized log management platform providing high-speed search, real-time analysis, dashboards, and alerting with a powerful pipeline processing engine.

## Search Syntax
```
-- Full-text search
ssh AND failed AND password

-- Field-based search
source:webserver AND http_response_code:500

-- Range queries
response_time:>5000

-- Wildcard and regex
message:/error.*connection/
source:web-*

-- Aggregation
source:* | stats count() by source | sort count desc
```

## Pipeline Rules
```
rule "extract_ip_from_syslog"
when
  has_field("message")
then
  let ip = regex("(\\d+\\.\\d+\\.\\d+\\.\\d+)", to_string($message.message));
  set_field("src_ip", ip["0"]);
end
```

## REST API
```bash
# Search for events
curl -u admin:admin \
  'http://graylog:9000/api/search/universal/relative?query=level:ERROR&range=3600'

# Create stream
curl -u admin:admin -X POST \
  -H 'Content-Type: application/json' \
  'http://graylog:9000/api/streams' \
  -d '{"title":"Errors","rules":[{"field":"level","value":"ERROR","type":1}]}'
```

## Configuration
```yaml
# GELF input (docker/applications)
# UDP input on port 12201
# Syslog input on port 514

# Elasticsearch connection
elasticsearch_hosts: http://elasticsearch:9200
```

## Best Practices
- Use **streams** to route logs to appropriate indices
- Implement **extractors** or **pipelines** for field extraction
- Set **index rotation** strategies (time or size-based)
- Use **content packs** for pre-built configurations
