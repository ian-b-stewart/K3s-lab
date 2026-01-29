# Week 4: Helm Package Manager

## Learning Objectives

By the end of this week, you will understand:
- What Helm is and why it's useful
- How to find and install charts
- Customizing charts with values
- Managing releases

## Prerequisites

- Completed Weeks 1-3
- Helm installed (`./scripts/03-install-helm.sh`)

---

## Exercises

### Exercise 1: Helm Basics

```bash
# Check Helm version
helm version

# List configured repositories
helm repo list

# Search for charts
helm search hub nginx
helm search repo nginx

# Get information about a chart
helm show chart bitnami/nginx
helm show readme bitnami/nginx
helm show values bitnami/nginx > nginx-all-values.yaml
```

---

### Exercise 2: Install a Chart

```bash
# Create a namespace
kubectl create namespace helm-demo

# Install nginx (basic)
helm install my-nginx bitnami/nginx -n helm-demo

# Watch pods
kubectl get pods -n helm-demo -w

# List releases
helm list -n helm-demo

# Get release status
helm status my-nginx -n helm-demo

# Get the service URL
kubectl get svc -n helm-demo my-nginx

# Test it
kubectl port-forward -n helm-demo svc/my-nginx 8080:80 &
curl http://localhost:8080

# Uninstall
helm uninstall my-nginx -n helm-demo
```

---

### Exercise 3: Customize with Values

```bash
# Install with custom values file
helm install prometheus prometheus-community/prometheus \
  -n helm-demo \
  -f values/prometheus-values.yaml

# Wait for pods
kubectl get pods -n helm-demo -w

# Port forward to Prometheus UI
kubectl port-forward -n helm-demo svc/prometheus-server 9090:80 &
# Open http://localhost:9090

# Install Grafana with custom values
helm install grafana grafana/grafana \
  -n helm-demo \
  -f values/grafana-values.yaml

# Get admin password
kubectl get secret -n helm-demo grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d

# Port forward to Grafana
kubectl port-forward -n helm-demo svc/grafana 3000:80 &
# Open http://localhost:3000 (admin / <password>)
```

---

### Exercise 4: Upgrade and Rollback

```bash
# Upgrade with new values
helm upgrade prometheus prometheus-community/prometheus \
  -n helm-demo \
  -f values/prometheus-values.yaml \
  --set server.replicaCount=2

# Check history
helm history prometheus -n helm-demo

# Rollback to previous revision
helm rollback prometheus 1 -n helm-demo

# Rollback to specific revision
helm rollback prometheus 1 -n helm-demo
```

---

### Exercise 5: Dry Run and Template

```bash
# See what would be installed (dry run)
helm install test bitnami/nginx \
  --dry-run \
  --debug

# Just render templates (no install)
helm template my-nginx bitnami/nginx > rendered.yaml
cat rendered.yaml

# Validate before install
helm lint ./my-chart  # If you have a local chart
```

---

## Cleanup

```bash
helm uninstall prometheus -n helm-demo
helm uninstall grafana -n helm-demo
kubectl delete namespace helm-demo
```

---

## Key Commands

| Command | Description |
|---------|-------------|
| `helm repo add <name> <url>` | Add repository |
| `helm repo update` | Update repo index |
| `helm search repo <term>` | Search repos |
| `helm show values <chart>` | Show default values |
| `helm install <name> <chart>` | Install release |
| `helm upgrade <name> <chart>` | Upgrade release |
| `helm rollback <name> <rev>` | Rollback release |
| `helm uninstall <name>` | Uninstall release |
| `helm list` | List releases |
| `helm history <name>` | Release history |

---

## Next Week

In Week 5, you'll learn about:
- GitOps principles
- Installing ArgoCD
- Deploying from Git repositories
- Automated sync
