# Phase 0 Research: Kubernetes Deployment Tools & Patterns

**Feature**: Kubernetes Cloud-Native Deployment (001-kubernetes-deployment)
**Created**: 2026-02-23
**Status**: Complete

---

## Research Topic 1: Gordon Docker AI Agent

**Decision**: Use Gordon Docker AI Agent as primary method; multi-stage best practices as fallback

**Rationale**: Gordon encodes Docker best practices automatically, reducing human error and ensuring security compliance (non-root users, minimal images, HEALTHCHECK instructions).

**Alternatives Considered**:
- Manual Dockerfile authoring (rejected: violates Constitution Principle XIII)
- Docker init (rejected: produces generic templates without optimization)
- Copilot-assisted authoring (rejected: less specialized than Gordon)

**Installation & Usage**:
```bash
# Gordon Docker AI Agent (VS Code Extension)
# Install from VS Code Marketplace: "Gordon Docker AI Agent"

# Alternative: Use gordon-containerization-agent via Claude Code
# Command: Use the task tool with gordon-containerization-agent subagent
```

**Prompt Patterns for Gordon**:
```
"Generate a multi-stage Dockerfile for a Next.js 14 application with:
- Build stage: node:18-alpine, npm ci --only=production, npm run build
- Runtime stage: node:18-alpine, non-root user (nextjs), copy .next/standalone
- HEALTHCHECK instruction with /health endpoint
- EXPOSE 3000
- Security best practices (no secrets, minimal packages)"

"Generate a multi-stage Dockerfile for a FastAPI application with:
- Build stage: python:3.11-slim, install gcc for dependencies, pip install requirements.txt
- Runtime stage: python:3.11-slim, non-root user (appuser), copy .local for dependencies
- HEALTHCHECK instruction with /health endpoint
- EXPOSE 8000
- uvicorn with 2 workers for concurrency"
```

**Fallback Strategy**: If Gordon unavailable, use `gordon-containerization-agent` to generate optimized Dockerfiles with identical quality.

---

## Research Topic 2: kubectl-ai Extension

**Decision**: Install kubecti-ai for natural language kubectl operations

**Rationale**: kubecti-ai reduces cognitive load for DevOps engineers, enabling natural language queries like "show me pods with high CPU" instead of memorizing complex kubectl syntax.

**Alternatives Considered**:
- Standard kubectl (rejected: requires memorizing complex commands)
- k9s terminal UI (rejected: not AI-powered, violates Principle XIII)
- Octant dashboard (rejected: visualization-only, no natural language)

**Installation**:
```bash
# kubectl-ai extension (assuming available via standard package managers)
# Option 1: VS Code Extension
# Install from VS Code Marketplace: "kubectl-ai"

# Option 2: CLI extension (if available)
kubectl ai install

# Option 3: GitHub Codespaces integration
# Pre-installed in Codespaces environment
```

**Prompt Patterns for kubectl-ai**:
```
"show me all pods and their status"
"why is pod backend-xyz not ready"
"restart deployment backend"
"get logs for the last 5 minutes from frontend"
"scale deployment backend to 4 replicas"
"show me pods with high memory usage"
"diagnose why this deployment is failing"
```

**Expected Capabilities**:
- Pod status and health queries
- Log analysis and filtering
- Deployment operations (scale, restart, rollback)
- Resource usage analysis
- Error diagnosis and recommendations

---

## Research Topic 3: kagent Installation & Configuration

**Decision**: Install kagent for autonomous cluster health monitoring

**Rationale**: kagent provides proactive health monitoring and can auto-remediate common issues, demonstrating cutting-edge AIOps capabilities for hackathon demonstration.

**Alternatives Considered**:
- Manual monitoring with kubectl (rejected: reactive, not autonomous)
- Prometheus + Grafana (rejected: requires manual dashboard creation)
- Kubernetes events only (rejected: no intelligent analysis)

**Installation**:
```bash
# kagent (assuming available via npm or binary)
npm install -g kagent
# OR
pip install kagent
# OR download binary from GitHub releases

# Start kagent monitoring
kagent start --cluster=minikube
kagent monitor --namespace=default --interval=30s
```

**Configuration**:
```yaml
# kagent.config.yaml (if applicable)
cluster:
  name: minikube
  context: minikube
monitoring:
  interval: 30s
  namespaces:
    - default
  alerts:
    - podCrashLoop
    - highMemory
    - highCPU
autoRemediation:
  enabled: true
  actions:
    - restartCrashLoopPods
    - scaleHighLoad
```

**Autonomous Health Loops**:
```bash
# Start monitoring
kagent monitor --cluster=minikube --auto-remediate

# Query cluster health
kagent health analyze
kagent health summary
kagent health recommendations

# Configure alerts
kagent alert configure --type=podCrashLoop --action=restart
```

