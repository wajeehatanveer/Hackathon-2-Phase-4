# Implementation Plan: Kubernetes Cloud-Native Deployment

**Branch**: `001-kubernetes-deployment` | **Date**: 2026-02-23 | **Spec**: [specs/001-kubernetes-deployment/spec.md](spec.md)

## Summary

Deploy the Phase III AI Todo Chatbot (Next.js frontend + FastAPI backend + Cohere integration + Neon PostgreSQL) to a local Minikube Kubernetes cluster using Helm charts and AI-powered DevOps tools. The deployment achieves production-grade characteristics: zero-downtime rolling updates, self-healing pod recovery, horizontal scaling, ingress-based access via clean URLs, and comprehensive observability—all generated via AI agents (Gordon, helm-chart-architect, kubecti-ai, kagent) with zero manual YAML authoring.

## Technical Context

**Language/Version**: TypeScript 5.x (Next.js 14.2+ App Router), Python 3.11 (FastAPI 0.104.1)
**Primary Dependencies**: React 18, Tailwind CSS, SQLModel 0.0.16, Cohere SDK 5.10.0, Better Auth JWT, PyJWT 2.8.0
**Storage**: Neon PostgreSQL (external managed database), Kubernetes Secrets for sensitive configuration
**Testing**: pytest (backend unit/integration), Jest (frontend component), contract tests (MCP tool validation)
**Target Platform**: Minikube v1.32+ (Docker driver), Helm v3.14+, kubectl v1.29+
**Project Type**: Full-stack web application with AI chatbot interface
**Performance Goals**: Cold start <30s, chatbot response <3s (excluding AI latency), p95 latency <500ms, pod recovery <60s
**Constraints**: Local Minikube only, AI-generated infrastructure mandatory, no manual YAML, HTTP-only for local demo
**Scale/Scope**: 2+ replicas per deployment, zero-downtime updates, self-healing, horizontal scaling to 4+ replicas

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Compliance Strategy |
|-----------|-------------|---------------------|
| **X. Containerization Excellence** | Multi-stage Dockerfiles, non-root, HEALTHCHECK | Gordon AI generates optimized Dockerfiles with security best practices |
| **XI. Helm-First Infrastructure** | Umbrella chart + subcharts, no raw kubectl | helm-chart-architect generates ai-todo umbrella with frontend/backend subcharts |
| **XII. Local Kubernetes Native** | Minikube docker driver, ingress addon | Minikube start with `--driver=docker --addons=ingress`, tunnel + host alias access |
| **XIII. AI-Powered DevOps** | Gordon, kubecti-ai, kagent mandatory | All Dockerfiles, charts, kubectl commands AI-generated; kagent monitors health |
| **XIV. Production-Grade Observability** | Logs, metrics, probes, events | Liveness/readiness probes on all containers, structured logging with correlation IDs |
| **XV. Security & Secrets** | Kubernetes Secrets, non-root, resource limits | k8s-security-specialist generates Secret manifests; pods run as non-root with limits |

**Gate Status**: ✅ ALL GATES PASSABLE - No constitutional violations anticipated.

## Project Structure

### Documentation (this feature)

```text
specs/001-kubernetes-deployment/
├── plan.md              # This file (implementation plan)
├── spec.md              # Feature specification (5 user stories, 18 FRs, 10 SCs)
├── research.md          # Phase 0 output (research findings on AI tools, Minikube, Helm)
├── data-model.md        # Phase 1 output (Kubernetes entities: Deployment, Service, Ingress, etc.)
├── quickstart.md        # Phase 1 output (Minikube start → Helm install → Access app flow)
├── contracts/           # Phase 1 output (Helm chart structure, values.yaml schema, resource contracts)
└── tasks.md             # Phase 2 output (testable tasks with acceptance criteria)
```

### Source Code (repository root)

