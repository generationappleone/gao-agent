---
name: Nagios
description: Skill for Nagios — enterprise network monitoring with host/service checks, alerting, plugins, and performance data collection.
---

# Nagios — Network Monitoring

## Overview
Nagios is an open-source enterprise monitoring system providing host/service checks, alerting, event handling, and performance graphs for network infrastructure.

## Configuration
```cfg
# Host definition
define host {
    host_name           webserver01
    alias               Web Server 01
    address             192.168.1.10
    check_command       check-host-alive
    max_check_attempts  5
    notification_interval 30
    notification_period 24x7
    contacts            admin
}

# Service definition
define service {
    host_name           webserver01
    service_description HTTP
    check_command       check_http!-p 80
    max_check_attempts  3
    check_interval      5
    retry_interval      1
    notification_interval 30
}

# Custom command
define command {
    command_name    check_ssl_expiry
    command_line    $USER1$/check_ssl_cert -H $HOSTADDRESS$ -w 30 -c 7
}
```

## Key Plugins
| Plugin | Check |
|--------|-------|
| `check_ping` | Host reachability |
| `check_http` | Web server availability |
| `check_tcp` | TCP port connectivity |
| `check_disk` | Disk space usage |
| `check_load` | System CPU load |
| `check_snmp` | SNMP-based monitoring |

## API (Nagios XI)
```bash
curl "https://nagios/nagiosxi/api/v1/objects/hoststatus?apikey=YOUR_KEY"
```

## Best Practices
- Use **NRPE** (Nagios Remote Plugin Executor) for remote checks
- Implement **service dependencies** to prevent alert storms
- Configure **escalation policies** for critical services
