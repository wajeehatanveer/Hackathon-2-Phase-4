# Kubernetes Data Model: Phase IV Deployment

**Feature**: Kubernetes Cloud-Native Deployment
**Version**: 1.0.0
**Created**: 2026-02-23

---

## Overview

This document defines all Kubernetes resources required for deploying the Phase III AI Todo Chatbot to Minikube. Each entity includes YAML templates and configuration specifications.

---

## Entity 1: Deployment (Frontend)

**Purpose**: Manages Next.js frontend pods with 2+ replicas, health probes, and rolling updates.

**YAML Template**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  labels:
    app: frontend
    component: ai-todo
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ai-todo-frontend:latest
        ports:
        - containerPort: 3000
          name: http
        resources:
          requests:
            memory: "256Mi"
            cpu: "0.25"
          limits:
            memory: "512Mi"
            cpu: "0.5"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 30
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 30
        envFrom:
        - configMapRef:
            name: ai-todo-config
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          readOnlyRootFilesystem: false
```

**Key Fields**:
- `replicas: 2`: Minimum for high availability
- `maxSurge: 1, maxUnavailable: 0`: Zero-downtime rolling updates
- `resources`: CPU/memory requests and limits
- `probes`: Health checks for reliability
- `securityContext`: Non-root container

---

## Entity 2: Deployment (Backend)

**Purpose**: Manages FastAPI backend pods with 2+ replicas, health probes, and database connectivity.

**YAML Template**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  labels:
    app: backend
    component: ai-todo
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ai-todo-backend:latest
        ports:
        - containerPort: 8000
          name: http
        resources:
          requests:
            memory: "512Mi"
            cpu: "0.5"
          limits:
            memory: "1Gi"
            cpu: "1.0"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 30
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 30
        envFrom:
        - secretRef:
            name: ai-todo-secrets
        - configMapRef:
            name: ai-todo-config
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          readOnlyRootFilesystem: false
```

**Key Fields**:
- `replicas: 2`: Minimum for high availability
- `resources`: Higher memory for Python + Cohere SDK
- `envFrom.secretRef`: Mounts sensitive env vars
- `probes`: Health checks for backend API

---

## Entity 3: Service (Frontend)

**Purpose**: Provides stable network endpoint for frontend pods with ClusterIP.

**YAML Template**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  labels:
    app: frontend
spec:
  type: ClusterIP
  ports:
  - port: 3000
    targetPort: 3000
    protocol: TCP
    name: http
  selector:
    app: frontend
```

**Key Fields**:
- `type: ClusterIP`: Internal cluster access
- `port: 3000`: Standard HTTP port
- `selector`: Routes traffic to frontend pods

---

## Entity 4: Service (Backend)

**Purpose**: Provides stable network endpoint for backend pods with ClusterIP.

**YAML Template**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend
spec:
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
    name: http
  selector:
    app: backend
```

**Key Fields**:
- `type: ClusterIP`: Internal cluster access
- `port: 8000`: FastAPI default port
- `selector`: Routes traffic to backend pods

---

## Entity 5: Ingress

**Purpose**: Routes external HTTP traffic to frontend/backend based on path rules.

**YAML Template**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ai-todo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: todo.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
```

**Key Fields**:
- `host: todo.local`: Clean URL for demo
- `pathType: Prefix`: Path-based routing
- `/api` → backend, `/` → frontend: Path separation

---

## Entity 6: Secret

**Purpose**: Stores sensitive environment variables securely.

**YAML Template**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ai-todo-secrets
type: Opaque
stringData:
  BETTER_AUTH_SECRET: <random-32-char-string>
  COHERE_API_KEY: <your-cohere-api-key>
  DATABASE_URL: postgresql://<neon-connection-string>
```

**Creation Command**:
```bash
kubectl create secret generic ai-todo-secrets \
  --from-literal=BETTER_AUTH_SECRET=$(openssl rand -hex 32) \
  --from-literal=COHERE_API_KEY=<your-cohere-key> \
  --from-literal=DATABASE_URL=<neon-connection-string>
```

**Key Fields**:
- `type: Opaque`: Generic secret type
- `stringData`: Plain text values (auto base64-encoded)
- Three sensitive env vars for backend

---

## Entity 7: ConfigMap

**Purpose**: Stores non-sensitive configuration data.

**YAML Template**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ai-todo-config
data:
  NODE_ENV: production
  PYTHONUNBUFFERED: "1"
  LOG_LEVEL: info
```

**Creation Command**:
```bash
kubectl create configmap ai-todo-config \
  --from-literal=NODE_ENV=production \
  --from-literal=PYTHONUNBUFFERED=1 \
  --from-literal=LOG_LEVEL=info
