#!/bin/bash
# Creates the certbot Cloudflare credentials secret from cloudflare-key.
# Run once before the certbot Job.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN=$(cat "${SCRIPT_DIR}/cloudflare-key")
kubectl create secret generic certbot-cloudflare-credentials -n amul \
  --from-literal=credentials.ini="dns_cloudflare_api_token = ${TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "Secret certbot-cloudflare-credentials created/updated in namespace amul"