```text
project-root/
├── docker/                          # NEW - Docker configurations (Gordon AI-generated)
│   ├── frontend/
│   │   ├── Dockerfile               # Multi-stage: build + runtime
│   │   └── .dockerignore
│   └── backend/
│       ├── Dockerfile               # Multi-stage: deps + runtime
│       └── .dockerignore
├── infra/                           # NEW - Infrastructure as Code
│   ├── helm/
│   │   └── ai-todo/                 # helm-chart-architect generated umbrella chart
│   │       ├── Chart.yaml           # Umbrella metadata (version 0.1.0)
│   │       ├── values.yaml          # Global configuration (replicas, resources, secrets)
│   │       ├── charts/
│   │       │   ├── frontend/        # Next.js subchart
│   │       │   │   ├── Chart.yaml
│   │       │   │   ├── values.yaml
│   │       │   │   └── templates/
│   │       │   │       ├── deployment.yaml
│   │       │   │       ├── service.yaml
│   │       │   │       ├── ingress.yaml
│   │       │   │       ├── configmap.yaml
│   │       │   │       └── hpa.yaml
│   │       │   ├── backend/         # FastAPI subchart
│   │       │   │   ├── Chart.yaml
│   │       │   │   ├── values.yaml
│   │       │   │   └── templates/
│   │       │   │       ├── deployment.yaml
│   │       │   │       ├── service.yaml
│   │       │   │       ├── configmap.yaml
│   │       │   │       └── hpa.yaml
│   │       │   └── database/        # External reference (Neon PostgreSQL)
│   │       │       └── Chart.yaml   # Empty chart with README noting external DB
│   │       └── templates/
│   │           ├── _helpers.tpl     # Shared template helpers
│   │           ├── secrets.yaml     # Kubernetes Secret for env vars
│   │           └── network-policy.yaml
│   └── k8s/
│       ├── secrets.yaml             # k8s-security-specialist generated (template)
│       └── network-policy.yaml      # Pod-to-pod traffic restrictions
├── backend/                         # EXISTING - Phase III FastAPI application
│   ├── src/
│   │   ├── api/
│   │   ├── models/
│   │   ├── services/
│   │   └── mcp/
│   ├── main.py
│   ├── db.py
│   └── requirements.txt
├── frontend/                        # EXISTING - Phase III Next.js application
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   ├── services/
│   │   └── lib/
│   ├── package.json
│   └── next.config.js
├── .specify/
│   └── memory/
│       └── constitution.md          # v4.0.0 with Phase IV principles
└── specs/
    └── 001-kubernetes-deployment/   # Phase IV specifications
```

**Structure Decision**: Web application structure (Option 2) with NEW infrastructure directories (`docker/`, `infra/`) for Phase IV Kubernetes deployment. Existing `backend/` and `frontend/` directories remain unchanged at application layer.

## Key Architectural Decisions

### Decision 1: Docker Strategy - Gordon-First AI Generation

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Primary Method** | Gordon Docker AI Agent | Encodes best practices automatically; reduces human error |
| **Fallback** | Multi-stage best practices | Manual authoring only if Gordon unavailable |
| **Base Images** | `node:18-alpine` (frontend), `python:3.11-slim` (backend) | Minimal attack surface, fast pull times |
| **Build Strategy** | Multi-stage: build layer → runtime layer | Reduces final image size by 60-80% |
| **Security** | Non-root user, no secrets in image, HEALTHCHECK | Constitution Principle X compliance |

**Dockerfile Frontend Pattern**:
```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:18-alpine AS runner
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
USER nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
```

**Dockerfile Backend Pattern**:
```dockerfile
# Stage 1: Dependencies
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim AS runner
WORKDIR /app
RUN useradd --create-home --uid 1001 appuser
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

### Decision 2: Helm Generation - kubectl-ai Initial + kagent Optimization

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Chart Generator** | helm-chart-architect agent | Produces production-grade charts with subcharts |
| **Initial Commands** | kubectl-ai for resource scaffolding | Natural language → Kubernetes resources |
| **Optimization** | kagent autonomous loops | Continuous health monitoring and recommendations |
| **Chart Type** | Umbrella chart with subcharts | Coordinated releases, environment parameterization |
| **Values Strategy** | Single values.yaml with environment overrides | DRY principle, clear configuration hierarchy |

**Helm Umbrella Chart Structure**:
```yaml
# infra/helm/ai-todo/Chart.yaml
apiVersion: v2
name: ai-todo
description: AI Todo Chatbot - Full-stack Kubernetes deployment
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: frontend
    version: 0.1.0
    repository: "file://charts/frontend"
  - name: backend
    version: 0.1.0
    repository: "file://charts/backend"
  - name: database
    version: 0.1.0
    repository: "file://charts/database"
