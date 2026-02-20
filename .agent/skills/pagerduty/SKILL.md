---
name: PagerDuty
description: Skill for incident management and alerting with PagerDuty, covering service setup, event API, escalation policies, incident response, and monitoring integration.
---

# PagerDuty Skill

## Overview
PagerDuty is an incident management platform that combines on-call scheduling, alerting, and incident response automation. It integrates with monitoring tools (Datadog, Prometheus, New Relic) to alert the right people when incidents occur.

**References**:
- [PagerDuty API](https://developer.pagerduty.com/api-reference/)
- [Events API v2](https://developer.pagerduty.com/docs/events-api-v2/overview/)
- [PagerDuty Integrations](https://www.pagerduty.com/integrations/)

---

## Events API v2

```typescript
// src/lib/pagerduty.ts

const PD_ROUTING_KEY = process.env.PAGERDUTY_ROUTING_KEY!;
const PD_EVENTS_URL = 'https://events.pagerduty.com/v2/enqueue';

interface PagerDutyPayload {
  summary: string;
  severity: 'critical' | 'error' | 'warning' | 'info';
  source: string;
  component?: string;
  group?: string;
  class?: string;
  custom_details?: Record<string, any>;
}

// ── Trigger incident ──
async function triggerIncident(payload: PagerDutyPayload, dedupKey?: string) {
  const res = await fetch(PD_EVENTS_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      routing_key: PD_ROUTING_KEY,
      event_action: 'trigger',
      dedup_key: dedupKey || `${payload.source}-${payload.component}-${Date.now()}`,
      payload: {
        ...payload,
        timestamp: new Date().toISOString(),
      },
      links: [
        { href: 'https://grafana.myapp.com/d/overview', text: 'Grafana Dashboard' },
        { href: 'https://app.datadoghq.com/apm/services/myapp-api', text: 'Datadog APM' },
      ],
      images: [],
    }),
  });

  const result = await res.json();
  console.log(`PagerDuty incident triggered: ${result.dedup_key}`);
  return result;
}

// ── Acknowledge incident ──
async function acknowledgeIncident(dedupKey: string) {
  await fetch(PD_EVENTS_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      routing_key: PD_ROUTING_KEY,
      event_action: 'acknowledge',
      dedup_key: dedupKey,
    }),
  });
}

// ── Resolve incident ──
async function resolveIncident(dedupKey: string) {
  await fetch(PD_EVENTS_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      routing_key: PD_ROUTING_KEY,
      event_action: 'resolve',
      dedup_key: dedupKey,
    }),
  });
}
```

---

## Alert Integration Examples

```typescript
// ── High error rate alert ──
async function checkErrorRate() {
  const errorRate = await getErrorRate();  // From Prometheus/metrics

  if (errorRate > 5) {
    await triggerIncident({
      summary: `High error rate: ${errorRate.toFixed(1)}% (threshold: 5%)`,
      severity: 'critical',
      source: 'myapp-api',
      component: 'api-server',
      group: 'production',
      class: 'error_rate',
      custom_details: {
        error_rate: errorRate,
        threshold: 5,
        environment: 'production',
        dashboard: 'https://grafana.myapp.com/d/errors',
        recent_errors: await getRecentErrors(5),
      },
    }, 'myapp-high-error-rate');  // Dedup key prevents duplicate incidents
  } else {
    // Auto-resolve when error rate returns to normal
    await resolveIncident('myapp-high-error-rate');
  }
}

// ── Database connection alert ──
async function checkDatabaseConnections() {
  const activeConns = await getActiveConnections();
  const maxConns = 100;

  if (activeConns > maxConns * 0.9) {
    await triggerIncident({
      summary: `Database connections near limit: ${activeConns}/${maxConns}`,
      severity: activeConns > maxConns * 0.95 ? 'critical' : 'warning',
      source: 'myapp-api',
      component: 'database',
      group: 'production',
      class: 'resource_exhaustion',
      custom_details: {
        active_connections: activeConns,
        max_connections: maxConns,
        utilization: `${(activeConns / maxConns * 100).toFixed(1)}%`,
      },
    }, 'myapp-db-connections');
  }
}

// ── Health check failure ──
async function healthCheckMonitor() {
  try {
    const res = await fetch('https://api.myapp.com/health', { signal: AbortSignal.timeout(5000) });
    if (res.ok) {
      await resolveIncident('myapp-health-check');
    } else {
      throw new Error(`Health check returned ${res.status}`);
    }
  } catch (error) {
    await triggerIncident({
      summary: `Health check failed: ${(error as Error).message}`,
      severity: 'critical',
      source: 'myapp-api',
      component: 'health-check',
      group: 'production',
      class: 'availability',
    }, 'myapp-health-check');
  }
}
```

---

## REST API (Incident Management)

```typescript
const PD_API_KEY = process.env.PAGERDUTY_API_KEY!;
const PD_API_URL = 'https://api.pagerduty.com';

async function pdApi(method: string, path: string, body?: any) {
  const res = await fetch(`${PD_API_URL}${path}`, {
    method,
    headers: {
      'Authorization': `Token token=${PD_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return res.json();
}

// ── List incidents ──
const { incidents } = await pdApi('GET', '/incidents?statuses[]=triggered&statuses[]=acknowledged');

// ── Get incident details ──
const { incident } = await pdApi('GET', `/incidents/${incidentId}`);

// ── List on-call users ──
const { oncalls } = await pdApi('GET', '/oncalls?include[]=users');

// ── Create incident note ──
await pdApi('POST', `/incidents/${incidentId}/notes`, {
  note: {
    content: 'Root cause identified: database connection pool exhaustion due to leaked connections.',
  },
});

// ── Merge incidents ──
await pdApi('PUT', `/incidents/${targetIncidentId}/merge`, {
  source_incidents: [
    { id: duplicateIncidentId, type: 'incident_reference' },
  ],
});
```

---

## Monitoring Tool Integration

```yaml
# Prometheus Alertmanager → PagerDuty
# prometheus/alertmanager.yml
receivers:
  - name: 'pagerduty-critical'
    pagerduty_configs:
      - routing_key: '<PAGERDUTY_ROUTING_KEY>'
        severity: '{{ if eq .CommonLabels.severity "critical" }}critical{{ else }}warning{{ end }}'
        description: '{{ .CommonAnnotations.summary }}'
        details:
          firing: '{{ .Alerts.Firing | len }}'
          resolved: '{{ .Alerts.Resolved | len }}'
          dashboard: 'https://grafana.myapp.com'

route:
  receiver: 'pagerduty-critical'
  routes:
    - match: { severity: critical }
      receiver: 'pagerduty-critical'
      repeat_interval: 15m
```

```yaml
# Grafana → PagerDuty
# grafana/provisioning/alerting/contact-points.yml
contactPoints:
  - orgId: 1
    name: pagerduty
    receivers:
      - uid: pagerduty-1
        type: pagerduty
        settings:
          integrationKey: ${PAGERDUTY_ROUTING_KEY}
          severity: critical
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Dedup keys** | Use consistent dedup keys to prevent duplicate incidents |
| **Severity levels** | critical (page), error (alert), warning (notify), info (log) |
| **Auto-resolve** | Resolve incidents when conditions return to normal |
| **Escalation** | Define escalation policies with timeout and fallback |
| **Runbooks** | Link runbook URLs in incident details |
| **Custom details** | Include metrics, thresholds, dashboard links |
| **On-call schedules** | Rotate on-call weekly, define business hours overrides |
| **Noise reduction** | Dedup, suppress, and group related alerts |
| **Postmortems** | Create postmortem for every critical incident |
| **Integration** | Connect to Slack for real-time incident updates |

---

## Rules Integration
- **Events API v2**: Trigger/acknowledge/resolve with dedup keys
- **REST API**: Incident management, on-call queries, incident notes
- **Integration**: Prometheus Alertmanager, Grafana, Datadog → PagerDuty
- **Automation**: Auto-resolve, custom details with dashboards/runbooks
- **Response**: Escalation policies, on-call schedules, postmortems
