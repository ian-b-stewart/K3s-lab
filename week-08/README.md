# Week 8: Production Patterns

## Learning Objectives

By the end of this week, you will understand:
- Network Policies for pod-to-pod security
- Resource Quotas for namespace limits
- LimitRanges for default resources
- Pod Disruption Budgets for availability
- Security contexts for container hardening

## Prerequisites

- Completed Weeks 1-7

---

## Exercises

### Exercise 1: Network Policies

Network Policies control traffic between pods.

```bash
# Create test namespace
kubectl create namespace netpol-demo

# Deploy frontend and backend
kubectl apply -f 01-netpol-apps.yaml -n netpol-demo

# Test connectivity (should work)
kubectl exec -n netpol-demo deploy/frontend -- \
  wget -qO- http://backend --timeout=5

# Apply deny-all policy
kubectl apply -f 01-netpol-deny-all.yaml -n netpol-demo

# Test again (should fail/timeout)
kubectl exec -n netpol-demo deploy/frontend -- \
  wget -qO- http://backend --timeout=5

# Apply allow policy for frontend -> backend
kubectl apply -f 01-netpol-allow.yaml -n netpol-demo

# Test again (should work)
kubectl exec -n netpol-demo deploy/frontend -- \
  wget -qO- http://backend --timeout=5

# Clean up
kubectl delete namespace netpol-demo
```

---

### Exercise 2: Resource Quotas

Resource Quotas limit total resources in a namespace.

```bash
# Create namespace with quota
kubectl create namespace quota-demo
kubectl apply -f 02-resource-quota.yaml -n quota-demo

# View quota
kubectl describe resourcequota namespace-quota -n quota-demo

# Deploy apps (within quota)
kubectl apply -f 02-quota-app.yaml -n quota-demo

# Try to exceed quota
kubectl scale deploy quota-app --replicas=20 -n quota-demo

# Check events (should show quota exceeded)
kubectl get events -n quota-demo | grep -i quota

# Clean up
kubectl delete namespace quota-demo
```

---

### Exercise 3: LimitRanges

LimitRanges set default and max resources per container.

```bash
# Create namespace with limits
kubectl create namespace limits-demo
kubectl apply -f 03-limit-range.yaml -n limits-demo

# View limits
kubectl describe limitrange default-limits -n limits-demo

# Deploy pod without resources specified
kubectl run test --image=nginx -n limits-demo

# Check that defaults were applied
kubectl get pod test -n limits-demo -o yaml | grep -A5 resources

# Try to exceed limits
kubectl apply -f 03-oversized-pod.yaml -n limits-demo
# Should be rejected

# Clean up
kubectl delete namespace limits-demo
```

---

### Exercise 4: Pod Disruption Budgets

PDBs ensure minimum availability during voluntary disruptions.

```bash
# Create namespace
kubectl create namespace pdb-demo

# Deploy app with multiple replicas
kubectl apply -f 04-pdb-app.yaml -n pdb-demo

# Create PDB
kubectl apply -f 04-pdb.yaml -n pdb-demo

# View PDB status
kubectl get pdb -n pdb-demo

# Try to drain node (will respect PDB)
# kubectl drain <node-name> --ignore-daemonsets

# Simulate eviction
kubectl delete pod -l app=pdb-app -n pdb-demo --wait=false
# PDB limits how many can be deleted at once

# Clean up
kubectl delete namespace pdb-demo
```

---

### Exercise 5: Security Contexts

Security contexts harden container security.

```bash
# Create namespace
kubectl create namespace security-demo

# Deploy secure pod
kubectl apply -f 05-security-context.yaml -n security-demo

# Verify security settings
kubectl exec -n security-demo secure-pod -- id
# Should show non-root user

kubectl exec -n security-demo secure-pod -- touch /test
# Should fail (read-only filesystem)

# Compare with insecure pod
kubectl apply -f 05-insecure-pod.yaml -n security-demo
kubectl exec -n security-demo insecure-pod -- id
# Shows root

# Clean up
kubectl delete namespace security-demo
```

---

## Cleanup

```bash
kubectl delete namespace netpol-demo quota-demo limits-demo pdb-demo security-demo
```

---

## Production Checklist

Before going to production, ensure:

- [ ] Network Policies restrict unnecessary traffic
- [ ] Resource Quotas prevent runaway usage
- [ ] LimitRanges set sensible defaults
- [ ] PDBs protect critical workloads
- [ ] Security contexts run as non-root
- [ ] Read-only filesystems where possible
- [ ] Pod Security Standards enforced
- [ ] Secrets managed externally (not in Git)
- [ ] Regular backups configured
- [ ] Monitoring and alerting in place

---

## Congratulations!

You've completed the K3s Learning Lab!

You now understand:
- Core Kubernetes concepts (Pods, Deployments, Services)
- Storage and configuration (PVCs, ConfigMaps, Secrets)
- Package management (Helm)
- GitOps (ArgoCD)
- Service mesh (Linkerd)
- Observability (Prometheus, Grafana)
- Production patterns (NetworkPolicy, Quotas, PDBs)

## Next Steps

1. Build your own applications on K3s
2. Explore more Helm charts
3. Set up a multi-node cluster
4. Try managed Kubernetes (EKS, GKE, AKS)
5. Get certified (CKA, CKAD)
