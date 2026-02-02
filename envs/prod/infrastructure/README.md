# Prod Infrastructure - *.prod.amulai.in Wildcard Setup

## Overview

Wildcard certificate for `*.prod.amulai.in` is issued via **certbot** with Cloudflare DNS-01. Certs are stored in a hostPath volume at `/data/letsencrypt-prod-amulai` and mounted by nginx. `hello.prod.amulai.in` serves "hello world" for validation.

## Prerequisites

- **Cloudflare API token** with `Zone - DNS - Edit` and `Zone - Zone - Read` (stored in `cloudflare-key`)

## Deployment Order

```bash
# 1. Create certbot Cloudflare credentials secret
bash create-certbot-credentials.sh

# 2. Run certbot Job to obtain initial cert
kubectl apply -f certbot-job.yaml
kubectl wait --for=condition=complete job/certbot-obtain-prod-amulai -n amul --timeout=300s

# 3. Apply nginx config and gateway (mounts same volume)
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-gateway.yaml

# 4. Schedule renewal (runs daily at 3am)
kubectl apply -f certbot-cronjob.yaml
```

## Validation

```bash
curl -I http://hello.prod.amulai.in   # 301 → HTTPS
curl https://hello.prod.amulai.in     # hello world
```

## Files

| File | Purpose |
|------|---------|
| `cloudflare-key` | Cloudflare API token |
| `create-certbot-credentials.sh` | Creates K8s Secret from cloudflare-key |
| `certbot-job.yaml` | One-time Job to obtain cert |
| `certbot-cronjob.yaml` | Daily CronJob to renew cert |
| `nginx-configmap.yaml` | Nginx config |
| `nginx-gateway.yaml` | Nginx gateway deployment |
