# Week 7: Full Observability Stack

## Learning Objectives

By the end of this week, you will understand:
- The three pillars of observability (metrics, logs, traces)
- Deploying kube-prometheus-stack
- Using Grafana dashboards
- Creating alerts

## Prerequisites

- Completed Weeks 1-6
- Helm installed
- At least 4GB RAM available

---

## Exercises

### Exercise 1: Install kube-prometheus-stack

This installs Prometheus, Grafana, Alertmanager, and pre-configured dashboards.

```bash
# Create namespace
kubectl create namespace monitoring

# Add Helm repo (if not already added)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install with custom values
helm install kube-prom prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f kube-prometheus-stack/values.yaml

# Wait for all pods
kubectl get pods -n monitoring -w

# Check all components
kubectl get all -n monitoring
```

---

### Exercise 2: Access Grafana

```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/kube-prom-grafana 3000:80 &

# Open http://localhost:3000
# Login: admin / prom-operator (default)

# Explore pre-built dashboards:
# - Dashboards > Browse > Kubernetes / Compute Resources / Cluster
# - Dashboards > Browse > Kubernetes / Compute Resources / Namespace (Pods)
```

---

### Exercise 3: Access Prometheus

```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/kube-prom-kube-prometheus-prometheus 9090:9090 &

# Open http://localhost:9090

# Try these queries:
# - up
# - kube_pod_status_phase
# - container_memory_usage_bytes
# - rate(container_cpu_usage_seconds_total[5m])
# - sum(rate(container_network_receive_bytes_total[5m])) by (pod)
```

---

### Exercise 4: Access Alertmanager

```bash
# Port forward to Alertmanager
kubectl port-forward -n monitoring svc/kube-prom-kube-prometheus-alertmanager 9093:9093 &

# Open http://localhost:9093

# View active alerts
# Configure receivers (Slack, email, etc.)
```

---

### Exercise 5: Create Custom Dashboard

```bash
# In Grafana:
# 1. Click + > Dashboard
# 2. Add visualization
# 3. Select Prometheus datasource
# 4. Enter query: sum(container_memory_usage_bytes) by (namespace)
# 5. Save dashboard

# Or import a community dashboard:
# 1. Dashboards > Import
# 2. Enter ID: 6417 (Kubernetes Cluster)
# 3. Select Prometheus datasource
```

---

### Exercise 6: Create an Alert

```bash
# Apply a PrometheusRule
kubectl apply -f custom-alert.yaml

# Wait for Prometheus to reload
sleep 30

# Check in Prometheus UI > Alerts
```

---

## Cleanup

```bash
helm uninstall kube-prom -n monitoring
kubectl delete namespace monitoring
```

---

## Key Concepts

| Component | Purpose |
|-----------|---------|
| **Prometheus** | Metrics collection and storage |
| **Grafana** | Visualization and dashboards |
| **Alertmanager** | Alert routing and notification |
| **Node Exporter** | Host-level metrics |
| **kube-state-metrics** | Kubernetes object metrics |

---

## Useful PromQL Queries

```promql
# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

# Memory usage by namespace
sum(container_memory_usage_bytes) by (namespace)

# Pod restart count
sum(kube_pod_container_status_restarts_total) by (pod)

# Network received bytes
sum(rate(container_network_receive_bytes_total[5m])) by (pod)

# Pods not ready
kube_pod_status_ready{condition="false"}
```

---

## Next Week

In Week 8, you'll learn about:
- Network Policies
- Resource Quotas
- Pod Disruption Budgets
- Security best practices
