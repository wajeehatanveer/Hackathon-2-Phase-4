# =============================================================================
# Phase IV Kubernetes Deployment Script
# =============================================================================
# Description: Full deployment automation for AI TODO application on Minikube
# Usage: .\deploy.ps1
# Requirements: Docker, Minikube, Helm, kubectl installed
# =============================================================================

param(
    [int]$MINIKUBE_CPUS = 2,
    [int]$MINIKUBE_MEMORY = 2048,
    [string]$NAMESPACE = "default",
    [string]$RELEASE_NAME = "ai-todo",
    [string]$COHERE_API_KEY = "REPLACE_WITH_YOUR_KEY",
    [string]$DATABASE_URL = "REPLACE_WITH_YOUR_NEON_URL"
)

# Error handling
$ErrorActionPreference = "Stop"

# Color helper functions
function Write-Phase {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

# =============================================================================
# Phase 1: Verify Prerequisites
# =============================================================================
Write-Phase "Phase 1: Verifying Prerequisites"

try {
    Write-Host "Checking Docker..." -ForegroundColor Gray
    docker --version
    Write-Success "  ✓ Docker is installed"
} catch {
    Write-Error-Custom "  ✗ Docker is not installed or not in PATH"
    exit 1
}

try {
    Write-Host "Checking Minikube..." -ForegroundColor Gray
    minikube version
    Write-Success "  ✓ Minikube is installed"
} catch {
    Write-Error-Custom "  ✗ Minikube is not installed or not in PATH"
    exit 1
}

try {
    Write-Host "Checking Helm..." -ForegroundColor Gray
    helm version
    Write-Success "  ✓ Helm is installed"
} catch {
    Write-Error-Custom "  ✗ Helm is not installed or not in PATH"
    exit 1
}

try {
    Write-Host "Checking kubectl..." -ForegroundColor Gray
    kubectl version --client
    Write-Success "  ✓ kubectl is installed"
} catch {
    Write-Error-Custom "  ✗ kubectl is not installed or not in PATH"
    exit 1
}

# =============================================================================
# Phase 2: Start Minikube Cluster
# =============================================================================
Write-Phase "Phase 2: Starting Minikube Cluster"

$minikubeStatus = minikube status 2>&1
if ($minikubeStatus -match "host:\s*Stopped" -or $minikubeStatus -match "host:\s*Does not exist") {
    Write-Host "Starting Minikube with Docker driver..." -ForegroundColor Gray
    minikube start --driver=docker --cpus $MINIKUBE_CPUS --memory $MINIKUBE_MEMORY --addons=ingress --wait=10m
    Write-Success "  ✓ Minikube cluster started successfully"
} else {
    Write-Success "  ✓ Minikube is already running"
}

# Enable metrics-server addon
Write-Host "Enabling metrics-server addon..." -ForegroundColor Gray
minikube addons enable metrics-server 2>$null
Write-Success "  ✓ Metrics server addon enabled"

# =============================================================================
# Phase 3: Build Docker Images
# =============================================================================
Write-Phase "Phase 3: Building Docker Images"

# Check if Dockerfiles exist
$frontendDockerfile = "docker/frontend/Dockerfile"
$backendDockerfile = "docker/backend/Dockerfile"

if (Test-Path $frontendDockerfile) {
    Write-Host "Building frontend image..." -ForegroundColor Gray
    docker build -f $frontendDockerfile -t ai-todo-frontend:latest .
    Write-Success "  ✓ Frontend image built: ai-todo-frontend:latest"
} else {
    Write-Warning-Custom "  ⚠ Frontend Dockerfile not found at $frontendDockerfile"
}

if (Test-Path $backendDockerfile) {
    Write-Host "Building backend image..." -ForegroundColor Gray
    docker build -f $backendDockerfile -t ai-todo-backend:latest .
    Write-Success "  ✓ Backend image built: ai-todo-backend:latest"
} else {
    Write-Warning-Custom "  ⚠ Backend Dockerfile not found at $backendDockerfile"
}

# List built images
Write-Host "`nBuilt AI TODO images:" -ForegroundColor Gray
docker images | Select-String "ai-todo"

# =============================================================================
# Phase 4: Create Kubernetes Resources
# =============================================================================
Write-Phase "Phase 4: Creating Kubernetes Resources"

# Generate random secret for BETTER_AUTH_SECRET
$authSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object {[char]$_})

