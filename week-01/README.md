# Week 1: Kubernetes Fundamentals

## Learning Objectives

By the end of this week, you will understand:
- What Pods are and how to create them
- How Deployments manage Pods
- How Services provide networking
- How Ingress exposes HTTP routes

## Prerequisites

- Completed K3s installation
- `kubectl` configured and working
- Run `kubectl get nodes` to verify

## Exercises

### Exercise 1: Your First Pod

A Pod is the smallest deployable unit in Kubernetes.

```bash
# Create the pod
kubectl apply -f 01-pod.yaml

# Watch it start
kubectl get pods -w

# View details
kubectl describe pod whoami-pod

# Check logs
kubectl logs whoami-pod

# Execute a command inside
kubectl exec whoami-pod -- hostname

# Interactive shell
kubectl exec -it whoami-pod -- /bin/sh

# Delete when done
kubectl delete -f 01-pod.yaml
```

**Key Takeaways:**
- Pods are ephemeral (temporary)
- Rarely create Pods directly in production
- Use Deployments instead

---

### Exercise 2: Deployments

A Deployment manages replicated Pods and handles updates.

```bash
# Create a deployment
kubectl apply -f 02-deployment.yaml

# Watch pods being created
kubectl get pods -w

# Scale up
kubectl scale deployment whoami --replicas=5

# Scale down
kubectl scale deployment whoami --replicas=2

# View deployment status
kubectl get deployment whoami

# View ReplicaSet (created by Deployment)
kubectl get replicasets

# Delete a pod - watch it recreate
kubectl delete pod <pod-name>
kubectl get pods -w
```

**Key Takeaways:**
- Deployments ensure desired number of replicas
- Self-healing: deleted pods are recreated
- ReplicaSets are managed by Deployments

---

### Exercise 3: Services

A Service provides stable networking for Pods.

```bash
# Create the service
kubectl apply -f 03-service.yaml

# View the service
kubectl get svc whoami

# Get the ClusterIP
kubectl get svc whoami -o jsonpath='{.spec.clusterIP}'

# Test from another pod
kubectl run test --rm -it --image=curlimages/curl -- curl http://whoami

# Observe load balancing (run multiple times)
kubectl run test --rm -it --image=curlimages/curl -- sh -c \
  'for i in $(seq 1 5); do curl -s http://whoami | grep Hostname; done'
```

**Key Takeaways:**
- Services provide stable DNS names
- ClusterIP is only accessible inside the cluster
- Traffic is load-balanced across pods

---

### Exercise 4: Ingress

Ingress exposes HTTP routes from outside the cluster.

```bash
# First, install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml

# Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Apply the ingress
kubectl apply -f 04-ingress.yaml

# Get the NodePort
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Test (replace <NODE_IP> with your VM's IP, <NODE_PORT> with the HTTP port)
curl -H "Host: whoami.k3s.local" http://<NODE_IP>:<NODE_PORT>

# Or add to /etc/hosts and use port 80
echo "<NODE_IP> whoami.k3s.local" | sudo tee -a /etc/hosts
curl http://whoami.k3s.local:<NODE_PORT>
```

**Key Takeaways:**
- Ingress requires an Ingress Controller
- Routes based on hostname and path
- Single entry point for multiple services

---

## Cleanup

```bash
kubectl delete -f .
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
```

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `kubectl get pods` | List pods |
| `kubectl get pods -o wide` | List with more details |
| `kubectl describe pod <name>` | Detailed info |
| `kubectl logs <pod>` | View logs |
| `kubectl logs -f <pod>` | Follow logs |
| `kubectl exec -it <pod> -- /bin/sh` | Shell into pod |
| `kubectl apply -f <file>` | Create/update from file |
| `kubectl delete -f <file>` | Delete from file |
| `kubectl get all` | List common resources |

---

## Next Week

In Week 2, you'll learn about:
- ReplicaSets in detail
- Rolling updates and rollbacks
- Jobs and CronJobs
