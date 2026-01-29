# Week 6: Service Mesh with Linkerd

## Learning Objectives

By the end of this week, you will understand:
- What a service mesh is and why you'd use one
- Installing Linkerd on K3s
- Automatic mTLS between services
- Observability with Linkerd Viz

## Prerequisites

- Completed Weeks 1-5
- At least 4GB RAM available

---

## What is a Service Mesh?

A service mesh provides infrastructure-level features for service-to-service communication:
- **mTLS**: Automatic encryption between services
- **Observability**: Metrics, tracing, traffic visibility
- **Reliability**: Retries, timeouts, circuit breaking
- **Traffic management**: Canary deploys, traffic splitting

---

## Why Linkerd?

- Lighter weight than Istio
- Simpler to learn and operate
- Written in Rust (low resource usage)
- Good for homelab scale

---

## Exercises

### Exercise 1: Install Linkerd CLI

```bash
# Install the CLI
curl -sL run.linkerd.io/install | sh

# Add to PATH
export PATH=$PATH:$HOME/.linkerd2/bin
echo 'export PATH=$PATH:$HOME/.linkerd2/bin' >> ~/.bashrc

# Verify
linkerd version
```

---

### Exercise 2: Pre-Installation Check

```bash
# Check if cluster is ready for Linkerd
linkerd check --pre

# Fix any issues before proceeding
```

---

### Exercise 3: Install Linkerd

```bash
# Install Custom Resource Definitions
linkerd install --crds | kubectl apply -f -

# Install control plane
linkerd install | kubectl apply -f -

# Wait for installation
linkerd check

# View control plane pods
kubectl get pods -n linkerd
```

---

### Exercise 4: Install Viz Extension

```bash
# Install the observability extension
linkerd viz install | kubectl apply -f -

# Wait for viz components
linkerd viz check

# Open the dashboard
linkerd viz dashboard &
# Opens browser automatically
```

---

### Exercise 5: Mesh an Application

```bash
# Deploy the sample emojivoto app
kubectl apply -f https://run.linkerd.io/emojivoto.yml

# Check pods (not yet meshed)
kubectl get pods -n emojivoto

# Inject Linkerd proxy into the deployment
kubectl get deploy -n emojivoto -o yaml | \
  linkerd inject - | \
  kubectl apply -f -

# Watch pods restart with sidecar
kubectl get pods -n emojivoto -w

# Each pod now has 2 containers (app + linkerd-proxy)
kubectl get pods -n emojivoto -o jsonpath='{.items[*].spec.containers[*].name}' | tr ' ' '\n'

# View in dashboard
linkerd viz dashboard &
# Navigate to emojivoto namespace
```

---

### Exercise 6: Observe mTLS

```bash
# Check mTLS status between services
linkerd viz edges deployment -n emojivoto

# All connections should show "secured"

# View detailed stats
linkerd viz stat deploy -n emojivoto

# Top requests (live)
linkerd viz top deploy -n emojivoto
```

---

### Exercise 7: Mesh Your Own App

```bash
# Create a test namespace
kubectl create namespace mesh-demo

# Deploy an app
kubectl apply -f demo-app.yaml -n mesh-demo

# Inject Linkerd (using annotation method)
kubectl annotate namespace mesh-demo linkerd.io/inject=enabled

# Restart deployments to pick up injection
kubectl rollout restart deploy -n mesh-demo

# Verify injection
kubectl get pods -n mesh-demo
```

---

## Cleanup

```bash
kubectl delete namespace emojivoto
kubectl delete namespace mesh-demo
linkerd viz uninstall | kubectl delete -f -
linkerd uninstall | kubectl delete -f -
```

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Sidecar** | Proxy container injected alongside your app |
| **mTLS** | Mutual TLS - both sides verify certificates |
| **Injection** | Adding Linkerd proxy to pods |
| **Control Plane** | Linkerd components that manage the mesh |
| **Data Plane** | The sidecar proxies in your pods |

---

## Next Week

In Week 7, you'll learn about:
- Full observability stack
- kube-prometheus-stack
- Grafana dashboards
- Alerting
