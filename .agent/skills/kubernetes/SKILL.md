---
name: Kubernetes
description: Skill for deploying and managing containerized applications with Kubernetes, covering pods, deployments, services, ingress, ConfigMaps, secrets, autoscaling, and production patterns.
---

# Kubernetes Skill

## Overview
Kubernetes (K8s) is the standard container orchestration platform. It manages containerized applications across clusters providing deployments, services, ingress, ConfigMaps, secrets, horizontal pod autoscaling, and rolling updates. kubectl is the primary CLI tool.

**References**:
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)

---

## Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-api
  labels:
    app: myapp-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp-api
  template:
    metadata:
      labels:
        app: myapp-api
    spec:
      containers:
        - name: api
          image: myapp/api:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: production
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database-url
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits: { cpu: 500m, memory: 512Mi }
          readinessProbe:
            httpGet: { path: /health, port: 3000 }
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet: { path: /health, port: 3000 }
            initialDelaySeconds: 15
            periodSeconds: 20
      imagePullSecrets:
        - name: registry-credentials
```

---

## Service & Ingress

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-api-svc
spec:
  selector:
    app: myapp-api
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP
---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  ingressClassName: nginx
  tls:
    - hosts: [api.myapp.com]
      secretName: myapp-tls
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-api-svc
                port: { number: 80 }
```

---

## ConfigMap & Secrets

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  APP_NAME: MyApp
  LOG_LEVEL: info
  CORS_ORIGINS: https://myapp.com
---
# k8s/secrets.yaml (apply with kubectl create secret)
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  database-url: postgresql://user:pass@host:5432/myapp
  jwt-secret: your-jwt-secret
  redis-url: redis://redis:6379
```

---

## HPA (Autoscaling)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target: { type: Utilization, averageUtilization: 70 }
    - type: Resource
      resource:
        name: memory
        target: { type: Utilization, averageUtilization: 80 }
```

---

## Commands

```bash
# Apply
kubectl apply -f k8s/

# Status
kubectl get pods,svc,ingress
kubectl describe deployment myapp-api
kubectl logs -f deployment/myapp-api

# Scaling
kubectl scale deployment myapp-api --replicas=5

# Rolling update
kubectl set image deployment/myapp-api api=myapp/api:v2

# Rollback
kubectl rollout undo deployment/myapp-api
kubectl rollout status deployment/myapp-api
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Probes** | Readiness + liveness probes on /health |
| **Resources** | Set requests and limits for CPU/memory |
| **Secrets** | Use Kubernetes secrets, never hardcode |
| **HPA** | Autoscale based on CPU/memory metrics |
| **Rolling updates** | Zero-downtime deployments by default |
| **Namespaces** | Separate environments (dev, staging, prod) |
| **Ingress** | TLS termination with cert-manager |
| **Labels** | Consistent labels for selection/monitoring |
| **Image tags** | Use specific tags, not `:latest` in production |
| **RBAC** | ServiceAccounts with minimal permissions |

---

## Rules Integration
- **Deployment**: Replicas, probes, resources, env from secrets
- **Networking**: Service (ClusterIP) + Ingress with TLS
- **Config**: ConfigMap for settings, Secrets for credentials
- **Scaling**: HPA with CPU/memory targets
- **Operations**: Rolling updates, rollbacks, monitoring
