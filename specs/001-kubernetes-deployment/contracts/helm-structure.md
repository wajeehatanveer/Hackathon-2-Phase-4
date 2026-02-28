# Helm Chart Structure Contract: AI Todo Chatbot

**Feature**: Kubernetes Cloud-Native Deployment
**Version**: 1.0.0
**Created**: 2026-02-23

---

## Overview

This document defines the Helm chart structure for the AI Todo Chatbot deployment. The chart follows the umbrella pattern with subcharts for frontend, backend, and database components.

---

## Chart Directory Structure

```
infra/helm/ai-todo/
├── Chart.yaml                    # Umbrella chart metadata
├── values.yaml                   # Global configuration values
├── Chart.lock                    # Locked dependency versions (auto-generated)
├── charts/                       # Subchart directory
│   ├── frontend/                 # Next.js frontend subchart
│   │   ├── Chart.yaml            # Frontend chart metadata
│   │   ├── values.yaml           # Frontend-specific values
│   │   └── templates/            # Frontend Kubernetes templates
│   │       ├── deployment.yaml   # Frontend Deployment
│   │       ├── service.yaml      # Frontend Service
│   │       ├── ingress.yaml      # Frontend Ingress (optional)
│   │       ├── configmap.yaml    # Frontend ConfigMap
│   │       ├── hpa.yaml          # Frontend HorizontalPodAutoscaler
│   │       └── _helpers.tpl      # Frontend template helpers
│   ├── backend/                  # FastAPI backend subchart
│   │   ├── Chart.yaml            # Backend chart metadata
│   │   ├── values.yaml           # Backend-specific values
│   │   └── templates/            # Backend Kubernetes templates
│   │       ├── deployment.yaml   # Backend Deployment
│   │       ├── service.yaml      # Backend Service
│   │       ├── configmap.yaml    # Backend ConfigMap
│   │       ├── hpa.yaml          # Backend HorizontalPodAutoscaler
│   │       └── _helpers.tpl      # Backend template helpers
│   └── database/                 # Database subchart (external reference)
│       ├── Chart.yaml            # Database chart metadata (empty)
│       └── README.md             # Note: Using external Neon PostgreSQL
└── templates/                    # Umbrella chart templates
    ├── _helpers.tpl              # Shared template helpers
    ├── secrets.yaml              # Kubernetes Secret for env vars
    └── network-policy.yaml       # NetworkPolicy for pod security
```

---

## Chart.yaml (Umbrella)

```yaml
apiVersion: v2
name: ai-todo
description: AI Todo Chatbot - Full-stack Kubernetes deployment with Next.js frontend, FastAPI backend, and Cohere AI integration
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - todo
  - chatbot
  - ai
  - nextjs
  - fastapi
  - cohere
maintainers:
  - name: Hackathon Team
    email: team@example.com
dependencies:
  - name: frontend
    version: 0.1.0
    repository: "file://charts/frontend"
    condition: frontend.enabled
  - name: backend
    version: 0.1.0
    repository: "file://charts/backend"
    condition: backend.enabled
  - name: database
    version: 0.1.0
    repository: "file://charts/database"
    condition: database.enabled
```

**Key Fields**:
- `apiVersion: v2`: Helm 3 chart format
- `version: 0.1.0`: Chart version (semantic versioning)
- `appVersion: "1.0.0"`: Application version
- `dependencies`: Subchart references

---

## values.yaml (Umbrella)