# Create secrets
Write-Host "Creating Kubernetes secrets..." -ForegroundColor Gray
$secretYaml = @"
apiVersion: v1
kind: Secret
metadata:
  name: ai-todo-secrets
  namespace: $NAMESPACE
type: Opaque
stringData:
  BETTER_AUTH_SECRET: $authSecret
  COHERE_API_KEY: $COHERE_API_KEY
  DATABASE_URL: $DATABASE_URL
"@

$secretYaml | kubectl apply -f -
Write-Success "  ✓ Secrets created: ai-todo-secrets"

# Create configmap
Write-Host "Creating Kubernetes configmap..." -ForegroundColor Gray
$configYaml = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: ai-todo-config
  namespace: $NAMESPACE
data:
  NODE_ENV: production
  PYTHONUNBUFFERED: "1"
  LOG_LEVEL: info
"@

$configYaml | kubectl apply -f -
Write-Success "  ✓ ConfigMap created: ai-todo-config"

# =============================================================================
# Phase 5: Deploy with Helm
# =============================================================================
Write-Phase "Phase 5: Deploying with Helm"

$chartPath = "./infra/helm/ai-todo"

if (Test-Path $chartPath) {
    Write-Host "Building Helm dependencies..." -ForegroundColor Gray
    helm dependency build $chartPath
    
    Write-Host "Installing Helm release..." -ForegroundColor Gray
    helm install $RELEASE_NAME $chartPath --namespace $NAMESPACE --create-namespace
    Write-Success "  ✓ Helm release installed: $RELEASE_NAME"
    
    Write-Host "`nHelm releases:" -ForegroundColor Gray
    helm list --namespace $NAMESPACE
} else {
    Write-Warning-Custom "  ⚠ Helm chart not found at $chartPath"
    Write-Warning-Custom "  Skipping Helm deployment. Please create the chart or adjust the path."
}

# =============================================================================
# Phase 6: Wait for Deployment
# =============================================================================
Write-Phase "Phase 6: Waiting for Pods"

Write-Host "Waiting for pods to be ready (timeout: 300s)..." -ForegroundColor Gray
kubectl wait --for=condition=Ready pods -l component=ai-todo --timeout=300s --namespace $NAMESPACE 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Success "  ✓ All pods are ready"
} else {
    Write-Warning-Custom "  ⚠ Some pods may not be ready yet. Check with: kubectl get pods -l component=ai-todo"
}

Write-Host "`nPod status:" -ForegroundColor Gray
kubectl get pods -l component=ai-todo --namespace $NAMESPACE

# =============================================================================
# Phase 7: Configure Access
# =============================================================================
Write-Phase "Phase 7: Configuring Access"

Write-Host "`n--- ACCESS CONFIGURATION ---" -ForegroundColor Cyan

Write-Host "`n1. Add to hosts file (run in Administrator PowerShell):" -ForegroundColor Yellow
Write-Host "   Add-Content -Path `"C:\Windows\System32\drivers\etc\hosts`" -Value `"127.0.0.1 todo.local`"" -ForegroundColor White

Write-Host "`n2. Start Minikube tunnel (run in separate terminal):" -ForegroundColor Yellow
Write-Host "   minikube tunnel" -ForegroundColor White

Write-Host "`n3. Alternative: Use port-forward for testing:" -ForegroundColor Yellow
Write-Host "   kubectl port-forward svc/ai-todo-frontend 3000:80 -n $NAMESPACE" -ForegroundColor White

Write-Host "`n4. Get service URL:" -ForegroundColor Yellow
Write-Host "   minikube service ai-todo-frontend -n $NAMESPACE --url" -ForegroundColor White

# =============================================================================
# Deployment Complete
# =============================================================================
Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Phase "Deployment Complete!"
Write-Host "="*60 -ForegroundColor Green

Write-Success "`n✓ Application deployed successfully!"
Write-Host "`nAccess application at:" -ForegroundColor Cyan
Write-Host "  • http://todo.local (after hosts + tunnel)" -ForegroundColor White
Write-Host "  • Or use: minikube service ai-todo-frontend -n $NAMESPACE" -ForegroundColor White

Write-Host "`nUseful commands:" -ForegroundColor Cyan
Write-Host "  • View logs:      kubectl logs -l component=ai-todo -n $NAMESPACE" -ForegroundColor Gray
Write-Host "  • Check status:   .\test-deployment.ps1" -ForegroundColor Gray
Write-Host "  • Cleanup:        .\cleanup.ps1" -ForegroundColor Gray

Write-Host "`n" + "="*60 -ForegroundColor Green
