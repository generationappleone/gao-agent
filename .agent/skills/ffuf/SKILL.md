---
name: FFuf
description: Skill for web fuzzing with FFuf, covering directory discovery, parameter fuzzing, virtual host discovery, filter techniques, and wordlist management.
---

# FFuf Skill

## Overview
FFuf (Fuzz Faster U Fool) is a fast web fuzzer written in Go, used for directory/file discovery, parameter fuzzing, virtual host enumeration, and content discovery.

## Installation
```bash
# Go install
go install github.com/ffuf/ffuf/v2@latest

# Download binary
# https://github.com/ffuf/ffuf/releases

# Docker
docker pull ghcr.io/ffuf/ffuf
```

## Core Usage

### Directory/File Discovery
```bash
# Basic directory brute force
ffuf -w /path/to/wordlist.txt -u http://localhost:3000/FUZZ

# With extensions
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -e .php,.html,.js,.txt,.bak

# Filter by status code
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -mc 200,301,302

# Filter OUT by status code
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -fc 404

# Filter by response size (remove noise)
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -fs 4242
```

### Parameter Fuzzing
```bash
# GET parameter names
ffuf -w params.txt -u "http://localhost:3000/api/search?FUZZ=test"

# GET parameter values
ffuf -w values.txt -u "http://localhost:3000/api/users?id=FUZZ"

# POST data fuzzing
ffuf -w wordlist.txt -u http://localhost:3000/api/login \
  -X POST -d '{"email":"FUZZ","password":"test"}' \
  -H "Content-Type: application/json"
```

### Virtual Host Discovery
```bash
ffuf -w vhosts.txt -u http://localhost:3000 -H "Host: FUZZ.example.com" -fs 4242
```

### Header Fuzzing
```bash
ffuf -w headers.txt -u http://localhost:3000/api/admin \
  -H "FUZZ: value" -mc 200
```

### Multi-keyword Fuzzing
```bash
ffuf -w users.txt:USER -w passwords.txt:PASS \
  -u http://localhost:3000/api/login \
  -X POST -d '{"email":"USER","password":"PASS"}' \
  -H "Content-Type: application/json" \
  -fc 401 -mode clusterbomb
```

## Output Options
```bash
# JSON output
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -o results.json -of json

# CSV output
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -o results.csv -of csv

# HTML report
ffuf -w wordlist.txt -u http://localhost:3000/FUZZ -o results.html -of html
```

## Advanced Options
```bash
# Rate limiting (requests per second)
ffuf -w wordlist.txt -u URL -rate 50

# Threads
ffuf -w wordlist.txt -u URL -t 40

# Timeout
ffuf -w wordlist.txt -u URL -timeout 10

# Follow redirects
ffuf -w wordlist.txt -u URL -r

# With proxy (for Burp/ZAP)
ffuf -w wordlist.txt -u URL -x http://127.0.0.1:8080

# With cookies
ffuf -w wordlist.txt -u URL -b "session=abc123"

# With auth header
ffuf -w wordlist.txt -u URL -H "Authorization: Bearer TOKEN"

# Recursive
ffuf -w wordlist.txt -u URL -recursion -recursion-depth 3
```

## Common Wordlists
```
SecLists (https://github.com/danielmiessler/SecLists):
- Discovery/Web-Content/common.txt           (4,600 entries)
- Discovery/Web-Content/directory-list-2.3-medium.txt (220K entries)
- Discovery/Web-Content/api/api-endpoints.txt
- Discovery/DNS/subdomains-top1million-5000.txt
- Fuzzing/special-chars.txt
- Passwords/Common-Credentials/top-1000.txt
```

## Best Practices
- Always use filters (`-fc 404` or `-fs SIZE`) to reduce noise
- Start with small wordlists, expand if needed
- Use `-rate` to avoid overwhelming the server
- Use `-t` wisely — too many threads may cause false negatives
- Combine with proxy (`-x`) for deeper inspection
- Only test on authorized targets
- Save results with `-o` for documentation