```yaml
# Global configuration applied to all subcharts
global:
  imageRegistry: ""  # Empty = use local images
  imagePullPolicy: IfNotPresent
  storageClass: ""

# Component enable flags
frontend:
  enabled: true
  replicas: 2
  image:
    repository: ai-todo-frontend
    tag: latest
  resources:
    requests:
      memory: "256Mi"
      cpu: "0.25"
    limits:
      memory: "512Mi"
      cpu: "0.5"
  service:
    type: ClusterIP
    port: 3000
  ingress:
    enabled: true
    host: todo.local
  probes:
    liveness:
      path: /health
      initialDelaySeconds: 30
      periodSeconds: 30
    readiness:
      path: /health
      initialDelaySeconds: 5
      periodSeconds: 10
    startup:
      path: /health
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30

backend:
  enabled: true
  replicas: 2
  image:
    repository: ai-todo-backend
    tag: latest
  resources:
    requests:
      memory: "512Mi"
      cpu: "0.5"
    limits:
      memory: "1Gi"
      cpu: "1.0"
  service:
    type: ClusterIP
    port: 8000
  probes:
    liveness:
      path: /health
      initialDelaySeconds: 30
      periodSeconds: 30
    readiness:
      path: /health
      initialDelaySeconds: 5
      periodSeconds: 10
    startup:
      path: /health
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30
  secrets:
    betterAuthSecret: ""  # Populated from Kubernetes Secret
    cohereApiKey: ""      # Populated from Kubernetes Secret
    databaseUrl: ""       # Populated from Kubernetes Secret

database:
  enabled: false  # Using external Neon PostgreSQL

# Ingress configuration
ingress:
  enabled: true
  className: nginx
  host: todo.local
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  paths:
    - path: /api
      pathType: Prefix
      backend:
        service: backend-service
        port: 8000
    - path: /
      pathType: Prefix
      backend:
        service: frontend-service
        port: 3000

# Security configuration
security:
  networkPolicy:
    enabled: true
    denyAllByDefault: true
    allowIngressFrom:
      - namespace: ingress-nginx
    allowEgressTo:
      - cidr: 0.0.0.0/0
        ports:
          - 5432  # PostgreSQL
          - 53    # DNS
```

---

## Subchart: frontend/Chart.yaml

```yaml
apiVersion: v2
name: frontend
description: Next.js Frontend for AI Todo Chatbot
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - nextjs
  - react
  - frontend
maintainers:
  - name: Hackathon Team
    email: team@example.com
```

---

## Subchart: frontend/values.yaml

```yaml
# Frontend-specific values
replicas: 2

image:
  repository: ai-todo-frontend
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 3000
  targetPort: 3000

resources:
  requests:
    memory: "256Mi"
    cpu: "0.25"
  limits:
    memory: "512Mi"
    cpu: "0.5"

probes:
  liveness:
    httpGet:
      path: /health
      port: 3000
    initialDelaySeconds: 30
    periodSeconds: 30
    failureThreshold: 3
  readiness:
    httpGet:
      path: /health
      port: 3000
    initialDelaySeconds: 5
    periodSeconds: 10
    failureThreshold: 3
  startup:
    httpGet:
      path: /health
      port: 3000
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 30

securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  readOnlyRootFilesystem: false

configMap:
  NODE_ENV: production
  LOG_LEVEL: info
```

---

## Subchart: backend/Chart.yaml

```yaml
apiVersion: v2
name: backend
description: FastAPI Backend for AI Todo Chatbot with Cohere Integration
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - fastapi
  - python
  - backend
  - cohere
  - ai
maintainers:
  - name: Hackathon Team
    email: team@example.com
```

---

## Subchart: backend/values.yaml

```yaml
# Backend-specific values
replicas: 2

image:
  repository: ai-todo-backend
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8000
  targetPort: 8000

resources:
  requests:
    memory: "512Mi"
    cpu: "0.5"
  limits:
    memory: "1Gi"
    cpu: "1.0"

probes:
  liveness:
    httpGet:
      path: /health
      port: 8000
    initialDelaySeconds: 30
    periodSeconds: 30
    failureThreshold: 3
  readiness:
    httpGet:
      path: /health
      port: 8000
    initialDelaySeconds: 5
    periodSeconds: 10
    failureThreshold: 3
  startup:
    httpGet:
      path: /health
      port: 8000
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 30

securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  readOnlyRootFilesystem: false

secrets:
  betterAuthSecret: ""
  cohereApiKey: ""
  databaseUrl: ""

configMap:
  PYTHONUNBUFFERED: "1"
  LOG_LEVEL: info
```

---

## Template: secrets.yaml (Umbrella)

```yaml
{{- if .Values.secrets }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secrets
  labels:
    app: {{ .Chart.Name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    release: {{ .Release.Name }}
type: Opaque
stringData:
  {{- range $key, $value := .Values.secrets }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
```

---

## Template: network-policy.yaml (Umbrella)

