---
name: Red Hat OpenShift
description: Skill for Red Hat OpenShift — enterprise Kubernetes platform with container management, CI/CD, and REST/CLI API for hybrid cloud deployments.
---

# Red Hat OpenShift — Enterprise Kubernetes

## Overview
Red Hat OpenShift is an enterprise Kubernetes platform providing container management, built-in CI/CD, developer tools, and multi-cluster management for hybrid cloud.

## CLI & API
```bash
# Login
oc login https://api.cluster.example.com:6443 --token=YOUR_TOKEN

# Create app from source
oc new-app https://github.com/example/app.git

# Deploy image
oc new-app --docker-image=registry.example.com/myapp:latest

# Scale deployment
oc scale deployment/myapp --replicas=3

# Get routes
oc get routes
```

## REST API
```python
import requests
headers = {"Authorization": f"Bearer {token}"}

# List projects
projects = requests.get("https://api.cluster:6443/apis/project.openshift.io/v1/projects",
    headers=headers, verify=False)

# List pods
pods = requests.get("https://api.cluster:6443/api/v1/namespaces/myapp/pods",
    headers=headers, verify=False)
```

## Best Practices
- Use **Source-to-Image (S2I)** for simplified builds
- Implement **Operators** for lifecycle management
- Use **OpenShift GitOps** (ArgoCD) for declarative deployments
