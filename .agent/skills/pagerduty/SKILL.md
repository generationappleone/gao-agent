---
name: PagerDuty
description: Skill for incident management and alerting with PagerDuty, covering service setup, event API, escalation policies, incident response, and monitoring integration.
---

# PagerDuty Skill

## Overview
PagerDuty is an incident management platform that alerts the right people when systems fail, manages on-call schedules, and orchestrates incident response. Requires an account and API key.

## Setup
```bash
# Environment variables
PAGERDUTY_API_KEY=your_api_key
PAGERDUTY_SERVICE_KEY=your_service_integration_key
PAGERDUTY_ROUTING_KEY=your_routing_key
```

## Events API v2 (Triggering Alerts)

### Trigger Alert
```bash
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H "Content-Type: application/json" \
  -d '{
    "routing_key": "'$PAGERDUTY_ROUTING_KEY'",
    "event_action": "trigger",
    "dedup_key": "test-failure-2026-02-19",
    "payload": {
      "summary": "Critical test failures detected in production deployment",
      "severity": "critical",
      "source": "CI/CD Pipeline",
      "component": "api-service",
      "group": "production",
      "class": "test-failure",
      "custom_details": {
        "tests_failed": 5,
        "tests_total": 150,
        "build_url": "https://github.com/org/repo/actions/runs/12345",
        "failing_tests": [
          "auth.login.test - invalid credentials handling",
          "orders.create.test - stock validation"
        ]
      }
    },
    "links": [
      { "href": "https://github.com/org/repo/actions/runs/12345", "text": "Build Details" }
    ]
  }'
```

### Acknowledge Alert
```bash
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -d '{
    "routing_key": "'$PAGERDUTY_ROUTING_KEY'",
    "event_action": "acknowledge",
    "dedup_key": "test-failure-2026-02-19"
  }'
```

### Resolve Alert
```bash
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -d '{
    "routing_key": "'$PAGERDUTY_ROUTING_KEY'",
    "event_action": "resolve",
    "dedup_key": "test-failure-2026-02-19"
  }'
```

## Node.js Integration
```javascript
const axios = require('axios');

async function triggerPagerDuty(summary, severity, details) {
  await axios.post('https://events.pagerduty.com/v2/enqueue', {
    routing_key: process.env.PAGERDUTY_ROUTING_KEY,
    event_action: 'trigger',
    dedup_key: `incident-${Date.now()}`,
    payload: {
      summary,
      severity, // 'critical', 'error', 'warning', 'info'
      source: 'my-application',
      custom_details: details,
    },
  });
}

// Usage in error handling
try {
  await criticalOperation();
} catch (error) {
  await triggerPagerDuty(
    `Critical failure: ${error.message}`,
    'critical',
    { stack: error.stack, timestamp: new Date().toISOString() }
  );
}
```

## Severity Mapping

| PagerDuty Severity | When to Use | Urgency |
|-------------------|------------|---------|
| `critical` | System down, data loss | High — immediate page |
| `error` | Feature broken, degraded service | High — 15min response |
| `warning` | Performance issues, high error rate | Low — next business day |
| `info` | Informational, non-actionable | Low — notification only |

## Integration with Testing

### Post-test Alerting
```bash
# In CI/CD: alert PagerDuty if critical tests fail
if [ $TEST_EXIT_CODE -ne 0 ]; then
  curl -X POST https://events.pagerduty.com/v2/enqueue \
    -H "Content-Type: application/json" \
    -d "{
      \"routing_key\": \"$PAGERDUTY_ROUTING_KEY\",
      \"event_action\": \"trigger\",
      \"payload\": {
        \"summary\": \"Critical tests failed in deployment pipeline\",
        \"severity\": \"critical\",
        \"source\": \"ci-pipeline\"
      }
    }"
fi
```

## CI/CD Integration
```yaml
# GitHub Actions
- name: Notify PagerDuty on Failure
  if: failure()
  uses: PagerDuty/pagerduty-change-events-action@main
  with:
    integration-key: ${{ secrets.PAGERDUTY_ROUTING_KEY }}
    change-summary: "Deployment failed"
```

## Best Practices
- Use `dedup_key` to prevent duplicate alerts for the same issue
- Set appropriate severity — don't alert `critical` for warnings
- Include actionable details in `custom_details`
- Set up escalation policies with clear ownership
- Use maintenance windows during planned downtime
- Integrate with Slack/Teams for visibility
- Review on-call schedules regularly
