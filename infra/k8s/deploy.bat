@echo off
REM AI Todo Chatbot - Kubernetes Deployment Script
REM This script deploys the application using raw Kubernetes manifests

echo ========================================
echo AI Todo Chatbot - Kubernetes Deployment
echo ========================================
echo.

REM Step 1: Verify prerequisites
echo [1/6] Verifying prerequisites...
kubectl cluster-info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Kubernetes cluster not accessible. Start Minikube first.
    exit /b 1
)
echo   ✓ Kubernetes cluster accessible
echo.

REM Step 2: Apply secrets
echo [2/6] Creating Secrets...
kubectl apply -f infra/k8s/secrets.yaml
if %errorlevel% neq 0 (
    echo WARNING: Secrets creation failed. Update values in secrets.yaml first.
)
echo   ✓ Secrets configured
echo.

REM Step 3: Apply ConfigMap
echo [3/6] Creating ConfigMap...
kubectl apply -f infra/k8s/configmap.yaml
echo   ✓ ConfigMap created
echo.

REM Step 4: Apply deployments
echo [4/6] Deploying applications...
kubectl apply -f infra/k8s/backend-deployment.yaml
kubectl apply -f infra/k8s/frontend-deployment.yaml
echo   ✓ Deployments created
echo.

REM Step 5: Apply services and HPA
echo [5/6] Creating Services and HPA...
kubectl apply -f infra/k8s/services.yaml
kubectl apply -f infra/k8s/hpa.yaml
echo   ✓ Services and HPA created
echo.

REM Step 6: Apply ingress and RBAC
echo [6/6] Creating Ingress and NetworkPolicy...
kubectl apply -f infra/k8s/ingress.yaml
kubectl apply -f infra/k8s/rbac.yaml
echo   ✓ Ingress and NetworkPolicy created
echo.

REM Wait for deployments
echo Waiting for deployments to be ready...
timeout /t 30 /nobreak >nul

echo.
echo ========================================
echo Deployment Status:
echo ========================================
kubectl get pods -l app.kubernetes.io/name=ai-todo
kubectl get deployments
kubectl get ingress
echo.
echo ========================================
echo DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Start Minikube tunnel: minikube tunnel
echo 2. Access application: http://todo.local
echo.
