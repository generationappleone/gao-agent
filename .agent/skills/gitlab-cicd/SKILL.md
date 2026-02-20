---
name: GitLab CI/CD
description: Skill for GitLab CI/CD — integrated DevOps platform with pipeline configuration, container registry, REST API, and GitOps workflows.
---

# GitLab CI/CD Skill

## Overview
GitLab CI/CD is an integrated continuous integration and delivery platform built into GitLab. It uses `.gitlab-ci.yml` for pipeline-as-code, supports Docker-based runners, caching, artifacts, environments, and deployment with built-in container registry.

**References**:
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [.gitlab-ci.yml Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [GitLab Runner](https://docs.gitlab.com/runner/)

---

## Basic Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - install
  - quality
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "20"
  DOCKER_IMAGE: "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

default:
  image: node:${NODE_VERSION}-alpine
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
      - .npm/

# ── Install ──
install:
  stage: install
  script:
    - npm ci --cache .npm --prefer-offline
  artifacts:
    paths:
      - node_modules/
    expire_in: 1 hour

# ── Quality (parallel) ──
lint:
  stage: quality
  needs: [install]
  script:
    - npm run lint

type-check:
  stage: quality
  needs: [install]
  script:
    - npm run type-check

# ── Test ──
test:
  stage: test
  needs: [install]
  services:
    - postgres:16
    - redis:7
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test
    DATABASE_URL: "postgresql://test:test@postgres:5432/testdb"
    REDIS_URL: "redis://redis:6379"
  script:
    - npm run db:migrate
    - npm run test:ci
  artifacts:
    when: always
    reports:
      junit: test-results/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
  coverage: /All files[^|]*\|[^|]*\s+([\d\.]+)/

# ── Build ──
build:
  stage: build
  needs: [lint, type-check, test]
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 day

# ── Docker Build & Push ──
docker:
  stage: build
  needs: [lint, type-check, test]
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $DOCKER_IMAGE -t $CI_REGISTRY_IMAGE:latest .
    - docker push $DOCKER_IMAGE
    - docker push $CI_REGISTRY_IMAGE:latest
  rules:
    - if: $CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH == "staging"

# ── Deploy Staging ──
deploy-staging:
  stage: deploy
  needs: [docker]
  environment:
    name: staging
    url: https://staging.myapp.com
  script:
    - apt-get update && apt-get install -y curl
    - |
      curl -X POST "$STAGING_DEPLOY_URL" \
        -H "Authorization: Bearer $STAGING_DEPLOY_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"image\": \"$DOCKER_IMAGE\"}"
  rules:
    - if: $CI_COMMIT_BRANCH == "staging"

# ── Deploy Production ──
deploy-production:
  stage: deploy
  needs: [docker]
  environment:
    name: production
    url: https://api.myapp.com
  script:
    - |
      curl -X POST "$PROD_DEPLOY_URL" \
        -H "Authorization: Bearer $PROD_DEPLOY_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"image\": \"$DOCKER_IMAGE\"}"
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual                  # Manual approval for production
  allow_failure: false
```

---

## Advanced Features

### Templates & Includes
```yaml
# .gitlab-ci.yml
include:
  - local: .gitlab/ci/test.yml
  - local: .gitlab/ci/deploy.yml
  - template: Jobs/SAST.gitlab-ci.yml     # Built-in security scanning
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

# Re-usable job template
.node-base:
  image: node:20-alpine
  before_script:
    - npm ci --cache .npm --prefer-offline
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths: [node_modules/, .npm/]

test:
  extends: .node-base
  stage: test
  script: npm test
```

### Rules & Conditions
```yaml
build:
  script: npm run build
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"     # MR only
    - if: $CI_COMMIT_BRANCH == "main"                       # main branch
    - if: $CI_COMMIT_TAG                                    # Tags
      variables:
        DEPLOY_ENV: production
    - changes:                                               # Only if files changed
        - src/**/*
        - package.json
```

### Environments & Review Apps
```yaml
deploy-review:
  stage: deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.review.myapp.com
    on_stop: stop-review
    auto_stop_in: 1 week
  script:
    - deploy-review-app.sh $CI_COMMIT_REF_SLUG
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

stop-review:
  stage: deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  when: manual
  script:
    - teardown-review-app.sh $CI_COMMIT_REF_SLUG
```

### Secrets & Variables
```yaml
# CI/CD Settings → Variables:
# DEPLOY_TOKEN (masked, protected)
# DATABASE_URL (masked, protected, environment: production)

deploy:
  script:
    # Access as environment variables
    - echo "Deploying with token: $DEPLOY_TOKEN"
    # Vault integration
    - export SECRET=$(vault kv get -field=api_key secret/myapp)
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **`needs`** | Use `needs:` for DAG pipelines (skip stage ordering) |
| **Cache** | Cache `node_modules/` keyed by branch slug |
| **Artifacts** | Share build output between stages, set expiry |
| **Services** | Database containers as `services:` for integration tests |
| **Templates** | `.job-template` with `extends:` for DRY pipelines |
| **Rules** | `rules:` over `only/except` (modern, more flexible) |
| **Environments** | Track deployments with `environment:` |
| **Review apps** | Auto-deploy MR branches, auto-stop after 1 week |
| **Protected variables** | Mask sensitive values, restrict to protected branches |
| **Security scanning** | Include SAST/dependency scanning templates |

---

## Rules Integration
- **Pipeline**: `.gitlab-ci.yml` stages, parallel jobs with `needs:`, `rules:` conditions
- **Docker**: Built-in container registry, DinD for builds
- **Security**: Protected/masked variables, SAST templates, dependency scanning
- **Environments**: Staging/production with manual approval, review apps per MR
- **Caching**: npm cache keyed by branch, artifacts between stages
