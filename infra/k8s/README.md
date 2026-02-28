# AI Todo Chatbot - Raw Kubernetes Manifests

This folder contains raw Kubernetes YAML manifests as an alternative to Helm charts for deploying the AI Todo Chatbot application.

## Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Namespace definition (optional) |
| `secrets.yaml` | Kubernetes Secrets (API keys, DB URL) |
| `configmap.yaml` | ConfigMap for non-sensitive configuration |
| `backend-deployment.yaml` | Backend FastAPI deployment |
| `frontend-deployment.yaml` | Frontend Next.js deployment |
| `services.yaml` | ClusterIP services for backend and frontend |
| `hpa.yaml` | Horizontal Pod Autoscalers |
| `ingress.yaml` | NGINX Ingress configuration |
| `rbac.yaml` | ServiceAccount and NetworkPolicy |

## Quick Start

### Prerequisites

- Minikube cluster running with ingress addon
- Docker images built and loaded into Minikube
- kubectl configured

### Deploy with kubectl

```bash
# Navigate to project root
cd "C:\Users\hp\OneDrive\Documents\Hackathon 2 Phase 4"

# Apply all manifests
kubectl apply -f infra/k8s/

# Or apply individually in order
kubectl apply -f infra/k8s/secrets.yaml
kubectl apply -f infra/k8s/configmap.yaml
kubectl apply -f infra/k8s/backend-deployment.yaml
kubectl apply -f infra/k8s/frontend-deployment.yaml
kubectl apply -f infra/k8s/services.yaml
kubectl apply -f infra/k8s/hpa.yaml
kubectl apply -f infra/k8s/ingress.yaml
kubectl apply -f infra/k8s/rbac.yaml

# Verify deployment
kubectl get pods -l app.kubernetes.io/name=ai-todo
kubectl get deployments
kubectl get services
kubectl get ingress
kubectl get hpa
```

### Verify Health

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=ai-todo

# Check backend logs
kubectl logs -l app.kubernetes.io/component=backend --tail=50

# Check frontend logs
kubectl logs -l app.kubernetes.io/component=frontend --tail=50

# Test health endpoints
kubectl exec deploy/ai-todo-backend -- python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/health').read().decode())"
```

### Access Application

```bash
# Start Minikube tunnel (in separate terminal)
minikube tunnel

# Navigate to http://todo.local in browser
```

### Cleanup

```bash
# Delete all resources
kubectl delete -f infra/k8s/

# Or delete individually
kubectl delete ingress ai-todo-ingress
kubectl delete hpa ai-todo-backend ai-todo-frontend
kubectl delete services ai-todo-backend ai-todo-frontend
kubectl delete deployments ai-todo-backend ai-todo-frontend
kubectl delete configmap ai-todo-config
kubectl delete secret ai-todo-secrets
kubectl delete serviceaccount ai-todo-service-account
kubectl delete networkpolicy ai-todo-network-policy
```

## Configuration

### Secrets (Update Before Production)

Edit `secrets.yaml` with real values:

```yaml
stringData:
  BETTER_AUTH_SECRET: <generate-random-32-char-string>
  COHERE_API_KEY: <your-cohere-api-key>
  DATABASE_URL: postgresql://<user>:<password>@<host>.neon.tech/<database>
```

### Resource Limits

Adjust resource requests/limits in deployment files based on your cluster capacity:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### Scaling

Modify replica count or HPA thresholds:

```yaml
# In deployment files
spec:
  replicas: 2  # Change this

# Or in HPA files
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - resource:
        name: cpu
        target:
          averageUtilization: 80  # Change this
```

## Comparison: Helm vs Raw Manifests

| Feature | Helm Charts | Raw Manifests |
|---------|-------------|---------------|
| Templating | ✅ Yes | ❌ No |
| Versioning | ✅ Yes | ❌ Manual |
| Dependencies | ✅ Automatic | ❌ Manual |
| Rollback | ✅ Easy | ❌ Manual |
| Simplicity | ⚠️ Learning curve | ✅ Simple |
| Flexibility | ⚠️ Template-based | ✅ Full control |

**Use Helm when**: You need templating, versioning, or complex configurations.

**Use Raw Manifests when**: You want simplicity, full control, or are learning Kubernetes.

## Troubleshooting

### Pods Not Starting

```bash
# Check events
kubectl describe pods -l app.kubernetes.io/name=ai-todo

# Check image pull errors
kubectl get pods -o wide

# Verify images exist in Minikube
minikube image ls | grep ai-todo
```

### Ingress Not Working

```bash
# Verify ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resource
kubectl describe ingress ai-todo-ingress

# Verify host alias
ping todo.local
```

### Health Checks Failing

```bash
# Check application logs
kubectl logs deploy/ai-todo-backend

# Test health endpoint manually
kubectl port-forward deploy/ai-todo-backend 8000:8000
curl http://localhost:8000/health
```

## Security Considerations

1. **Never commit real secrets** - Use placeholder values and update via `kubectl create secret` or sealed secrets
2. **Network policies** - Restrict pod-to-pod communication
3. **Pod security contexts** - Run as non-root, drop capabilities
4. **Resource limits** - Prevent resource exhaustion

## Constitution Compliance

These manifests follow Phase IV Constitution principles:

- ✅ **Containerization Excellence**: Multi-stage Docker images
- ✅ **Security**: Non-root users, NetworkPolicy, Secrets management
- ✅ **Observability**: Health probes, HPA metrics
- ✅ **Production-Grade**: Resource limits, rolling updates

---

**Created**: 2026-02-28  
**Version**: 1.0.0  
**Status**: Production-ready
