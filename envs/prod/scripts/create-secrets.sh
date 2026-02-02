#!/bin/bash
# Create secrets on the server via kubectl.
# Run this from a machine with cluster access. Set env vars before running, or use a local
# .env.secrets file (gitignored) with: source .env.secrets && ./create-secrets.sh
set -e

NAMESPACE=amul-prod

# Ensure namespace exists
kubectl get namespace "$NAMESPACE" || kubectl create namespace "$NAMESPACE"

echo "Creating regcred (image pull)..."
kubectl create secret docker-registry regcred \
  --docker-server="${REGISTRY_SERVER:-dev-amulmitra.amul.com}" \
  --docker-username="${REGISTRY_USERNAME}" \
  --docker-password="${REGISTRY_PASSWORD}" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating langfuse-secrets..."
kubectl create secret generic langfuse-secrets -n "$NAMESPACE" \
  --from-literal=DATABASE_URL="${LANGFUSE_DATABASE_URL}" \
  --from-literal=SALT="${LANGFUSE_SALT}" \
  --from-literal=ENCRYPTION_KEY="${LANGFUSE_ENCRYPTION_KEY}" \
  --from-literal=NEXTAUTH_SECRET="${LANGFUSE_NEXTAUTH_SECRET}" \
  --from-literal=CLICKHOUSE_USER="${CLICKHOUSE_USER:-clickhouse}" \
  --from-literal=CLICKHOUSE_PASSWORD="${CLICKHOUSE_PASSWORD}" \
  --from-literal=minio-access-key="${MINIO_ROOT_USER:-minio}" \
  --from-literal=minio-secret-key="${MINIO_ROOT_PASSWORD}" \
  --from-literal=LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID="${MINIO_ROOT_USER:-minio}" \
  --from-literal=LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}" \
  --from-literal=LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID="${MINIO_ROOT_USER:-minio}" \
  --from-literal=LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}" \
  --from-literal=LANGFUSE_S3_BATCH_EXPORT_ACCESS_KEY_ID="${MINIO_ROOT_USER:-minio}" \
  --from-literal=LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating amul-oan-api-prod-secrets..."
kubectl create secret generic amul-oan-api-prod-secrets -n "$NAMESPACE" \
  --from-literal=LANGFUSE_SECRET_KEY="${AMUL_LANGFUSE_SECRET_KEY}" \
  --from-literal=LANGFUSE_PUBLIC_KEY="${AMUL_LANGFUSE_PUBLIC_KEY}" \
  --from-literal=MEITY_API_KEY_VALUE="${AMUL_MEITY_API_KEY_VALUE}" \
  --from-literal=OPENAI_API_KEY="${AMUL_OPENAI_API_KEY}" \
  --from-literal=ANTHROPIC_API_KEY="${AMUL_ANTHROPIC_API_KEY}" \
  --from-literal=GEMINI_API_KEY="${AMUL_GEMINI_API_KEY}" \
  --from-literal=PASHUGPT_TOKEN="${AMUL_PASHUGPT_TOKEN}" \
  --from-literal=PASHUGPT_TOKEN_2="${AMUL_PASHUGPT_TOKEN_2}" \
  --from-literal=PASHUGPT_TOKEN_3="${AMUL_PASHUGPT_TOKEN_3}" \
  --from-literal=FIREBASE_SERVICE_ACCOUNT_PATH="${AMUL_FIREBASE_SERVICE_ACCOUNT_PATH:-}" \
  --from-literal=FIREBASE_SERVICE_ACCOUNT_PATH_2="${AMUL_FIREBASE_SERVICE_ACCOUNT_PATH_2:-}" \
  --from-literal=JWT_PRIVATE_KEY_PATH="${AMUL_JWT_PRIVATE_KEY_PATH:-}" \
  --from-literal=APP_FE_URL="${AMUL_APP_FE_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating voice-oan-api-prod-secrets..."
kubectl create secret generic voice-oan-api-prod-secrets -n "$NAMESPACE" \
  --from-literal=SECRET_KEY="${VOICE_SECRET_KEY}" \
  --from-literal=ALLOWED_ORIGINS="${VOICE_ALLOWED_ORIGINS:-[\"*\"]}" \
  --from-literal=JWT_PUBLIC_KEY_PATH="${VOICE_JWT_PUBLIC_KEY_PATH:-jwt_public_key.pem}" \
  --from-literal=OPENAI_API_KEY="${VOICE_OPENAI_API_KEY}" \
  --from-literal=PASHUGPT_TOKEN="${VOICE_PASHUGPT_TOKEN}" \
  --from-literal=PASHUGPT_TOKEN_2="${VOICE_PASHUGPT_TOKEN_2}" \
  --from-literal=PASHUGPT_TOKEN_3="${VOICE_PASHUGPT_TOKEN_3}" \
  --from-literal=LANGFUSE_SECRET_KEY="${VOICE_LANGFUSE_SECRET_KEY}" \
  --from-literal=LANGFUSE_PUBLIC_KEY="${VOICE_LANGFUSE_PUBLIC_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Done. Verify with: kubectl get secrets -n $NAMESPACE"
