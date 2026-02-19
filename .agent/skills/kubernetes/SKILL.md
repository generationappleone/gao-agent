---
name: Kubernetes
description: Skill for deploying and managing containerized applications with Kubernetes, covering pods, deployments, services, ingress, ConfigMaps, secrets, autoscaling, and production patterns.
---

# Kubernetes (K8s) Skill

## Overview
Kubernetes orchestrates containerized applications at scale. This skill covers core resources, deployment strategies, security, monitoring, and production-ready configurations.

## Core Concepts
```
Cluster
├── Nodes (machines)
│   ├── Pods (smallest deployable unit)
│   │   └── Containers (Docker images)
│   ├── Services (networking)
│   └── Volumes (storage)
├── Namespaces (logical isolation)
├── ConfigMaps & Secrets (configuration)
└── Ingress (external access)
```

## Namespace
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  labels:
    app: myapp
    environment: production
```

## Deployment
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-api
  namespace: myapp
  labels:
    app: myapp-api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapp-api
  template:
    metadata:
      labels:
        app: myapp-api
        version: v1.2.0
    spec:
      serviceAccountName: myapp-api
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
        - name: api
          image: registry.example.com/myapp-api:1.2.0  # Pinned tag
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3000
              protocol: TCP
          env:
            - name: NODE_ENV
              value: "production"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database-url
            - name: REDIS_URL
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: redis-url
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
            periodSeconds: 20
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: myapp-api
                topologyKey: kubernetes.io/hostname
```

## Service
```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-api
  namespace: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp-api
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
```

## Ingress (External Access)
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: myapp
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.myapp.com
      secretName: myapp-tls
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-api
                port:
                  number: 80
```

## ConfigMap & Secrets
```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: myapp
data:
  redis-url: "redis://redis-svc:6379"
  log-level: "info"
  max-workers: "4"

---
# secret.yaml (values are base64 encoded)
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
  namespace: myapp
type: Opaque
data:
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0BkYjo1NDMyL215YXBw
  jwt-secret: c3VwZXJfc2VjcmV0X2tleV9oZXJl
```

## Horizontal Pod Autoscaler
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-api-hpa
  namespace: myapp
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
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## NetworkPolicy (Security)
```yaml
# networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-api-netpol
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: myapp-api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - port: 5432
    - to:
        - podSelector:
            matchLabels:
              app: redis
      ports:
        - port: 6379
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - port: 53
          protocol: UDP
```

## Essential Commands
```bash
# Context & namespace
kubectl config use-context production
kubectl config set-context --current --namespace=myapp

# Apply manifests
kubectl apply -f k8s/                         # Apply all in directory
kubectl apply -f deployment.yaml

# View resources
kubectl get pods -n myapp -o wide
kubectl get svc,deploy,ing -n myapp
kubectl describe pod <pod-name> -n myapp
kubectl top pods -n myapp                     # Resource usage

# Logs
kubectl logs -f <pod-name> -n myapp           # Follow logs
kubectl logs <pod-name> --previous            # Previous crash logs

# Debug
kubectl exec -it <pod-name> -n myapp -- sh    # Shell into pod
kubectl port-forward svc/myapp-api 3000:80    # Local port forward

# Rollout
kubectl rollout status deploy/myapp-api
kubectl rollout undo deploy/myapp-api         # Rollback
kubectl rollout history deploy/myapp-api      # History

# Scale
kubectl scale deploy/myapp-api --replicas=5
```

## Rules Integration
- **Security**: Non-root, read-only FS, drop capabilities, NetworkPolicy, secrets management
- **ISO 27017**: Namespace isolation, RBAC, audit logging, network segmentation
- **Docker**: Kubernetes deploys Docker images — use multi-stage secure Dockerfiles