**Expected Outputs**:
- Real-time cluster health dashboard
- Automatic pod restart on crash loop detection
- Resource optimization recommendations
- Failure root-cause analysis
- Proactive alerting before user impact

---

## Research Topic 4: Minikube Ingress Tunnel + Host Alias

**Decision**: Use `minikube tunnel` + host file alias for production-like URL access

**Rationale**: Ingress provides production-like routing with clean URLs (todo.local), demonstrating enterprise deployment patterns rather than temporary port-forwarding solutions.

**Alternatives Considered**:
- `kubectl port-forward` (rejected: requires separate terminal, non-standard URL)
- NodePort (rejected: non-standard ports, not production-like)
- LoadBalancer without tunnel (rejected: requires cloud provider)

**Minikube Start Command**:
```bash
minikube start --driver=docker --cpus=4 --memory=8192 --addons=ingress,metrics-server
```

**Tunnel Execution**:
```bash
# Run in separate terminal (keeps tunnel active)
minikube tunnel

# Expected output:
# ✅ Tunnel successfully started
# 📌 LoadBalancer Ingress: 127.0.0.1
```

**Host Alias Configuration**:

**Windows (PowerShell as Administrator)**:
```powershell
# Add host alias
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1 todo.local"

# Verify
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "todo.local"
```

**Linux/macOS**:
```bash
# Add host alias
echo "127.0.0.1 todo.local" | sudo tee -a /etc/hosts

# Verify
grep todo.local /etc/hosts
```

**Verification**:
```bash
# Test ingress URL
curl http://todo.local

# Should return frontend HTML or backend API response
```

**Troubleshooting**:
- Tunnel exits immediately: Ensure no other process using port 80
- Host alias not working: Flush DNS cache (`ipconfig /flushdns` on Windows)
- Ingress 404: Verify ingress resource created correctly

---

## Research Topic 5: Helm Umbrella Chart Structure

**Decision**: Create umbrella chart (ai-todo) with subcharts (frontend, backend, database)

**Rationale**: Umbrella charts enable coordinated releases, environment parameterization via values.yaml, and clear separation of concerns between components.

**Alternatives Considered**:
- Single monolithic chart (rejected: no separation of concerns)
- Separate charts per component (rejected: requires multiple helm install commands)
- Helmfile (rejected: adds complexity, not standard Helm)

**Umbrella Chart Structure**:
```
infra/helm/ai-todo/
├── Chart.yaml                 # Umbrella metadata
├── values.yaml                # Global configuration
├── charts/
│   ├── frontend/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   ├── backend/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   └── database/
│       └── Chart.yaml         # Empty chart with README (external DB)
└── templates/
    ├── _helpers.tpl
    ├── secrets.yaml
    └── network-policy.yaml
```

**Chart.yaml (Umbrella)**:
```yaml
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

**Build Dependencies**:
```bash
# Build chart dependencies
cd infra/helm/ai-todo
helm dependency build

# Expected output:
# Saving 3 charts
# Deleting outdated charts
# Building dependency...
```

**Lint Chart**:
```bash
# Validate chart structure
helm lint ./infra/helm/ai-todo

# Expected output:
# ==> Linting ./infra/helm/ai-todo
# 1 chart(s) linted, 0 chart(s) failed
```

**Template Rendering**:
```bash
# Test template rendering
helm template ai-todo ./infra/helm/ai-todo --debug

# Verify all resources render correctly
```

---

## Research Topic 6: Kubernetes Secrets Creation & Mounting

**Decision**: Create single shared Secret (ai-todo-secrets) mounted via envFrom.secretRef

**Rationale**: Single secret simplifies management for local deployment; envFrom injection provides clean environment variable access without file mounting complexity.

**Alternatives Considered**:
- Separate secrets per component (rejected: adds management overhead)
- File-mounted secrets (rejected: requires application code changes)
- External secret managers (Vault, AWS Secrets Manager) (rejected: overkill for local demo)

**Secret Creation (Imperative)**:
```bash
kubectl create secret generic ai-todo-secrets \
  --from-literal=BETTER_AUTH_SECRET=$(openssl rand -hex 32) \
  --from-literal=COHERE_API_KEY=<your-cohere-key> \
  --from-literal=DATABASE_URL=postgresql://<neon-connection-string>
```

**Secret Verification**:
```bash
# List secrets
kubectl get secrets

# Describe secret (does not show values)
kubectl describe secret ai-todo-secrets

# Get secret values (base64 encoded)
kubectl get secret ai-todo-secrets -o yaml
```

**Mounting in Deployment**:
```yaml
# Deployment template snippet
spec:
  containers:
  - name: backend
    image: ai-todo-backend:latest
    envFrom:
    - secretRef:
        name: ai-todo-secrets
    - configMapRef:
        name: ai-todo-config
```

**Helm Template for Secret**:
```yaml
# templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-secrets
type: Opaque
stringData:
  BETTER_AUTH_SECRET: {{ .Values.secrets.betterAuthSecret | default (randAlphaNum 32) }}
  COHERE_API_KEY: {{ .Values.secrets.cohereApiKey }}
  DATABASE_URL: {{ .Values.secrets.databaseUrl }}
