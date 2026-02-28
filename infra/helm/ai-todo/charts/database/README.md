# Database Subchart - External Neon PostgreSQL

## Overview

This subchart is a **placeholder** for the external Neon PostgreSQL database used by the AI Todo Chatbot application.

## External Database Configuration

The application connects to an external **Neon PostgreSQL** managed database service. Connection details are provided via Kubernetes Secrets.

### Required Secret

Create the `ai-todo-secrets` Secret with the following key:

```bash
kubectl create secret generic ai-todo-secrets \
  --from-literal=DATABASE_URL="postgresql://user:password@host.neon.tech/dbname?sslmode=require"
```

### Neon PostgreSQL Setup

1. Create a Neon project at https://neon.tech
2. Create a new database or use the default `neondb`
3. Copy the connection string from the Neon dashboard
4. Store the connection string in Kubernetes Secrets (see above)

### Connection String Format

```
postgresql://[user]:[password]@[host].neon.tech/[dbname]?sslmode=require
```

### SSL Mode

Neon requires SSL connections. Ensure `sslmode=require` is included in the connection string.

## Why External Database?

- **Managed Service**: Neon handles backups, scaling, and maintenance
- **Serverless**: Pay-per-use pricing model
- **Branching**: Database branching for development/testing
- **Global**: Low-latency access from anywhere

## Alternative: Local PostgreSQL

For local development without Neon, you can:

1. Deploy a local PostgreSQL chart (e.g., Bitnami PostgreSQL)
2. Update the DATABASE_URL secret to point to the local service
3. Modify the backend connection configuration accordingly

## Troubleshooting

### Connection Issues

1. Verify the DATABASE_URL secret is correctly set:
   ```bash
   kubectl get secret ai-todo-secrets -o jsonpath='{.data.DATABASE_URL}' | base64 -d
   ```

2. Check backend pod logs for connection errors:
   ```bash
   kubectl logs -l app.kubernetes.io/name=backend
   ```

3. Test connectivity from within the cluster:
   ```bash
   kubectl run -it --rm debug --image=postgres:15 --restart=Never -- psql $DATABASE_URL
   ```

### SSL Certificate Issues

If you encounter SSL certificate verification errors, ensure:
- The connection string includes `sslmode=require`
- Your Neon project is properly configured
- The backend has the necessary CA certificates
