# Secrets required for Langfuse and shared infrastructure

Create these secrets in your secrets repo (`amul-secrets-repo`) under `prod/` and sync via the secrets-sync CronWorkflow. The `namespace` in each file determines where the secret is applied.

**Note:** Postgres, Redis, ClickHouse, MinIO run externally via `external-dbs/docker-compose.yml`. No K8s secrets needed for DB credentials in `amul` namespace; credentials live in the external-dbs `.env`.

## amul-prod namespace

### langfuse-secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: langfuse-secrets
  namespace: amul-prod
type: Opaque
stringData:
  # Postgres - external (see external-dbs/)
  DATABASE_URL: "postgresql://postgres:<POSTGRES_PASSWORD>@10.5.25.36:5432/langfuse"
  # Secrets - generate via: openssl rand -hex 32
  SALT: <CHANGEME>
  ENCRYPTION_KEY: <64-char-hex>
  NEXTAUTH_SECRET: <CHANGEME>
  # ClickHouse - must match clickhouse-credentials
  CLICKHOUSE_USER: clickhouse
  CLICKHOUSE_PASSWORD: <same as clickhouse-credentials>
  # Redis - no password (cluster-internal, permissive)
  # MinIO - must match minio-credentials (for S3 buckets)
  minio-access-key: minio
  minio-secret-key: <same as minio-credentials password>
  LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID: minio
  LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY: <same as minio-credentials>
  LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID: minio
  LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY: <same as minio-credentials>
  LANGFUSE_S3_BATCH_EXPORT_ACCESS_KEY_ID: minio
  LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY: <same as minio-credentials>
  # Optional: initial Langfuse setup
  # LANGFUSE_INIT_USER_EMAIL: admin@example.com
  # LANGFUSE_INIT_USER_PASSWORD: <CHANGEME>
```

## Database layout (shared)

| Service | Postgres DB | Redis | ClickHouse DB |
|---------|-------------|-------|---------------|
| Langfuse | langfuse | (shared, key prefix) | default* |

*Langfuse uses default; langfuse DB created for future use by other services.

## amul-oan-api-prod-secrets (namespace: amul-prod)

From amul_env - all uncommented sensitive vars. Non-sensitive (Redis, Marqo URL, LLM provider, etc.) are in ConfigMap.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: amul-oan-api-prod-secrets
  namespace: amul-prod
type: Opaque
stringData:
  LANGFUSE_SECRET_KEY: "sk-xxxx"
  LANGFUSE_PUBLIC_KEY: "pk-xxxx"
  MEITY_API_KEY_VALUE: "xxxx"
  OPENAI_API_KEY: "xxxx"
  ANTHROPIC_API_KEY: "xxxx"
  GEMINI_API_KEY: "xxxx"
  PASHUGPT_TOKEN: "xxxx"
  PASHUGPT_TOKEN_2: "xxxx"
  PASHUGPT_TOKEN_3: "xxxx"
  FIREBASE_SERVICE_ACCOUNT_PATH: "xxxx"   # or path to mounted file
  FIREBASE_SERVICE_ACCOUNT_PATH_2: "xxxx"
  JWT_PRIVATE_KEY_PATH: "xxxx"
  APP_FE_URL: "https://xxxx"
```

## OAN-UI Dockerfile (OpenAgriNet/OAN-UI repo)

The OAN-UI repo needs a `Dockerfile` (see `OAN-UI/Dockerfile` in this repo) that accepts build args:
- `VITE_API_BASE_URL` – API URL baked at build
- `VITE_VOICE_OAN_MODE` – `true` for voice FE, empty for chat FE

Copy or merge it into the OAN-UI repo and push to amul-prod and amul-prod-voice branches.

### voice-oan-api-prod-secrets (namespace: amul-prod)

From voice-env - all uncommented sensitive vars.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: voice-oan-api-prod-secrets
  namespace: amul-prod
type: Opaque
stringData:
  SECRET_KEY: "xxxx"
  ALLOWED_ORIGINS: '["*"]'
  JWT_PUBLIC_KEY_PATH: "jwt_public_key.pem"
  OPENAI_API_KEY: "xxxx"
  PASHUGPT_TOKEN: "xxxx"
  PASHUGPT_TOKEN_2: "xxxx"
  PASHUGPT_TOKEN_3: "xxxx"
  LANGFUSE_SECRET_KEY: "sk-xxxx"
  LANGFUSE_PUBLIC_KEY: "pk-xxxx"
```
