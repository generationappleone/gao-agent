---
name: Load Testing
description: Skill for performance and load testing with Artillery, k6, Autocannon, JMeter, and Apache Bench — covering scenario design, thresholds, reporting, and CI integration.
---

# Load Testing Skill

## Overview
Load testing validates application performance under expected and peak traffic. k6 and Artillery are modern, scriptable tools for HTTP, WebSocket, and gRPC load testing. Define scenarios, set thresholds, analyze results, and integrate into CI/CD pipelines.

**References**:
- [k6 Documentation](https://k6.io/docs/)
- [Artillery Documentation](https://www.artillery.io/docs)

---

## k6

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // ramp up
    { duration: '3m', target: 50 },   // sustain
    { duration: '1m', target: 100 },  // peak
    { duration: '2m', target: 100 },  // sustain peak
    { duration: '1m', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    errors: ['rate<0.01'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  // List products
  const listRes = http.get(`${__ENV.BASE_URL}/api/products?page=1`);
  check(listRes, { 'list status 200': (r) => r.status === 200 });
  errorRate.add(listRes.status !== 200);
  responseTime.add(listRes.timings.duration);

  sleep(1);

  // Get product detail
  const detailRes = http.get(`${__ENV.BASE_URL}/api/products/sample-product`);
  check(detailRes, { 'detail status 200': (r) => r.status === 200 });

  sleep(Math.random() * 2);
}
```

```bash
k6 run --env BASE_URL=http://localhost:3000 load-test.js
k6 run --out json=results.json load-test.js  # JSON output
```

---

## Artillery

```yaml
# artillery.yml
config:
  target: http://localhost:3000
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Sustained load"
    - duration: 60
      arrivalRate: 100
      name: "Peak load"
  defaults:
    headers:
      Content-Type: application/json

scenarios:
  - name: "Browse products"
    flow:
      - get:
          url: "/api/products?page=1"
          expect:
            - statusCode: 200
      - think: 2
      - get:
          url: "/api/products/sample-product"
          expect:
            - statusCode: 200
```

```bash
artillery run artillery.yml
artillery run --output report.json artillery.yml
artillery report report.json
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Scenarios** | Realistic user journeys |
| **Ramp up** | Gradually increase load |
| **Thresholds** | P95 < 500ms, error rate < 1% |
| **Think time** | Add sleep/think between requests |
| **k6** | JavaScript-based, lightweight |
| **Artillery** | YAML-based, easy configuration |
| **CI** | Run in CI with pass/fail thresholds |
| **Baseline** | Establish performance baselines |
| **Environment** | Test against production-like env |
| **Reports** | HTML/JSON reports for analysis |

---

## Rules Integration
- **k6**: JavaScript scenarios with thresholds
- **Artillery**: YAML configuration with phases
- **Thresholds**: P95 latency and error rate gates
- **CI**: Automated performance regression testing
