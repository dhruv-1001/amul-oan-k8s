# Before Deploy – Checklist

Complete these items before applying the K8s manifests.

---

## 1. External DBs (run first)

- [ ] **VM layout** – See `VM_ARCHITECTURE.md` for workload distribution (vm2-db vs vm6 split for ClickHouse+Marqo).

- [ ] **Start external DBs** – On vm2-db (and optionally vm6 for ClickHouse if splitting):
  ```bash
  cd external-dbs
  cp .env.example .env
  # Edit .env with passwords
  docker compose up -d
  docker compose --profile init run --rm minio-init
  ```
- [ ] **DB host IP** – All configs use `10.5.25.36` as the external DB host. Update in ConfigMaps and secrets if your DB host has a different IP.

## 2. Cluster & nodes

- [ ] **Node labels** – Ensure nodes have:
  - `role: infrastructure` (Prometheus, Grafana, Loki, nginx-gateway, docker-registry)
  - `role: backend` (amul-oan-api, voice-oan-api, Langfuse, OAN-UI)
  - `role: dashboard` (Grafana, if different from infrastructure)

- [ ] **Host paths** – Create and set permissions for PV hostPaths:
  - `/data/prometheus`
  - `/data/grafana`
  - `/data/loki`
  - `/data/registry`
  - `/var/www/acme-challenge` (for Certbot/ACME)

---

## 3. Secrets (create on server)

- [ ] **Create secrets on the server** – SSH to the cluster admin node and run `kubectl create secret` or apply from local YAML files. See `envs/prod/services/SECRETS.md` for the list and `envs/prod/scripts/create-secrets.sh` for helper commands.

  | Secret                         | Namespace | Used by                                   |
  |--------------------------------|-----------|-------------------------------------------|
  | amul-oan-api-prod-secrets      | amul-prod | amul-oan-api                              |
  | voice-oan-api-prod-secrets     | amul-prod | voice-oan-api                             |
  | langfuse-secrets               | amul-prod | Langfuse                                  |

  DB credentials (Postgres, ClickHouse, MinIO) live in `external-dbs/.env` on the DB host, not in K8s.

- [ ] **regcred** – Create image-pull secret in `amul-prod`:
  ```bash
  kubectl create secret docker-registry regcred \
    --docker-server=dev-amulmitra.amul.com \
    --docker-username=<user> \
    --docker-password=<password> \
    -n amul-prod
  ```

---

## 4. OAN-UI Dockerfile

- [ ] **Dockerfile in OAN-UI repo** – Copy `OAN-UI/Dockerfile` from this repo into [OpenAgriNet/OAN-UI](https://github.com/OpenAgriNet/OAN-UI) (supports `VITE_API_BASE_URL` and `VITE_VOICE_OAN_MODE` build args).

- [ ] **Push to branches** – Ensure the Dockerfile exists on both:
  - `amul-prod`
  - `amul-prod-voice`

---

## 5. Argo / CI prerequisites

- [ ] **Argo Workflows** – Installed and running in `argocd` namespace.

- [ ] **ArgoCD** (if used) – Installed for GitOps sync.

- [ ] **Workflow templates** – Apply:
  - `common/cicd/templates/build-kaniko.yaml`
  - `common/cicd/templates/build-oan-ui.yaml`

- [ ] **RBAC** – Apply:
  - `common/cicd/workflow-rbac.yaml`
  - `common/cicd/workflow-executor-rbac.yaml`

- [ ] **ci-builder** – ServiceAccount with permissions to build (Kaniko) and run `kubectl set image`.


---

## 6. DNS & TLS

- [ ] **DNS** – A records for:
  - `api.prod.amulai.in` → nginx gateway
  - `voice.prod.amulai.in` → nginx gateway
  - `app.prod.amulai.in` → nginx gateway
  - `voice-ui.prod.amulai.in` → nginx gateway
  - `langfuse.prod.amulai.in` → nginx gateway
  - `hello.prod.amulai.in` (for cert validation)

- [ ] **Certbot / TLS** – Prod nginx uses Let’s Encrypt certs from `/etc/letsencrypt/live/prod.amulai.in/`. Run the certbot Job/CronJob (see `envs/prod/infrastructure/`) or mount existing certs.

---

## 7. External dependencies

- [ ] **Marqo** – amul-oan-api and voice-oan-api use `MARQO_ENDPOINT_URL` (default `http://10.5.25.44:8882`). Ensure Marqo is reachable from the cluster.

- [ ] **Registry** – `dev-amulmitra.amul.com` reachable from cluster for image pulls.

---

## 8. Apply order

1. External DBs (docker compose up in external-dbs/)  
2. Namespaces  
3. Secrets (create on server via kubectl)  
4. Langfuse (web + worker)  
5. amul-oan-api, voice-oan-api  
6. OAN-UI chat, OAN-UI voice (or let CI build and deploy)  
7. Prod nginx gateway, nginx config  
8. CI triggers (CronWorkflows)

---

## 9. First-time image builds

Before deployments can pull images, CI must build them at least once:

- amul-oan-api  
- voice-oan-api  
- oan-ui-chat  
- oan-ui-voice  

Ensure the CI CronWorkflows are applied; they will build on the next run when the image does not exist.
