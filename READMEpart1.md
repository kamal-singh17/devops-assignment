# DevOps Assignment — Part 1 (Docker Compose Stack)

## Overview

This project implements a local development environment using Docker Compose.
It includes a multi-service application with observability and environment-based configuration.

The goal is to simulate a production-like setup with proper isolation, health checks, and monitoring.

---

## Architecture

The stack consists of:

* **PostgreSQL** → Database
* **API (Flask)** → Backend service exposing `/health` and `/metrics`
* **Web (Nginx)** → Frontend
* **Prometheus** → Metrics collection
* **Grafana** → Visualization
* **Loki + Promtail** → Logging

---

## Docker Compose Profiles

The stack is organized using profiles:

| Profile    | Services                            |
| ---------- | ----------------------------------- |
| core       | postgres                            |
| app        | api, web                            |
| monitoring | prometheus, grafana, loki, promtail |

---

## Project Structure

```
.
├── api/
├── web/
├── docker-compose.yml
├── environments/
│   └── local/
│       ├── .env.example
│       └── .env (not committed)
├── monitoring/
│   └── config/
│       └── prometheus.yml
├── scripts/
│   └── deploy.sh
```

---

## Environment Configuration

Environment variables are managed using:

* `environments/local/.env.example` → template (committed)
* `environments/local/.env` → actual values (not committed)

### Setup

```
cp environments/local/.env.example environments/local/.env
```

---

## Running the Stack

### Start full stack

```
./scripts/deploy.sh full
```

### Start only core + app

```
./scripts/deploy.sh start
```

### Start monitoring

```
./scripts/deploy.sh monitoring
```

### Stop services

```
./scripts/deploy.sh stop
```

---

## Health Checks

Health checks are implemented for core services:

| Service  | Healthcheck             |
| -------- | ----------------------- |
| API      | HTTP `/health` endpoint |
| Postgres | `pg_isready`            |
| Web      | HTTP check              |

Monitoring services run without strict healthchecks due to minimal container images.

---

## Verification

### Check container status

```
docker compose ps
```

All core services should be `healthy`.

---

### API check

```
curl http://localhost:5000/health
```

---

### Prometheus

```
http://localhost:9090
```

Verify API target is UP.

---

### Grafana

```
http://localhost:3001
```

Default credentials:

* username: admin
* password: admin

---

### Loki

```
curl http://localhost:3100/ready
```

Expected output:

```
ready
```

---

## Observability

* API exposes Prometheus metrics at `/metrics`
* Prometheus scrapes API metrics
* Grafana is available for visualization
* Loki + Promtail collect logs

---

## Design Decisions

* **Profiles used** to separate core, app, and monitoring components
* **Environment files** used to support multi-environment configuration
* **Health checks** implemented for critical services
* **Monitoring stack included** for visibility into system behavior

---

## Production Considerations

Docker Compose is used for local development only.

In production, this setup would be replaced with:

* Kubernetes (for orchestration)
* Managed database services
* Secure secret management (Vault / cloud secret stores)
* Scalable monitoring stack

---

## Notes

* `.env` is excluded from version control to avoid exposing sensitive data
* `.env.example` is provided for reproducibility
* Loki runs without strict healthcheck due to container limitations, and is verified via `/ready` endpoint

---