```yaml
{{- if .Values.security.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ .Release.Name }}-network-policy
  labels:
    app: {{ .Chart.Name }}
spec:
  podSelector:
    matchLabels:
      app: {{ .Chart.Name }}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    {{- if .Values.security.networkPolicy.denyAllByDefault }}
    # Allow only specified ingress
    {{- end }}
    - from:
      - namespaceSelector:
          matchLabels:
            name: ingress-nginx
      ports:
      - protocol: TCP
        port: 3000
      - protocol: TCP
        port: 8000
    # Allow frontend → backend
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
      - protocol: TCP
        port: 8000
  egress:
    # Allow external database access
    - to:
      - ipBlock:
          cidr: {{ .Values.security.networkPolicy.allowEgressTo[0].cidr }}
          except:
          - 10.0.0.0/8
          - 172.16.0.0/12
          - 192.168.0.0/16
      ports:
      - protocol: TCP
        port: 5432
    # Allow DNS
    - to:
      - namespaceSelector: {}
      ports:
      - protocol: UDP
        port: 53
{{- end }}
```

---

## Values Schema

### Global Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `global.imageRegistry` | string | `""` | Docker registry for all images |
| `global.imagePullPolicy` | string | `IfNotPresent` | Image pull policy |
| `global.storageClass` | string | `""` | Default storage class |

### Frontend Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `frontend.enabled` | bool | `true` | Enable frontend deployment |
| `frontend.replicas` | int | `2` | Number of frontend replicas |
| `frontend.image.repository` | string | `ai-todo-frontend` | Frontend image name |
| `frontend.image.tag` | string | `latest` | Frontend image tag |
| `frontend.resources.requests.memory` | string | `256Mi` | Memory request |
| `frontend.resources.requests.cpu` | string | `0.25` | CPU request |
| `frontend.resources.limits.memory` | string | `512Mi` | Memory limit |
| `frontend.resources.limits.cpu` | string | `0.5` | CPU limit |

### Backend Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `backend.enabled` | bool | `true` | Enable backend deployment |
| `backend.replicas` | int | `2` | Number of backend replicas |
| `backend.image.repository` | string | `ai-todo-backend` | Backend image name |
| `backend.image.tag` | string | `latest` | Backend image tag |
| `backend.resources.requests.memory` | string | `512Mi` | Memory request |
| `backend.resources.requests.cpu` | string | `0.5` | CPU request |
| `backend.resources.limits.memory` | string | `1Gi` | Memory limit |
| `backend.resources.limits.cpu` | string | `1.0` | CPU limit |

### Ingress Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `ingress.enabled` | bool | `true` | Enable ingress |
| `ingress.className` | string | `nginx` | Ingress class |
| `ingress.host` | string | `todo.local` | Ingress hostname |
| `ingress.paths` | list | `[...]` | Path-based routing rules |

### Security Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `security.networkPolicy.enabled` | bool | `true` | Enable NetworkPolicy |
| `security.networkPolicy.denyAllByDefault` | bool | `true` | Deny all by default |
| `security.networkPolicy.allowEgressTo` | list | `[...]` | Allowed egress destinations |

---

## Validation Commands

### Lint Chart

```bash
helm lint ./infra/helm/ai-todo
```

**Expected Output**:
```
==> Linting ./infra/helm/ai-todo
1 chart(s) linted, 0 chart(s) failed
```

### Build Dependencies

```bash
cd infra/helm/ai-todo
helm dependency build
```

**Expected Output**:
```
Saving 3 charts
Deleting outdated charts
Building dependency...
```

### Template Rendering

```bash
helm template ai-todo ./infra/helm/ai-todo --debug
```

**Expected Output**: All Kubernetes resources rendered as YAML

### Dry-Run Install

```bash
helm install ai-todo ./infra/helm/ai-todo --dry-run
```

**Expected Output**: Installation simulation with validation

---

## Chart Versioning Strategy

### Semantic Versioning

- **MAJOR** (X.0.0): Breaking changes (removed values, incompatible schema)
- **MINOR** (0.X.0): New features (new values, new templates)
- **PATCH** (0.0.X): Bug fixes (typo corrections, template fixes)

### Version Bump Triggers

| Change Type | Version Impact | Example |
|-------------|----------------|---------|
| Remove value | MAJOR | `frontend.replicas` removed |
| Add value | MINOR | `backend.autoscaling` added |
| Change default | MINOR | `frontend.replicas` default 2→3 |
| Fix template bug | PATCH | Ingress path typo corrected |
| Update app version | PATCH | appVersion 1.0.0→1.0.1 |

---

**Helm chart structure defined. Ready for chart generation via helm-chart-architect agent.**