```

### Decision 3: Minikube Configuration - Docker Driver with Ingress

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Driver** | `docker` | Uses Docker Desktop daemon; fastest local option |
| **Resources** | `--cpus=4 --memory=8192` | Sufficient for 2+ replicas of each component |
| **Addons** | `ingress` (required), `metrics-server` (recommended) | Ingress for production-like routing; metrics for observability |
| **Access Method** | `minikube tunnel` + host alias | Clean URL (todo.local) without port-forward complexity |
| **DNS** | Host file entry: `127.0.0.1 todo.local` | Simple, reliable local DNS resolution |

**Minikube Start Command**:
```bash
minikube start --driver=docker --cpus=4 --memory=8192 --addons=ingress,metrics-server
```

**Host Alias Configuration**:
```bash
# Windows (PowerShell as Administrator)
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1 todo.local"

# Linux/macOS
echo "127.0.0.1 todo.local" | sudo tee -a /etc/hosts
```

### Decision 4: Access Strategy - Ingress + Tunnel + Host Alias

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Primary Access** | Kubernetes Ingress (Nginx) | Production-like routing; path-based rules |
| **LoadBalancer** | `minikube tunnel` | Provides external IP for Ingress controller |
| **URL** | `http://todo.local` | Clean, memorable URL for demo |
| **Fallback** | `kubectl port-forward` | If tunnel unavailable (not preferred) |
| **Routing** | `/` → frontend, `/api` → backend | Path-based routing to appropriate services |

**Ingress Configuration**:
```yaml
# infra/helm/ai-todo/charts/frontend/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ai-todo-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
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

### Decision 5: Secrets Management - Single Shared Secret

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Secret Name** | `ai-todo-secrets` | Single secret for all sensitive env vars |
| **Creation Method** | `kubectl create secret` + Helm template | Manual creation for values; Helm for mounting |
| **Mounting** | `envFrom.secretRef` in Deployment | Clean injection as environment variables |
| **Secrets** | `BETTER_AUTH_SECRET`, `COHERE_API_KEY`, `DATABASE_URL` | All sensitive configuration |
| **Rotation** | Update secret + `kubectl rollout restart` | Zero-downtime secret rotation |

**Secret Creation Command**:
```bash
kubectl create secret generic ai-todo-secrets \
  --from-literal=BETTER_AUTH_SECRET=$(openssl rand -hex 32) \
  --from-literal=COHERE_API_KEY=<your-cohere-key> \
  --from-literal=DATABASE_URL=postgresql://<neon-connection-string>
```

### Decision 6: Health Probes - Full Startup/Liveness/Readiness Combo

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Startup Probe** | HTTP GET /health, initialDelay=10s, period=10s, failureThreshold=30 | Allows slow-starting containers up to 5 minutes |
| **Liveness Probe** | HTTP GET /health, initialDelay=30s, period=30s, failureThreshold=3 | Detects deadlocks; restarts unhealthy pods |
| **Readiness Probe** | HTTP GET /health, initialDelay=5s, period=10s, failureThreshold=3 | Prevents traffic to unready pods |
| **Endpoint** | `/health` (backend), `/health` (frontend) | Consistent health check path |

**Probe Configuration**:
```yaml
# Deployment template probes
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
```

### Decision 7: Resource Allocation - Realistic with kagent Optimization

| Component | Requests | Limits | Rationale |
|-----------|----------|--------|-----------|
| **Frontend** | 256Mi RAM, 0.25 CPU | 512Mi RAM, 0.5 CPU | Next.js SSR is lightweight |
| **Backend** | 512Mi RAM, 0.5 CPU | 1Gi RAM, 1.0 CPU | FastAPI + Cohere SDK needs memory |
| **Replicas** | 2 (minimum) | 4 (scale target) | High availability + demo scaling |

**Resource Configuration**:
```yaml
# Deployment template resources
resources:
  requests:
    memory: "512Mi"
    cpu: "0.5"
  limits:
    memory: "1Gi"
    cpu: "1.0"
```

## Data Flow Architecture

### Request Flow (User → Frontend → Backend → Database)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │────▶│   Ingress   │────▶│  Frontend   │────▶│   Backend   │
│  (todo.     │     │  (Nginx)    │     │  (Next.js)  │     │  (FastAPI)  │
│   local)    │     │             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                   │
                                                                   │ JWT + API Call
                                                                   ▼
                                                           ┌─────────────┐
                                                           │    Neon     │
                                                           │ PostgreSQL  │
                                                           │  (External) │
                                                           └─────────────┘
```

### Authentication Flow (JWT-based with Better Auth)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │────▶│   Auth      │────▶│   Backend   │
│  (Login)    │     │   Endpoint  │     │  (Validate) │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
                           │                   │
                           │ JWT Token         │ Extract user_id
                           ▼                   ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   Browser   │     │  Database   │
                    │  (Storage)  │     │  (Query by  │
                    │             │     │   user_id)  │
                    └─────────────┘     └─────────────┘
