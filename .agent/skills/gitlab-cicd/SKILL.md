---
name: GitLab CI/CD
description: Skill for GitLab CI/CD — integrated DevOps platform with pipeline configuration, container registry, REST API, and GitOps workflows.
---

# GitLab CI/CD — Integrated DevOps

## Overview
GitLab CI/CD provides integrated continuous integration and deployment directly within GitLab, with YAML-based pipeline configuration and auto-DevOps capabilities.

## .gitlab-ci.yml
```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  image: node:20
  script:
    - npm ci
    - npm run build
  artifacts:
    paths: [dist/]

test:
  stage: test
  image: node:20
  script:
    - npm ci
    - npm test
  coverage: '/Statements.*?(\d+(?:\.\d+)?)%/'

deploy-prod:
  stage: deploy
  environment: production
  when: manual
  only: [main]
  script:
    - npm run deploy
```

## REST API
```python
import requests
headers = {"PRIVATE-TOKEN": "YOUR_ACCESS_TOKEN"}

# List projects
projects = requests.get("https://gitlab.com/api/v4/projects", headers=headers)

# Trigger pipeline
requests.post(f"https://gitlab.com/api/v4/projects/{id}/pipeline",
    headers=headers, json={"ref": "main"})

# Get pipeline status
pipeline = requests.get(f"https://gitlab.com/api/v4/projects/{id}/pipelines/latest",
    headers=headers)
```

## Best Practices
- Use **include** for shared CI/CD templates
- Implement **environments** for deployment tracking
- Enable **Auto DevOps** for convention-over-configuration pipelines
