# VM Architecture & Workload Distribution

Based on `vm_resources_summary.txt`. Update IPs to match your environment.

---

## VM summary

| VM | Cores | RAM | Load | Suggested role |
|----|-------|-----|------|----------------|
| **vm2-db** | 8 | 31Gi (30Gi free) | Very low | Postgres, Redis, MinIO |
| **vm3-uintele** | 4 | 15Gi | Low | Jump host |
| **vm4-dashboard** | ? | ? | Unreachable | Grafana, telemetry dashboard (when up) |
| **vm5-ai-backend** | 4 | 15Gi | **High** (12+) | K8s workers, backends – avoid adding more |
| **vm6-ai-vecdb** | 8 | 31Gi (24Gi free) | Low | ClickHouse, Marqo (vector/analytics) |

---

## Recommended split

### Option A: All DBs on vm2-db (simpler)
- **vm2-db** (10.5.25.36): Postgres, Redis, ClickHouse, MinIO
- **vm6** (10.5.25.44): Marqo only (already there)
- Good if load is light; vm2 has enough capacity.

### Option B: Split analytics to vm6 (recommended)
- **vm2-db** (10.5.25.36): Postgres, Redis, MinIO  
  → Transactional DBs + object storage  
- **vm6-ai-vecdb** (10.5.25.44): ClickHouse, Marqo  
  → Vector/analytics workloads together  

**Why split:**
- ClickHouse can be CPU/memory heavy under analytics load.
- vm6 is already used for vector DB (Marqo).
- vm2 stays focused on transactional workloads.

---

## IP mapping (update to match your setup)

| Host | IP | Workloads |
|------|-----|-----------|
| vm2-db | 10.5.25.36 | Postgres, Redis, MinIO (Option B) or all DBs (Option A) |
| vm6-ai-vecdb | 10.5.25.44 | Marqo, ClickHouse (Option B only) |

---

## Docker Compose layout

### Option A – single host
Run `external-dbs/docker-compose.yml` on vm2-db. All services use 10.5.25.36.

### Option B – split
1. **vm2-db**: Create `external-dbs/docker-compose-db-only.yml` (Postgres, Redis, MinIO).
2. **vm6**: Create `external-dbs/docker-compose-analytics.yml` (ClickHouse) – Marqo already runs here.
3. Update K8s ConfigMaps: ClickHouse URLs → 10.5.25.44; Postgres/Redis/MinIO → 10.5.25.36.

---

## Capacity check (vm2-db for all four)

| Service | Est. RAM | Est. CPU |
|---------|----------|----------|
| Postgres | 512Mi–2Gi | 0.25–1 |
| Redis | 256–512Mi | 0.1–0.5 |
| MinIO | 256–512Mi | 0.1–0.5 |
| ClickHouse | 512Mi–4Gi | 0.25–2 |
| **Total** | ~2–7Gi | ~0.7–4 |

vm2-db has 30Gi free – sufficient for all four if load stays moderate. Split is recommended if you expect heavy Langfuse/ClickHouse usage.
