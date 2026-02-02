# External DBs – Docker Compose

Run Postgres, Redis, ClickHouse, and MinIO on a dedicated VM (e.g. vm2-db). K8s apps connect via the VM’s IP.

## Quick start

```bash
cp .env.example .env
# Edit .env with real passwords

docker compose up -d

# Create MinIO langfuse bucket (one-time)
docker compose --profile init run --rm minio-init
```

## Ports

| Service   | Host port(s)       |
|-----------|--------------------|
| Postgres  | 5432               |
| Redis     | 6379               |
| ClickHouse| 8123 (HTTP), 9002 (native) |
| MinIO     | 9000 (API), 9001 (console) |

## Databases

- **Postgres**: `postgres` (default), `langfuse`
- **ClickHouse**: `default`, `langfuse`
- **MinIO**: `langfuse` bucket (created by minio-init)
- **Redis**: no password; services use DB indices 0–15 or key prefixes

## K8s connection strings

When running externally, use the VM IP (e.g. `10.5.25.36`) in K8s ConfigMaps/secrets:

| Service   | URL example                                                         |
|-----------|---------------------------------------------------------------------|
| Postgres  | `postgresql://postgres:PASSWORD@10.5.25.36:5432/langfuse`          |
| Redis     | `10.5.25.36:6379`                                                  |
| ClickHouse| `http://10.5.25.36:8123` (HTTP), `clickhouse://10.5.25.36:9002` (native) |
| MinIO     | `http://10.5.25.36:9000`                                           |

## Volumes

Data is stored in Docker named volumes. Back up from `/var/lib/docker/volumes/external-dbs_*` or use `docker compose down -v` only when removing data.

## Network

Bind all services to `0.0.0.0` (or omit `ports` if using host network). Ensure firewall allows the VM IP from K8s nodes.
