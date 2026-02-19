---
name: MCP Server — Netdata
description: MCP Server for Netdata — real-time infrastructure monitoring enabling AI assistants to query metrics, analyze alerts, explore logs, and perform root cause analysis with ML-powered anomaly detection.
---

# MCP Server — Netdata

## Overview
Netdata MCP Server provides AI assistants with comprehensive access to infrastructure observability data. Built into every Netdata Agent (v2.6.0+), it enables natural-language-driven monitoring, troubleshooting, and root cause analysis.

## Tools Provided

| Tool | Description |
|------|-------------|
| `get_nodes` | Discover monitored nodes — hardware specs, OS, streaming topology |
| `get_metrics` | Full-text search across contexts, instances, dimensions, and labels |
| `get_functions` | Discover system functions (processes, network connections, systemd-journal) |
| `get_alerts` | View active and raised alerts with transition history |
| `query_metrics` | Execute complex metric aggregations and groupings |
| `get_anomaly_scores` | ML-powered anomaly detection scoring on any metric |
| `get_metric_correlations` | Correlate metrics for root cause analysis |
| `explore_logs` | Access logs from connected nodes |
| `execute_function` | Run Netdata functions on connected nodes (via Netdata Parent) |

## Configuration

### Local Agent MCP (Data stays on-premises)
```json
{
  "mcpServers": {
    "netdata": {
      "url": "http://localhost:19999/api/v3/mcp"
    }
  }
}
```

### Netdata Cloud MCP (Infrastructure-wide)
```json
{
  "mcpServers": {
    "netdata": {
      "url": "https://app.netdata.cloud/api/v3/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_NETDATA_CLOUD_TOKEN"
      }
    }
  }
}
```

## Monitored Infrastructure
- **Servers**: Linux, Windows, macOS, FreeBSD
- **Containers**: Docker, containerd, Podman, LXC, Kubernetes
- **Cloud**: AWS, Azure, GCP
- **Databases**: 40+ databases (MySQL, PostgreSQL, MongoDB, Redis, etc.)
- **Web Servers**: Nginx, Apache, Caddy
- **Network**: SNMP devices, network interfaces
- **Hardware**: Sensors, IoT devices

## Key Capabilities
- **Per-second granularity**: Sub-2-second latency for real-time monitoring
- **ML anomaly detection**: Unsupervised ML on every metric — reduces false positives
- **Zero-configuration**: Auto-discovers services, generates 400+ pre-configured alerts
- **Data sovereignty**: All data stays on your infrastructure
- **Root cause analysis**: Metric correlation to pinpoint issues fast

## Use Cases
- AI-assisted infrastructure troubleshooting
- Proactive anomaly detection and alerting
- Natural-language metric queries ("Show CPU usage last hour")
- Automated incident analysis and reporting