```

### Chatbot Conversation Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │────▶│   Frontend  │────▶│   Backend   │────▶│   Cohere    │
│  (Message)  │     │  (Chat UI)  │     │  (/api/chat)│     │     API     │
└─────────────┘     └─────────────┘     └──────┬──────┘     └──────┬──────┘
                                               │                   │
                                               │ Tool Call         │ AI Response
                                               ▼                   ▼
                                        ┌─────────────┐     ┌─────────────┐
                                        │    Neon     │     │   Backend   │
                                        │ PostgreSQL  │     │  (Parse +   │
                                        │  (Save Msg) │     │  Respond)   │
                                        └─────────────┘     └─────────────┘
```

## Phase 0: Research Topics

### Research Topic 1: Gordon Docker AI Agent Availability and Prompt Patterns

**Status**: Requires verification
**Key Questions**:
- Is Gordon Docker AI Agent available as VS Code extension or CLI?
- What prompt patterns produce optimal Dockerfiles?
- Does Gordon support multi-stage build generation?

**Expected Output**: Gordon-generated Dockerfiles for frontend and backend with security best practices.

### Research Topic 2: kubectl-ai Extension Installation and Usage

**Status**: Requires verification
**Key Questions**:
- How to install kubecti-ai extension (VS Code Marketplace or CLI)?
- What natural language prompts are supported?
- Can kubecti-ai generate Helm values?

**Expected Output**: Natural language kubectl commands for cluster operations.

### Research Topic 3: kagent Installation and Autonomous Health Monitoring

**Status**: Requires verification
**Key Questions**:
- How to install kagent (npm, pip, or binary)?
- What health monitoring loops are available?
- Can kagent auto-remediate common issues?

**Expected Output**: kagent monitoring cluster with autonomous health recommendations.

### Research Topic 4: Minikube Ingress Tunnel + Host Alias Configuration

**Status**: Well-documented
**Key Findings**:
- `minikube tunnel` runs in background, provides LoadBalancer IPs
- Host alias required for custom domain (todo.local)
- Windows requires Administrator privileges for hosts file modification

**Expected Output**: Working ingress access at http://todo.local.

### Research Topic 5: Helm Umbrella Chart Structure with Subcharts

**Status**: Well-documented
**Key Findings**:
- Umbrella chart references subcharts via `dependencies` in Chart.yaml
- Subcharts reside in `charts/` directory
- Global values can override subchart values

**Expected Output**: ai-todo umbrella chart with frontend/backend subcharts.

### Research Topic 6: Kubernetes Secrets Creation and Mounting Patterns

**Status**: Well-documented
**Key Findings**:
- `kubectl create secret generic` for imperative creation
- `envFrom.secretRef` for environment variable injection
- Secrets base64-encoded; Helm can template secret creation

**Expected Output**: ai-todo-secrets mounted as environment variables in pods.

### Research Topic 7: Health Probe Configuration (Startup/Liveness/Readiness)

**Status**: Well-documented
**Key Findings**:
- Startup probe allows slow container initialization
- Liveness probe detects deadlocks (restarts pod)
- Readiness probe prevents traffic to unready pods
- All three probes recommended for production workloads

**Expected Output**: Comprehensive probe configuration on all deployments.

### Research Topic 8: Resource Requests/Limits for Next.js and FastAPI

**Status**: Requires empirical tuning
**Key Findings**:
- Next.js SSR: 256-512Mi RAM typical
- FastAPI + UVicorn: 512Mi-1Gi RAM typical
- Cohere SDK adds memory overhead for API client

**Expected Output**: Realistic resource allocation based on local testing.

## Phase 1: Design Artifacts

### Artifact 1: data-model.md - Kubernetes Entities

**Purpose**: Define all Kubernetes resources required for deployment.

**Entities**:
- **Deployment**: Frontend (2 replicas), Backend (2 replicas)
- **Service**: Frontend (ClusterIP:3000), Backend (ClusterIP:8000)
- **Ingress**: Path-based routing (todo.local)
- **Secret**: ai-todo-secrets (BETTER_AUTH_SECRET, COHERE_API_KEY, DATABASE_URL)
- **ConfigMap**: ai-todo-config (NODE_ENV, PYTHONUNBUFFERED)
- **Pod**: Frontend pod (1 container), Backend pod (1 container)
- **HorizontalPodAutoscaler**: Optional for demo scaling