```

**Key Fields**:
- `NODE_ENV: production`: Next.js production mode
- `PYTHONUNBUFFERED: "1"`: Python unbuffered output
- `LOG_LEVEL: info`: Application logging level

---

## Entity 8: HorizontalPodAutoscaler (Optional)

**Purpose**: Automatically scales replicas based on CPU/memory usage.

**YAML Template**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
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

**Key Fields**:
- `minReplicas: 2`: High availability minimum
- `maxReplicas: 10`: Scale ceiling
- `averageUtilization: 70`: Scale target

---

## Entity 9: NetworkPolicy (Optional)

**Purpose**: Restricts pod-to-pod communication for security.

**YAML Template**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ai-todo-network-policy
spec:
  podSelector:
    matchLabels:
      component: ai-todo
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # Allow ingress from ingress controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
    - protocol: TCP
      port: 8000
  # Allow frontend → backend communication
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8000
  egress:
  # Allow backend → external database (Neon)
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS resolution
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
```

**Key Fields**:
- `policyTypes`: Ingress and Egress rules
- `ingress`: Allows traffic from ingress controller + frontend
- `egress`: Allows database access + DNS

---

## Entity 10: Pod (Frontend)

**Purpose**: Smallest deployable unit containing Next.js container.

**Pod Specification** (managed by Deployment):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend-pod-example
  labels:
    app: frontend
spec:
  containers:
  - name: frontend
    image: ai-todo-frontend:latest
    ports:
    - containerPort: 3000
    resources:
      requests:
        memory: "256Mi"
        cpu: "0.25"
      limits:
        memory: "512Mi"
        cpu: "0.5"
    livenessProbe:
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 30
      periodSeconds: 30
    readinessProbe:
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 5
      periodSeconds: 10
    envFrom:
    - configMapRef:
        name: ai-todo-config
    securityContext:
      runAsNonRoot: true
      runAsUser: 1001
```

**Key Fields**:
- Single container (Next.js)
- Health probes on /health endpoint
- Non-root security context

---

## Entity 11: Pod (Backend)

**Purpose**: Smallest deployable unit containing FastAPI container.

**Pod Specification** (managed by Deployment):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod-example
  labels:
    app: backend
spec:
  containers:
  - name: backend
    image: ai-todo-backend:latest
    ports:
    - containerPort: 8000
    resources:
      requests:
        memory: "512Mi"
        cpu: "0.5"
      limits:
        memory: "1Gi"
        cpu: "1.0"
    livenessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 30
      periodSeconds: 30
    readinessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 5
      periodSeconds: 10
    envFrom:
    - secretRef:
        name: ai-todo-secrets
    - configMapRef:
        name: ai-todo-config
    securityContext:
      runAsNonRoot: true
      runAsUser: 1001
```

**Key Fields**:
- Single container (FastAPI + Cohere SDK)
- Secret-mounted environment variables
- Health probes on /health endpoint

---

## Resource Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                        Ingress                               │
│                   (todo.local)                               │
│          Routes: / → Frontend, /api → Backend                │
└───────────────┬─────────────────────┬────────────────────────┘
                │                     │
        ┌───────▼────────┐   ┌────────▼────────┐
        │   Service      │   │    Service      │
        │  (frontend)    │   │   (backend)     │
        │  ClusterIP:3000│   │  ClusterIP:8000 │
        └───────┬────────┘   └────────┬────────┘
                │                     │
        ┌───────▼────────┐   ┌────────▼────────┐
        │  Deployment    │   │   Deployment    │
        │  (replicas: 2) │   │   (replicas: 2) │
        └───────┬────────┘   └────────┬────────┘
                │                     │
        ┌───────▼────────┐   ┌────────▼────────┐
        │  Pod (Frontend)│   │  Pod (Backend)  │
        │  - Next.js     │   │  - FastAPI      │
        │  - Port 3000   │   │  - Port 8000    │
        └────────────────┘   └────────┬────────┘
                                     │
                              ┌──────▼──────────┐
                              │ Neon PostgreSQL │
                              │   (External)    │
                              └─────────────────┘
```

---

## Validation Rules

### Deployment Validation
- ✅ All deployments have 2+ replicas
- ✅ Rolling update strategy configured (maxSurge=1, maxUnavailable=0)
- ✅ All containers have resource requests and limits
- ✅ All containers have liveness, readiness, startup probes
- ✅ All containers run as non-root users

### Service Validation
- ✅ All services have ClusterIP type
- ✅ Service selectors match pod labels
- ✅ Ports match container ports

### Ingress Validation
- ✅ Ingress class set to nginx
- ✅ Host rule configured (todo.local)
- ✅ Path-based routing (/api → backend, / → frontend)

### Security Validation
- ✅ Secrets used for sensitive env vars
- ✅ ConfigMaps used for non-sensitive config
- ✅ Non-root security context on all pods
- ✅ NetworkPolicy restricts pod-to-pod traffic (optional)

---

## State Transitions

### Pod Lifecycle
```
Pending → ContainerCreating → Running → Ready
   ↓            ↓                ↓         ↓
Scheduled   Image Pull      App Start   Probes Pass
```

### Deployment Rollout
```
Old ReplicaSet (2 pods)
         ↓
New ReplicaSet created (scale up to 3 with maxSurge=1)
         ↓
New pod passes readiness probe
         ↓
Old pod terminated (maxUnavailable=0)
         ↓
New ReplicaSet (2 pods) - Rollout Complete
```

---

**All Kubernetes entities defined. Ready for Helm chart templating.**
