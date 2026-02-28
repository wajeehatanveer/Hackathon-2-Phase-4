# AI Todo Chatbot - Kubernetes Deployment Script
# This script deploys the application to Minikube using Helm

param(
    [string]$Namespace = "default",
    [switch]$Verbose
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AI Todo Chatbot - Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify prerequisites
Write-Host "[1/8] Verifying prerequisites..." -ForegroundColor Yellow

# Check Minikube status
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Minikube is not running. Start it with: minikube start" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Minikube cluster is running" -ForegroundColor Green

# Check Docker images
$frontendImage = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String "ai-todo-frontend:latest"
$backendImage = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String "ai-todo-backend:latest"

if (-not $frontendImage) {
    Write-Host "ERROR: Frontend Docker image not found. Build it first." -ForegroundColor Red
    exit 1
}
if (-not $backendImage) {
    Write-Host "ERROR: Backend Docker image not found. Build it first." -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Docker images found" -ForegroundColor Green

# Check environment variables
$requiredVars = @("COHERE_API_KEY", "DATABASE_URL", "BETTER_AUTH_SECRET")
$missingVars = @()

foreach ($var in $requiredVars) {
    if (-not (Test-Path "env:$var")) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "ERROR: Missing environment variables: $($missingVars -join ', ')" -ForegroundColor Red
    Write-Host "Please set these environment variables and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ Environment variables configured" -ForegroundColor Green

# Step 2: Load images into Minikube
Write-Host ""
Write-Host "[2/8] Loading Docker images into Minikube..." -ForegroundColor Yellow
minikube image load ai-todo-frontend:latest 2>&1 | Out-Null
minikube image load ai-todo-backend:latest 2>&1 | Out-Null
Write-Host "  ✓ Images loaded" -ForegroundColor Green

# Step 3: Create Kubernetes Secret
Write-Host ""
Write-Host "[3/8] Creating Kubernetes Secret..." -ForegroundColor Yellow
$secretExists = kubectl get secret ai-todo-secrets 2>&1 | Select-String "NotFound"

if ($secretExists) {
    kubectl create secret generic ai-todo-secrets `
        --from-literal=BETTER_AUTH_SECRET=$env:BETTER_AUTH_SECRET `
        --from-literal=COHERE_API_KEY=$env:COHERE_API_KEY `
        --from-literal=DATABASE_URL=$env:DATABASE_URL `
        --namespace=$Namespace 2>&1 | Out-Null
    Write-Host "  ✓ Secret created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Secret already exists" -ForegroundColor Green
}

# Step 4: Create ConfigMap
Write-Host ""
Write-Host "[4/8] Creating ConfigMap..." -ForegroundColor Yellow
$configMapExists = kubectl get configmap ai-todo-config 2>&1 | Select-String "NotFound"

if ($configMapExists) {
    kubectl create configmap ai-todo-config `
        --from-literal=NODE_ENV=production `
        --from-literal=PYTHONUNBUFFERED=1 `
        --from-literal=LOG_LEVEL=info `
        --namespace=$Namespace 2>&1 | Out-Null
    Write-Host "  ✓ ConfigMap created" -ForegroundColor Green
} else {
    Write-Host "  ✓ ConfigMap already exists" -ForegroundColor Green
}

# Step 5: Configure host alias
Write-Host ""
Write-Host "[5/8] Configuring host alias for todo.local..." -ForegroundColor Yellow
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$hostEntry = "127.0.0.1 todo.local"

$hostsContent = Get-Content $hostsFile -Raw
if ($hostsContent -notlike "*$hostEntry*") {
    Write-Host "  Adding host entry (requires Administrator)..." -ForegroundColor Yellow
    try {
        Add-Content -Path $hostsFile -Value "`n$hostEntry" -Force
        Write-Host "  ✓ Host alias added" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not add host alias. Run this script as Administrator or add manually:" -ForegroundColor Yellow
        Write-Host "    Add-Content -Path '$hostsFile' -Value '$hostEntry'" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✓ Host alias already configured" -ForegroundColor Green
}

# Step 6: Build Helm dependencies
Write-Host ""
Write-Host "[6/8] Building Helm dependencies..." -ForegroundColor Yellow
helm dependency build ./infra/helm/ai-todo 2>&1 | Out-Null
Write-Host "  ✓ Dependencies built" -ForegroundColor Green

# Step 7: Deploy with Helm
Write-Host ""
Write-Host "[7/8] Deploying with Helm..." -ForegroundColor Yellow

# Check if release exists
$releaseExists = helm list --namespace=$Namespace 2>&1 | Select-String "ai-todo"

if ($releaseExists) {
    Write-Host "  Upgrading existing release..." -ForegroundColor Yellow
    helm upgrade ai-todo ./infra/helm/ai-todo --namespace=$Namespace --wait --timeout=5m 2>&1 | Out-Null
} else {
    Write-Host "  Installing new release..." -ForegroundColor Yellow
    helm install ai-todo ./infra/helm/ai-todo --namespace=$Namespace --wait --timeout=5m 2>&1 | Out-Null
}

Write-Host "  ✓ Deployment complete" -ForegroundColor Green

# Step 8: Verify deployment
Write-Host ""
Write-Host "[8/8] Verifying deployment..." -ForegroundColor Yellow

# Wait for pods to be ready
Write-Host "  Waiting for pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/part-of=ai-todo --timeout=300s --namespace=$Namespace 2>&1 | Out-Null

# Get deployment status
Write-Host ""
Write-Host "Deployment Status:" -ForegroundColor Cyan
helm list --namespace=$Namespace
Write-Host ""

Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -l app.kubernetes.io/part-of=ai-todo --namespace=$Namespace
Write-Host ""

Write-Host "Services:" -ForegroundColor Cyan
kubectl get services -l app.kubernetes.io/part-of=ai-todo --namespace=$Namespace
Write-Host ""

Write-Host "Ingress:" -ForegroundColor Cyan
kubectl get ingress --namespace=$Namespace
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start Minikube tunnel in a separate terminal:" -ForegroundColor White
Write-Host "   minikube tunnel" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Access the application at:" -ForegroundColor White
Write-Host "   http://todo.local" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Monitor pods:" -ForegroundColor White
Write-Host "   kubectl get pods -l app.kubernetes.io/part-of=ai-todo --watch" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