### Artifact 2: contracts/ - Helm Chart Structure

**Purpose**: Define Helm chart schema and Kubernetes resource contracts.

**Files**:
- `contracts/helm-structure.md`: Chart directory layout
- `contracts/values-schema.md`: values.yaml parameter documentation
- `contracts/resource-contracts.md`: Deployment, Service, Ingress specifications

### Artifact 3: quickstart.md - Deployment Flow

**Purpose**: Step-by-step guide from cluster start to application access.

**Flow**:
1. Start Minikube: `minikube start --driver=docker --addons=ingress`
2. Create secrets: `kubectl create secret generic ai-todo-secrets ...`
3. Build images: `docker build -f docker/frontend/Dockerfile -t ai-todo-frontend .`
4. Deploy: `helm install ai-todo ./infra/helm/ai-todo`
5. Configure tunnel: `minikube tunnel` (separate terminal)
6. Add host alias: `127.0.0.1 todo.local`
7. Access: Navigate to http://todo.local

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Umbrella chart with subcharts | Coordinated deployment of frontend + backend | Separate charts would require multiple helm install commands |
| Three probe types (startup/liveness/readiness) | Production-grade reliability | Single probe insufficient for slow-starting containers |
| AI-generated infrastructure | Constitution Principle XIII mandate | Manual YAML violates Phase IV principles |
| Minikube tunnel + host alias | Production-like URL access | Port-forward requires separate terminal and non-standard URL |

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Gordon AI unavailable | Dockerfile generation blocked | Medium | Fallback to manual multi-stage Dockerfiles |
| kubectl-ai/kagent installation fails | AI DevOps demo blocked | Medium | Document manual kubectl equivalents |
| Minikube resource exhaustion | Pods fail to schedule | Low | Allocate 8GB+ RAM, 4+ CPUs to Minikube |
| Neon PostgreSQL connectivity | Backend health checks fail | Low | Verify connection string; fallback to local SQLite |
| Ingress tunnel instability | Access URL unavailable | Medium | Document port-forward fallback |

## Success Criteria Validation

| Criterion | Validation Method | Target |
|-----------|-------------------|--------|
| SC-001: Deployment <30s | `time helm install` + `kubectl rollout status` | <30s warm start |
| SC-002: App accessible at todo.local | Browser navigation + chatbot test | Full functionality |
| SC-003: Zero-downtime updates | `helm upgrade` + continuous requests | No HTTP errors |
| SC-004: Self-healing <60s | `kubectl delete pod` + watch recovery | <60s to Ready |
| SC-005: Scaling <30s | `kubectl scale` + watch new pods | <30s to Ready |
| SC-006: Non-root containers | `kubectl exec -- whoami` | Not root |
| SC-007: Secrets mounted | `kubectl exec -- printenv` | Secrets visible |
| SC-008: kubecti-ai functional | Natural language queries | Accurate responses |
| SC-009: Resource limits set | `kubectl describe pod` | Limits present |
| SC-010: Health probes configured | `kubectl describe pod` | All probes defined |

## Follow-ups

1. **Create research.md**: Document findings from Phase 0 research topics with installation commands and configuration examples.
2. **Create data-model.md**: Detail Kubernetes entity specifications with YAML examples for each resource type.
3. **Create contracts/**: Define Helm chart structure, values.yaml schema, and resource contracts.
4. **Create quickstart.md**: Write step-by-step deployment guide with troubleshooting section.
5. **Create tasks.md**: Generate testable tasks with acceptance criteria for each user story.

## Architectural Decision Records (ADRs)

📋 **Architectural decisions requiring documentation**:

1. **Gordon-First Dockerfile Generation**: AI-generated Dockerfiles with manual fallback
2. **Helm Umbrella Chart Architecture**: Single chart with subcharts vs. separate charts
3. **Minikube Docker Driver Selection**: Docker driver vs. Hyper-V/VirtualBox
4. **Ingress + Tunnel Access Pattern**: Production-like URL vs. port-forward
5. **Single Shared Secret Strategy**: One secret for all env vars vs. per-component secrets
6. **Three-Probe Health Strategy**: Startup + liveness + readiness vs. simplified probes
7. **Resource Allocation Baseline**: 512Mi/0.5 CPU starting point with kagent optimization

**Action**: Run `/sp.adr kubernetes-deployment-decisions` to document these decisions with tradeoff analysis.
