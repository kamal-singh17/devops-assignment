# devops-assignment
End-to-end DevOps platform with Docker, Kubernetes (Kind), ArgoCD GitOps, Helm, Kustomize, and Observability stack




# 🚀 DevOps Platform — End-to-End GitOps Implementation

---

# 📌 1. Objective

This repository demonstrates a **production-style DevOps platform** for a microservices-based application, covering:

* Local development using Docker Compose
* Kubernetes deployment on Kind (single-node cluster)
* GitOps-based delivery using ArgoCD
* Infrastructure management via Helm wrappers
* Application configuration via Kustomize overlays
* Zero-trust networking using NetworkPolicies
* Observability stack (Prometheus, Grafana, Loki)
* CI pipeline with linting, build, security scan, and deployment

> ⚠️ Note: Application code is intentionally minimal. Focus is on platform engineering.

---

# 🧱 2. Architecture

```
Developer → Git → GitHub Actions → ArgoCD → Kind Cluster
                                              |
        ┌────────────┬────────────┬────────────┐
        │            │            │
     Postgres       API          Web
        │
   Prometheus → Grafana
        │
      Loki ← Promtail
```

---

# ⚙️ 3. Prerequisites

Ensure the following tools are installed:

```bash
docker
kubectl
kind (>= 0.22)
helm (>= 3.13)
kustomize (>= 5.0)
trivy
mkcert
```

Optional:

```bash
argocd CLI
node (>=20), python (>=3.11)
```

---

# 📁 4. Repository Structure

```
api/
web/
docker-compose.yml
environments/local/.env.example

helm/charts/          # Helm wrappers (infra)
k8s/base/             # Base manifests
k8s/overlays/dev/     # Dev environment
k8s/overlays/qat/     # QAT environment

monitoring/
  ├── dashboards/
  └── rules/

argocd/
scripts/
```

---

# 🐳 5. Part 1 — Docker Compose (Local Development)

## Setup

```bash
cp environments/local/.env.example environments/local/.env
```

Edit `.env` if required.

---

## Run Stack

```bash
docker compose --profile core --profile app --profile monitoring up -d
```

---

## Verify

```bash
docker compose ps
```

All services must be **healthy within ~60 seconds**.

---

## Services

| Service    | URL                   |
| ---------- | --------------------- |
| Web        | http://localhost:3000 |
| API        | http://localhost:5000 |
| Grafana    | http://localhost:3001 |
| Prometheus | http://localhost:9090 |

---

## Deployment Script

```bash
chmod +x scripts/deploy.sh
```

```bash
./scripts/deploy.sh start
./scripts/deploy.sh stop
./scripts/deploy.sh restart
./scripts/deploy.sh pause
```

---

# ☸️ 6. Part 2 — Kind + Helm + Kustomize

## Cluster Creation

```bash
./scripts/bootstrap-kind.sh
```

This performs:

* Kind cluster creation
* Ingress setup
* Monitoring stack installation
* Loki + Promtail deployment
* Application deployment

---

## Manual Alternative

```bash
kind create cluster --config kind-config.yaml
kubectl apply -k k8s/overlays/dev
```

---

## Verify Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

All pods must be:

```
Running / Completed
```

---

## Helm Wrappers Used

Located under `helm/charts/`:

* ingress-nginx
* kube-prometheus-stack
* loki + promtail

> These are wrapped Helm charts (not raw upstream usage) for controlled configuration.

---

## Kustomize Layout

```
k8s/base/         → reusable configs
k8s/overlays/dev  → dev config (low resources)
k8s/overlays/qat  → qat config (custom domain)
```

---

## Security (Restricted PSS)

All workloads enforce:

```yaml
runAsNonRoot: true
allowPrivilegeEscalation: false
capabilities:
  drop: ["ALL"]
```

---

## Resource Limits

All containers define:

```yaml
resources:
  requests:
    cpu: 100m
  limits:
    cpu: 500m
```

---

## Network Policies (Zero Trust)

* Default deny all traffic
* Explicit allow rules between services

---

# 🔁 7. Part 3 — GitOps with ArgoCD

## Install ArgoCD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## Access UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Step  Get password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

---

## 🧠 Why ArgoCD?

* Git = source of truth
* Automated deployments
* Easy rollback

---

## ApplicationSets

Located in `argocd/`:

* `dev` → k8s/overlays/dev
* `qat` → k8s/overlays/qat

---

## Sync Waves

| Wave | Component           |
| ---- | ------------------- |
| 0    | ingress, namespaces |
| 1    | monitoring          |
| 2    | loki                |
| 10   | postgres            |
| 20   | api, web            |

---

## Deployment Flow

```
git push → ArgoCD auto-sync → cluster updated
```

---

## Test Deployment

1. Update API image tag
2. Push to repository
3. Verify ArgoCD auto-sync

---

## Rollback

Performed via ArgoCD UI:

* Select application
* Choose previous revision
* Click rollback

---

# 📊 8. Part 4 — Observability

## Metrics (Prometheus)

Scrapes:

* kubelet
* node-exporter
* kube-state-metrics
* API `/metrics`

---

## Logs (Loki)

* Promtail collects logs
* Loki stores logs
* View via Grafana → Explore

---

## Grafana

Access:

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```



## Prometheus

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090

kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 19090:9090
---

## Dashboard

Provisioned via:

```
monitoring/dashboards/
```

Includes:

* Node CPU / Memory
* Pod restarts
* API logs

---

## Alerts

Defined in:

```
monitoring/rules/
```

Example:

```yaml
alert: HighCPUUsage
expr: rate(node_cpu_seconds_total{mode!="idle"}[1m]) > 0.8
for: 1m
```

---

## Trigger Alert

```bash
while true; do curl http://api-dev:5000; done
```

Verify:

* Prometheus → Alerts → FIRING

---

# 🧪 9. Validation Checklist (MANDATORY)

Run the following:

```bash
./scripts/bootstrap-kind.sh
```

Then manually verify:

```bash
kubectl get pods -A
kubectl get svc -A
```

---

## Must Pass

* All pods Running ✅
* Prometheus targets UP ✅
* Grafana dashboards load ✅
* Logs visible in Loki ✅
* Alerts firing ✅

---

# ⚠️ 10. Known Limitations

* Single-node cluster (Kind limitation)
* Loki UI may have minor inconsistencies (logs verified via API)
* No external DNS (port-forward used)

---

# 🔮 11. What I Would Add Next

1. API latency SLO alerts
2. Error rate tracking (5xx monitoring)
3. Log-based alerts using Loki
4. Distributed tracing (Jaeger / Tempo)
5. HPA based on custom metrics

---

# 🤖 12. CI Pipeline (GitHub Actions)

Pipeline includes:

* Linting (YAML, Dockerfiles)
* Image build
* Trivy security scan
* Push to registry
* Deployment trigger via GitOps

---

# 🏁 13. Final Status

| Feature        | Status |
| -------------- | ------ |
| Docker Compose | ✅      |
| Kubernetes     | ✅      |
| GitOps         | ✅      |
| Monitoring     | ✅      |
| Logging        | ✅      |
| Alerts         | ✅      |

---

# 🙌 Conclusion

This project demonstrates:

* Real-world DevOps architecture
* GitOps deployment strategy
* Secure and observable platform design
* End-to-end automation from local to Kubernetes

---

# 📎 Reviewer Notes

* Use `scripts/bootstrap-kind.sh` for full setup
* No manual steps required beyond prerequisites
* All configurations are reproducible

---

