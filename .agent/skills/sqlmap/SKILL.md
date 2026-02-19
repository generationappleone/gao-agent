---
name: SQLMap
description: Skill for automated SQL injection detection and exploitation testing with SQLMap, covering detection, database enumeration, WAF bypass, and safe testing practices.
---

# SQLMap Skill

## Overview
SQLMap automates SQL injection detection and exploitation. Used for security testing to verify that applications properly protect against SQL injection (OWASP A03).

## Installation
```bash
pip install sqlmap
# or
git clone https://github.com/sqlmapproject/sqlmap.git
```

## Basic Usage

### URL-based Testing
```bash
# Test a URL parameter
sqlmap -u "http://localhost:3000/api/users?id=1" --batch

# Test POST request
sqlmap -u "http://localhost:3000/api/login" --data="email=test&password=test" --batch

# With JSON body
sqlmap -u "http://localhost:3000/api/search" --data='{"query":"test"}' \
  --headers="Content-Type: application/json" --batch

# With auth token
sqlmap -u "http://localhost:3000/api/users?id=1" \
  --headers="Authorization: Bearer TOKEN" --batch
```

### Detection Levels
```bash
# Level 1 (default) - basic tests
sqlmap -u URL --level 1

# Level 3 - more injection points (headers, cookies)
sqlmap -u URL --level 3

# Level 5 - maximum coverage (slow)
sqlmap -u URL --level 5

# Risk levels
sqlmap -u URL --risk 1   # safe (default)
sqlmap -u URL --risk 2   # + time-based blind
sqlmap -u URL --risk 3   # + OR-based (may modify data!)
```

### Database Enumeration (After Finding Injection)
```bash
# List databases
sqlmap -u URL --dbs

# List tables
sqlmap -u URL -D database_name --tables

# Dump table
sqlmap -u URL -D database_name -T users --dump

# Specific columns
sqlmap -u URL -D database_name -T users -C email,password --dump
```

### Advanced Options
```bash
# Specify DBMS
sqlmap -u URL --dbms=postgresql

# Use proxy
sqlmap -u URL --proxy="http://127.0.0.1:8080"

# WAF bypass
sqlmap -u URL --tamper=space2comment,between

# Use random user agent
sqlmap -u URL --random-agent

# Threads (faster)
sqlmap -u URL --threads=5

# Output to file
sqlmap -u URL --output-dir=./sqlmap-results

# Test all parameters
sqlmap -u URL -p "id,name,email"  # specific params
```

## Safe Testing Practices
```bash
# ⚠️ ALWAYS use --batch and --safe-url for automated testing
sqlmap -u URL --batch --safe-url="http://localhost:3000/" --safe-freq=3

# Use GET-only techniques (safest)
sqlmap -u URL --technique=B   # Boolean-based blind only

# Techniques:
# B = Boolean-based blind
# E = Error-based
# U = UNION query
# S = Stacked queries (dangerous!)
# T = Time-based blind
# Q = Inline queries
```

## Output Example
```
[INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[INFO] GET parameter 'id' appears to be 'AND boolean-based blind' injectable
[INFO] testing 'MySQL >= 5.0 AND error-based'
[INFO] GET parameter 'id' is 'MySQL >= 5.0 AND error-based' injectable

Parameter: id (GET)
    Type: boolean-based blind
    Title: AND boolean-based blind - WHERE or HAVING clause
    Payload: id=1 AND 5693=5693

    Type: error-based
    Title: MySQL >= 5.0 AND error-based
    Payload: id=1 AND (SELECT 1234 FROM(SELECT COUNT(*),CONCAT(0x71,(SELECT version()),0x71,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)
```

## Best Practices
- **NEVER** run against production without explicit permission
- Use `--risk 1` and `--level 1` first, increase only if needed
- Use `--batch` for automated/CI testing
- Avoid `--risk 3` (may modify data with OR-based payloads)
- If SQLMap finds an injection = **CRITICAL vulnerability** → fix immediately
- Always use parameterized queries to prevent SQL injection
- Log all SQLMap testing for audit trail
