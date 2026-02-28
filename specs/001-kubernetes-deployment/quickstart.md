# Quickstart: Phase IV Kubernetes Deployment

**Feature**: Kubernetes Cloud-Native Deployment
**Version**: 1.0.0
**Created**: 2026-02-23
**Last Updated**: 2026-02-23

---

## Overview

This guide walks you through deploying the Phase III AI Todo Chatbot to a local Minikube Kubernetes cluster in under 5 minutes. By the end, you'll have a production-grade deployment accessible at http://todo.local with full chatbot functionality.

---

## Prerequisites

Ensure the following tools are installed before starting:

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| Docker Desktop | Latest | [docker.com](https://www.docker.com/products/docker-desktop) (enable Gordon Beta) |
| Minikube | v1.32+ | [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| Helm | v3.14+ | [helm.sh](https://helm.sh/docs/intro/install/) |
| kubectl | v1.29+ | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |

### Optional AI DevOps Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| kubecti-ai | Natural language kubectl | VS Code Marketplace |
| kagent | Autonomous health monitoring | npm/pip install |

### Verify Installation

```bash
# Check Docker
docker --version
# Expected: Docker version 24.x.x

# Check Minikube
minikube version
# Expected: minikube version: v1.32.0+

# Check Helm
helm version
# Expected: version.BuildInfo{Version:"v3.14.0"+}

# Check kubectl
kubectl version --client
# Expected: Client Version: v1.29.0+
```

---

## Step 1: Start Minikube Cluster

```bash
minikube start --driver=docker --cpus=4 --memory=8192 --addons=ingress,metrics-server
```

**Expected Output**:
```
😄  minikube v1.32.0 on Microsoft Windows 11
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.0-0 ...
🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
🐳  Preparing Kubernetes v1.29.0 on Docker 24.0.7 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: ingress, metrics-server
🏄  Done! kubectl is now configured to use "minikube" cluster
```

**Verification**:
```bash
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://...
```

---

## Step 2: Create Kubernetes Secrets

```bash
kubectl create secret generic ai-todo-secrets \
  --from-literal=BETTER_AUTH_SECRET=$(openssl rand -hex 32) \
  --from-literal=COHERE_API_KEY=<your-cohere-api-key> \
  --from-literal=DATABASE_URL=<your-neon-connection-string>
```

**Expected Output**:
```
secret/ai-todo-secrets created
```

**Verification**:
```bash
kubectl get secrets
# Expected: ai-todo-secrets   Opaque   3   10s

kubectl describe secret ai-todo-secrets
# Expected: Shows 3 data entries (values hidden)
```

---

## Step 3: Create ConfigMap

```bash
kubectl create configmap ai-todo-config \
  --from-literal=NODE_ENV=production \
  --from-literal=PYTHONUNBUFFERED=1 \
  --from-literal=LOG_LEVEL=info
```

**Expected Output**:
```
configmap/ai-todo-config created
```

**Verification**:
```bash
kubectl get configmaps
# Expected: ai-todo-config   3   10s
```

---

## Step 4: Build Docker Images

### Build Frontend Image

```bash
docker build -f docker/frontend/Dockerfile -t ai-todo-frontend:latest .
```

**Expected Output**:
```
[+] Building 45.2s (15/15) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/node:18-alpine
 => [builder 1/5] WORKDIR /app
 => [builder 2/5] COPY package*.json ./
 => [builder 3/5] RUN npm ci --only=production
 => [builder 4/5] COPY . .
 => [builder 5/5] RUN npm run build
 => [runner 1/3] COPY --from=builder /app/public ./public
 => [runner 2/3] COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
 => [runner 3/3] COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
 => exporting to image
 => => naming to ai-todo-frontend:latest
```

**Verification**:
```bash
docker images | grep ai-todo-frontend
# Expected: ai-todo-frontend   latest   <image-id>   2 minutes ago   150MB
```

### Build Backend Image

```bash
docker build -f docker/backend/Dockerfile -t ai-todo-backend:latest .
```

**Expected Output**:
```
[+] Building 38.5s (12/12) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [builder 1/4] WORKDIR /app
 => [builder 2/4] COPY requirements.txt .
 => [builder 3/4] RUN pip install --no-cache-dir --user -r requirements.txt
 => [runner 1/3] COPY --from=builder /root/.local /home/appuser/.local
 => [runner 2/3] COPY --chown=appuser:appuser . .
 => [runner 3/3] USER appuser
 => exporting to image
 => => naming to ai-todo-backend:latest
```

**Verification**:
```bash
docker images | grep ai-todo-backend
# Expected: ai-todo-backend   latest   <image-id>   2 minutes ago   180MB
```

---

## Step 5: Deploy with Helm

```bash
helm install ai-todo ./infra/helm/ai-todo --namespace=default
```

**Expected Output**:
```
NAME: ai-todo
LAST DEPLOYED: Mon Feb 23 10:30:00 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export INGRESS_HOST=$(minikube ip)
  echo http://todo.local
```

**Verification**:
```bash
helm list
# Expected: ai-todo   1   10s   deployed   ai-todo-0.1.0   1.0.0
```

---

## Step 6: Wait for Pods to Be Ready

```bash
kubectl wait --for=condition=Ready pods -l component=ai-todo --timeout=300s
```

**Expected Output**:
```
pod/frontend-deployment-xyz123 condition met
pod/frontend-deployment-abc456 condition met
pod/backend-deployment-def789 condition met
pod/backend-deployment-ghi012 condition met
```

**Verification**:
```bash
kubectl get pods -l component=ai-todo
# Expected:
# NAME                                  READY   STATUS    RESTARTS   AGE
# frontend-deployment-xyz123            1/1     Running   0          30s
# frontend-deployment-abc456            1/1     Running   0          30s
# backend-deployment-def789             1/1     Running   0          30s
# backend-deployment-ghi012             1/1     Running   0          30s
```

---

## Step 7: Configure Ingress Access

### Start Minikube Tunnel

**Open a new terminal window** and run:

```bash
minikube tunnel
```

**Expected Output**:
```
✅  Tunnel successfully started
📌  LoadBalancer Ingress: 127.0.0.1
📢  The tunnel/ingress service is now running
```

**Note**: Keep this terminal window open. The tunnel must remain active for ingress access.

### Add Host Alias

**Windows (PowerShell as Administrator)**:
```powershell
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1 todo.local"
```

**Linux/macOS**:
```bash
echo "127.0.0.1 todo.local" | sudo tee -a /etc/hosts
```

**Verification**:
```bash
ping todo.local
# Expected: Pinging todo.local [127.0.0.1] with 32 bytes of data
```

---

## Step 8: Access the Application

### Open Browser

Navigate to: **http://todo.local**

**Expected**: Next.js frontend login page loads

### Test Chatbot Functionality

1. **Login** with your credentials
2. **Open chat interface**
3. **Type**: "Add a task to test Kubernetes deployment"
4. **Expected Response**: "I've added 'test Kubernetes deployment' to your tasks!"
5. **Verify**: Task appears in your task list

### Test Conversation Persistence

1. **Type**: "Show me my tasks"
2. **Expected Response**: Lists your tasks from database
3. **Type**: "Mark the test task as complete"
4. **Expected Response**: Confirms task completion
5. **Verify**: Task marked complete in UI

---

## Step 9: Demonstrate Self-Healing

### Delete a Pod

```bash
kubectl delete pod backend-deployment-def789
```

**Expected Output**:
```
pod "backend-deployment-def789" deleted
```

### Watch Auto-Recovery

```bash
kubectl get pods -l app=backend -w
```

**Expected**:
```
NAME                                  READY   STATUS              RESTARTS   AGE
backend-deployment-def789             1/1     Running             0          2m
backend-deployment-ghi012             1/1     Running             0          2m
backend-deployment-def789             1/1     Terminating         0          2m
backend-deployment-xyz789             0/1     ContainerCreating   0          0s
backend-deployment-xyz789             1/1     Running             0          10s
backend-deployment-xyz789             1/1     Ready               0          30s
```

**Verification**: Application remains accessible throughout recovery.

---

## Step 10: Demonstrate Horizontal Scaling

### Scale Backend Replicas

```bash
kubectl scale deployment/backend --replicas=4
```

**Expected Output**:
```
deployment.apps/backend scaled
```

### Watch Scaling Operation

```bash
kubectl get pods -l app=backend -w
```

**Expected**:
```
NAME                                  READY   STATUS              RESTARTS   AGE
backend-deployment-def789             1/1     Running             0          5m
backend-deployment-ghi012             1/1     Running             0          5m
backend-deployment-xyz789             1/1     Running             0          3m
backend-deployment-abc123             0/1     ContainerCreating   0          0s
backend-deployment-abc123             1/1     Running             0          10s
backend-deployment-abc123             1/1     Ready               0          30s
```

### Verify Load Balancing

```bash
kubectl get endpoints backend-service
```

**Expected**: All 4 pod IPs listed

---

## Troubleshooting

### Pods Not Starting

**Symptom**: Pods stuck in `Pending` or `ImagePullBackOff`

**Diagnosis**:
```bash
kubectl describe pod <pod-name>
kubectl get events --sort-by='.lastTimestamp'
```

**Common Causes**:
- Insufficient cluster resources: `minikube stop && minikube start --cpus=4 --memory=8192`
- Image not found: Verify image built with `docker images`
- Secret not mounted: Check secret exists with `kubectl get secrets`

### Ingress Not Working

**Symptom**: Browser shows "Site can't be reached"

**Diagnosis**:
```bash
kubectl get ingress
kubectl describe ingress ai-todo-ingress
```

**Common Causes**:
- Tunnel not running: Start `minikube tunnel` in separate terminal
- Host alias not configured: Add `127.0.0.1 todo.local` to hosts file
- Ingress addon not enabled: `minikube addons enable ingress`

### Backend Health Check Failing

**Symptom**: Backend pods in `CrashLoopBackOff`

**Diagnosis**:
```bash
kubectl logs backend-deployment-<pod-id>
kubectl describe pod backend-deployment-<pod-id>
```

**Common Causes**:
- DATABASE_URL incorrect: Verify Neon connection string
- COHERE_API_KEY invalid: Check API key in secret
- BETTER_AUTH_SECRET missing: Recreate secret

### Database Connection Issues

**Symptom**: Backend logs show database connection errors

**Diagnosis**:
```bash
kubectl logs backend-deployment-<pod-id> | grep -i database
```

**Common Causes**:
- Neon PostgreSQL unreachable: Verify network connectivity
- Connection string malformed: Check DATABASE_URL format
- Firewall blocking: Ensure Neon allows connections from your IP

---

## Demo Scenarios

### Scenario 1: Zero-Downtime Deployment

```bash
# Start continuous requests in background
while true; do curl -s http://todo.local > /dev/null && echo "✓ Request successful"; sleep 1; done

# In another terminal, upgrade deployment
helm upgrade ai-todo ./infra/helm/ai-todo

# Verify no failed requests during upgrade
```

**Expected**: All requests succeed throughout upgrade

### Scenario 2: AI DevOps with kubecti-ai

```bash
# Natural language query
kubectl-ai "show me all pods and their status"

# Diagnosis query
kubectl-ai "why is pod backend-xyz not ready"

# Scaling query
kubectl-ai "scale deployment backend to 4 replicas"
```

**Expected**: AI returns accurate, actionable responses

### Scenario 3: kagent Autonomous Monitoring

```bash
# Start kagent monitoring
kagent monitor --cluster=minikube --auto-remediate

# Trigger failure
kubectl delete pod backend-deployment-xyz

# Watch kagent detect and remediate
kagent health analyze
```

**Expected**: kagent detects failure, restarts pod, reports resolution

---

## Cleanup

### Uninstall Helm Release

```bash
helm uninstall ai-todo
```

### Delete Minikube Cluster

```bash
minikube delete --purge
```

### Remove Host Alias

**Windows**:
```powershell
(Get-Content C:\Windows\System32\drivers\etc\hosts) | Select-String -Pattern "todo.local" -NotMatch | Set-Content C:\Windows\System32\drivers\etc\hosts
```

**Linux/macOS**:
```bash
sudo sed -i '/todo.local/d' /etc/hosts
```

---

## Next Steps

1. **Explore AI DevOps**: Install kubecti-ai and kagent for intelligent operations
2. **Configure HPA**: Enable horizontal pod autoscaling for automatic scaling
3. **Add NetworkPolicy**: Implement pod-to-pod traffic restrictions
4. **Set up Monitoring**: Deploy Prometheus + Grafana for advanced metrics
5. **Prepare Demo**: Rehearse hackathon demonstration flow

---

**Deployment complete! Application accessible at http://todo.local**
