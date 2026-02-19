---
name: YAML (YML)
description: Skill for writing well-structured YAML files — covering YAML 1.2 specification, syntax rules, data types, anchors & aliases, multi-document files, schema validation, and common use cases (CI/CD, Docker Compose, Kubernetes, OpenAPI, Ansible).
---

# YAML (YML) Skill

## Overview
YAML (YAML Ain't Markup Language) is a human-readable data serialization standard. This skill follows **YAML 1.2** specification (the current global standard) for configuration files, CI/CD pipelines, infrastructure-as-code, and data exchange.

**Reference**: [YAML 1.2 Specification](https://yaml.org/spec/1.2.2/)

## Core Syntax Rules

### Indentation
```yaml
# ✅ Use 2-space indentation (standard convention)
# ❌ NEVER use tabs — YAML forbids tabs for indentation
parent:
  child:
    grandchild: value
```

### Comments
```yaml
# Full line comment
key: value  # Inline comment
```

### Key-Value Pairs
```yaml
# Scalars
string_key: Hello World
number_key: 42
float_key: 3.14
boolean_true: true       # true, True, TRUE, yes, on
boolean_false: false      # false, False, FALSE, no, off
null_value: null          # null, Null, NULL, ~
date: 2026-02-19
datetime: 2026-02-19T15:08:47+07:00
```

### Strings
```yaml
# Plain (unquoted) — avoid special characters
plain: Hello World

# Single quotes — preserves literal, no escape sequences
literal: 'Hello\nWorld'           # Output: Hello\nWorld

# Double quotes — supports escape sequences
escaped: "Hello\nWorld"           # Output: Hello (newline) World
unicode: "\u0041\u0042\u0043"     # Output: ABC

# ✅ BEST PRACTICE: Quote strings that look like other types
version: "1.0"     # Not number 1.0
flag: "yes"        # Not boolean true
port: "8080"       # Not number 8080
empty: ""          # Not null
```

### Multi-line Strings
```yaml
# Literal Block Scalar (|) — preserves newlines
description: |
  This is line one.
  This is line two.
  
  This is line four after a blank line.

# Folded Block Scalar (>) — folds newlines into spaces
summary: >
  This is a long paragraph
  that will be folded into
  a single line.

# Chomping indicators
keep_trailing: |+    # Keep trailing newlines
  Line one.
  Line two.

strip_trailing: |-   # Strip final newline
  Line one.
  Line two.

clip_trailing: |     # Default: single newline at end
  Line one.
  Line two.
```

## Data Structures

### Sequences (Lists/Arrays)
```yaml
# Block style
fruits:
  - Apple
  - Banana
  - Cherry

# Flow style (inline)
colors: [red, green, blue]

# Nested sequences
matrix:
  - [1, 2, 3]
  - [4, 5, 6]
  - [7, 8, 9]
```

### Mappings (Objects/Dictionaries)
```yaml
# Block style
person:
  name: John Doe
  age: 30
  email: john@example.com

# Flow style (inline)
point: {x: 10, y: 20, z: 30}

# Nested mappings
database:
  primary:
    host: localhost
    port: 5432
    name: mydb
  replica:
    host: replica.local
    port: 5432
    name: mydb
```

### Complex Keys
```yaml
# Explicit key indicator
? - key
  - part
: value

# Mapping as key (rare, but valid)
? {name: John, age: 30}
: "Complex key value"
```

## Advanced Features

### Anchors & Aliases (DRY Principle)
```yaml
# Define anchor with &
defaults: &default_settings
  adapter: postgres
  host: localhost
  port: 5432
  pool: 5

# Reference with *
development:
  database:
    <<: *default_settings    # Merge key: inherit all
    name: dev_db

staging:
  database:
    <<: *default_settings
    name: staging_db
    host: staging.db.local   # Override specific value

production:
  database:
    <<: *default_settings
    name: prod_db
    host: prod.db.local
    pool: 25                 # Override pool size
```

### Multi-Document Files
```yaml
# Document separator: ---
# Document terminator: ...

---
# Document 1: Application config
app:
  name: MyApp
  version: "1.0.0"
...

---
# Document 2: Database config
database:
  host: localhost
  port: 5432
...
```

### Tags (Explicit Typing)
```yaml
# Standard tags
explicit_string: !!str 123        # Force string "123"
explicit_int: !!int "42"          # Force integer 42
explicit_float: !!float "3.14"    # Force float 3.14
explicit_bool: !!bool "true"      # Force boolean true
explicit_null: !!null ""          # Force null

# Binary data
icon: !!binary |
  R0lGODlhDAAMAIQAAP//9/X17unp5WZmZg...
```

## Common File Patterns

### GitHub Actions (CI/CD)
```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  contents: read

env:
  NODE_VERSION: "20"

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
```

### GitLab CI
```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

variables:
  NODE_IMAGE: node:20-alpine

default:
  image: $NODE_IMAGE
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/

build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:
  stage: test
  script:
    - npm ci
    - npm test
  coverage: '/Statements\s*:\s*(\d+\.?\d*)%/'

deploy_staging:
  stage: deploy
  script:
    - ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - ./deploy.sh production
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

### Docker Compose
```yaml
# docker-compose.yml
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
      - REDIS_URL=redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    volumes:
      - ./uploads:/app/uploads
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5

  cache:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - backend

volumes:
  postgres_data:

networks:
  backend:
    driver: bridge
```

### Kubernetes Deployment
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
  labels:
    app: myapp
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
        - name: myapp
          image: myregistry/myapp:1.0.0
          ports:
            - containerPort: 3000
              protocol: TCP
          env:
            - name: NODE_ENV
              value: production
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: password
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: production
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  type: ClusterIP
```

### OpenAPI Specification
```yaml
# openapi.yaml
openapi: "3.1.0"
info:
  title: My API
  version: "1.0.0"
  description: RESTful API for MyApp
  contact:
    name: API Support
    email: api@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

paths:
  /users:
    get:
      summary: List users
      operationId: listUsers
      tags:
        - Users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        "200":
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: "#/components/schemas/User"
                  meta:
                    $ref: "#/components/schemas/Pagination"

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
          example: John Doe
        email:
          type: string
          format: email
          example: john@example.com
    Pagination:
      type: object
      properties:
        total:
          type: integer
        page:
          type: integer
        limit:
          type: integer
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []
```

### Ansible Playbook
```yaml
# playbook.yml
---
- name: Setup Web Server
  hosts: webservers
  become: true
  vars:
    app_name: myapp
    app_port: 3000
    node_version: "20"

  tasks:
    - name: Update apt cache
      apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install required packages
      apt:
        name:
          - nginx
          - curl
          - git
        state: present

    - name: Configure Nginx
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app_name }}
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

## Schema Validation

### JSON Schema for YAML validation
```yaml
# Use $schema for IDE support
# Example: VS Code with YAML extension
# .vscode/settings.json
# {
#   "yaml.schemas": {
#     "https://json.schemastore.org/github-workflow.json": ".github/workflows/*.yml",
#     "https://json.schemastore.org/docker-compose.json": "docker-compose*.yml"
#   }
# }
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **2-space indent** | Standard convention across all YAML files |
| **No tabs** | YAML specification forbids tabs for indentation |
| **Quote ambiguous** | Always quote strings like `"yes"`, `"1.0"`, `"null"` |
| **Use anchors** | Apply DRY principle with `&` and `*` for repeated blocks |
| **Validate** | Use linters (yamllint) and schema validation |
| **UTF-8 encoding** | Always use UTF-8 without BOM |
| **Meaningful keys** | Use `snake_case` or `kebab-case` consistently |
| **Limit nesting** | Keep nesting to 4 levels max for readability |
| **Blank lines** | Separate logical sections with blank lines |
| **No trailing spaces** | Remove trailing whitespace |

## Linting
```bash
# Install yamllint
pip install yamllint

# Lint YAML files
yamllint .
yamllint -d relaxed myfile.yml
yamllint -d "{extends: default, rules: {line-length: {max: 120}}}" .

# .yamllint.yml configuration
---
extends: default
rules:
  line-length:
    max: 120
    allow-non-breakable-words: true
  truthy:
    check-keys: false
  comments:
    min-spaces-from-content: 1
  indentation:
    spaces: 2
    indent-sequences: true
```

## File Naming Conventions
```
# Preferred extensions
config.yml          # .yml (most common)
config.yaml         # .yaml (also valid)

# Common file names
docker-compose.yml
.github/workflows/ci.yml
.gitlab-ci.yml
ansible/playbook.yml
k8s/deployment.yaml
openapi.yaml
.yamllint.yml
```

## Rules Integration
- **Security**: Never store secrets in YAML — use environment variables, secret managers, or encrypted vaults
- **Validation**: Always validate YAML against schemas before deployment
- **Version Control**: YAML files should be tracked in Git with proper `.gitignore` rules
- **Encoding**: Always UTF-8, never use BOM
- **Consistency**: Pick one extension (`.yml` or `.yaml`) and stick with it per project