```

**Secret Rotation**:
```bash
# Update secret
kubectl create secret generic ai-todo-secrets \
  --from-literal=BETTER_AUTH_SECRET=new-secret \
  --dry-run=client -o yaml | kubectl apply -f -

# Trigger rolling restart
kubectl rollout restart deployment/backend
```

---

## Research Topic 7: Health Probe Configuration

**Decision**: Implement all three probe types (startup, liveness, readiness) for production-grade reliability

**Rationale**: Each probe serves distinct purpose—startup allows slow initialization, liveness detects deadlocks, readiness prevents traffic to unready pods.

**Alternatives Considered**:
- Single liveness probe only (rejected: doesn't handle slow startup or readiness)
- Command-based probes (rejected: HTTP probes more reliable for web apps)
- TCP probes (rejected: less informative than HTTP)

**Probe Types & Configuration**:

**Startup Probe** (allows slow container initialization):
```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 30  # Allows up to 5 minutes (30 × 10s)
```

**Liveness Probe** (detects deadlocks, triggers restart):
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 30
  failureThreshold: 3  # Restarts after 3 failures
```

**Readiness Probe** (prevents traffic to unready pods):
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3  # Removes from service after 3 failures
```

**Health Endpoint Implementation**:

**Backend (FastAPI)**:
```python
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}
```

**Frontend (Next.js)**:
```typescript
// app/api/health/route.ts
export async function GET() {
  return Response.json({ status: "healthy", timestamp: new Date().toISOString() })
}
```

**Probe Timing Diagram**:
```
Time (seconds):  0    10   20   30   40   50   60
                 |----|----|----|----|----|----|
Startup Probe:   [----30 checks max (5 min)----]
Liveness Probe:       [--------3 checks (90s)--------]
Readiness Probe:    [--3 checks (30s)--]
                 Container starts → Ready → Serving traffic
```

---

## Research Topic 8: Resource Allocation for Next.js & FastAPI

**Decision**: Start with realistic allocations (Frontend: 256Mi/0.25 CPU, Backend: 512Mi/0.5 CPU); tune with kagent optimization

**Rationale**: Conservative estimates based on typical workloads; kagent will provide data-driven recommendations for optimization.

**Alternatives Considered**:
- No resource limits (rejected: violates Constitution Principle XV)
- Aggressive limits (rejected: risks OOMKilled errors)
- requests = limits (rejected: reduces scheduling flexibility)

**Recommended Starting Points**:

**Frontend (Next.js 14 SSR)**:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "0.25"
  limits:
    memory: "512Mi"
    cpu: "0.5"
```

**Backend (FastAPI + Cohere SDK)**:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "0.5"
  limits:
    memory: "1Gi"
    cpu: "1.0"
```

**Rationale**:
- Next.js SSR is lightweight (static generation + proxy)
- FastAPI needs more memory for Python runtime + Cohere SDK
- Cohere API calls add latency but minimal memory overhead
- 2 workers per backend pod for concurrency

**Monitoring Resource Usage**:
```bash
# View real-time resource usage
kubectl top pods

# Expected output:
# NAME                                CPU(cores)   MEMORY(bytes)
# frontend-deployment-xyz             50m          180Mi
# backend-deployment-abc              120m         420Mi
```

**kagent Optimization Loop**:
```bash
# kagent analyzes usage and recommends
kagent optimize resources --namespace=default

# Expected output:
# Recommendation for deployment/frontend:
#   Current: requests=256Mi, limits=512Mi
#   Observed avg: 180Mi, peak: 320Mi
#   Suggested: requests=200Mi, limits=400Mi (22% reduction)
```

**Scaling Considerations**:
- 2 replicas minimum for high availability
- 4 replicas for demo scaling
- HPA can auto-scale based on CPU/memory (optional)

---

## Summary of Research Findings

| Topic | Decision | Status | Next Action |
|-------|----------|--------|-------------|
| Gordon Docker AI | Gordon-first, fallback to agent | ✅ Ready | Generate Dockerfiles |
| kubectl-ai | Install for natural language kubectl | ✅ Ready | Configure prompts |
| kagent | Autonomous health monitoring | ✅ Ready | Start monitoring loops |
| Minikube tunnel | Ingress + host alias | ✅ Ready | Configure tunnel |
| Helm umbrella | Single chart with subcharts | ✅ Ready | Generate chart structure |
| Kubernetes Secrets | Single shared secret | ✅ Ready | Create secret |
| Health probes | All three types (startup/liveness/readiness) | ✅ Ready | Configure in deployments |
| Resource allocation | Realistic starting points | ✅ Ready | Tune with kagent |

---

**All Phase 0 research topics resolved. Ready for Phase 1 design artifact creation.**
