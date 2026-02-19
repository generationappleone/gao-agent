---
name: Load Testing
description: Skill for performance and load testing with Artillery, k6, Autocannon, JMeter, and Apache Bench — covering scenario design, thresholds, reporting, and CI integration.
---

# Load Testing Skill

## Overview
Load testing verifies application performance under expected and peak traffic. This skill covers 5 tools for different use cases.

## Tool Selection Matrix

| Tool | Best For | Language | Install | Complexity |
|------|---------|---------|---------|-----------|
| **Artillery** | API load testing, scenarios | YAML/JS | npm | Low |
| **k6** | Scriptable load testing | JavaScript | binary/npm | Medium |
| **Autocannon** | Quick HTTP benchmarks | Node.js | npm | Very Low |
| **Apache Bench** | Simple HTTP benchmarks | CLI | system | Very Low |
| **JMeter** | Complex enterprise scenarios | Java/GUI | download | High |

---

## Artillery

### Installation
```bash
npm install -D artillery
```

### Config — `artillery.yml`
```yaml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 30     # ramp up
      arrivalRate: 5
      name: "Warm up"
    - duration: 60     # sustained load
      arrivalRate: 20
      name: "Sustained load"
    - duration: 30     # spike test
      arrivalRate: 50
      name: "Spike"
  defaults:
    headers:
      Content-Type: "application/json"
  ensure:
    thresholds:
      - http.response_time.p95: 500    # p95 < 500ms
      - http.response_time.p99: 1000   # p99 < 1000ms
      - http.codes.200: 95             # 95% success rate

scenarios:
  - name: "User browsing flow"
    flow:
      - get:
          url: "/"
      - think: 2
      - post:
          url: "/api/auth/login"
          json:
            email: "test@example.com"
            password: "password"
          capture:
            - json: "$.token"
              as: "authToken"
      - get:
          url: "/api/users"
          headers:
            Authorization: "Bearer {{ authToken }}"
      - think: 1
      - get:
          url: "/api/orders"
          headers:
            Authorization: "Bearer {{ authToken }}"
```

### CLI
```bash
npx artillery run artillery.yml                    # run test
npx artillery run artillery.yml --output report.json   # save report
npx artillery report report.json --output report.html  # HTML report
npx artillery quick --count 100 --num 10 http://localhost:3000/api/health  # quick test
```

---

## k6

### Installation
```bash
# Windows
choco install k6
# macOS
brew install k6
# npm wrapper
npm install -D k6
```

### Script — `load-test.js`
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // ramp up
    { duration: '1m',  target: 50 },  // sustained
    { duration: '30s', target: 0 },   // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.05'],
  },
};

export default function () {
  const loginRes = http.post('http://localhost:3000/api/auth/login', JSON.stringify({
    email: 'test@example.com',
    password: 'password',
  }), { headers: { 'Content-Type': 'application/json' } });

  check(loginRes, {
    'login status is 200': (r) => r.status === 200,
    'login response has token': (r) => JSON.parse(r.body).token !== undefined,
  });

  const token = JSON.parse(loginRes.body).token;
  const usersRes = http.get('http://localhost:3000/api/users', {
    headers: { Authorization: `Bearer ${token}` },
  });

  check(usersRes, { 'users status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

### CLI
```bash
k6 run load-test.js
k6 run --vus 50 --duration 30s load-test.js
k6 run --out json=results.json load-test.js
```

---

## Autocannon

### Installation
```bash
npm install -D autocannon
```

### Usage
```bash
npx autocannon -c 50 -d 10 -p 5 http://localhost:3000/api/health
# -c: connections  -d: duration(s)  -p: pipelining
```

### Programmatic
```javascript
const autocannon = require('autocannon');

autocannon({
  url: 'http://localhost:3000/api/health',
  connections: 50,
  duration: 10,
  headers: { Authorization: 'Bearer token' },
}, (err, result) => {
  console.log(`Avg latency: ${result.latency.average}ms`);
  console.log(`Requests/sec: ${result.requests.average}`);
  console.log(`Errors: ${result.errors}`);
});
```

---

## Apache Bench (ab)

### Usage
```bash
# 1000 requests, 50 concurrent
ab -n 1000 -c 50 http://localhost:3000/api/health

# POST with data
ab -n 500 -c 20 -p data.json -T application/json http://localhost:3000/api/users

# With auth header
ab -n 1000 -c 50 -H "Authorization: Bearer TOKEN" http://localhost:3000/api/users
```

---

## JMeter (Headless)

### Installation
Download from https://jmeter.apache.org/ or use Docker:
```bash
docker run -v $(pwd):/tests justb4/jmeter -n -t /tests/test-plan.jmx -l /tests/results.jtl
```

### CLI (Headless)
```bash
jmeter -n -t test-plan.jmx -l results.jtl -e -o report/
# -n: non-GUI  -t: test plan  -l: log  -e -o: report
```

---

## Performance Thresholds (Recommended)

| Metric | Good | Acceptable | Poor |
|--------|------|-----------|------|
| p50 latency | < 100ms | < 300ms | > 300ms |
| p95 latency | < 300ms | < 500ms | > 500ms |
| p99 latency | < 500ms | < 1000ms | > 1000ms |
| Error rate | < 1% | < 5% | > 5% |
| RPS | > 1000 | > 100 | < 100 |

## Best Practices
- Always warm up before measuring
- Test from a separate machine (not the same server)
- Use realistic data and user flows
- Set clear pass/fail thresholds
- Run in CI/CD to catch regressions early
- Test both read-heavy and write-heavy scenarios
- Monitor server resources (CPU, memory, DB connections) during tests
