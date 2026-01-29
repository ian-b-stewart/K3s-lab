# Week 3: Storage & Configuration

## Learning Objectives

By the end of this week, you will understand:
- ConfigMaps for application configuration
- Secrets for sensitive data
- PersistentVolumeClaims for data persistence
- StatefulSets for stateful applications

## Prerequisites

- Completed Weeks 1-2
- `kubectl` working

---

## Exercises

### Exercise 1: ConfigMaps

ConfigMaps store non-sensitive configuration data.

```bash
# Create ConfigMap from manifest
kubectl apply -f 01-configmap.yaml

# View the ConfigMap
kubectl get configmap app-config -o yaml

# Create ConfigMap from literal values
kubectl create configmap my-config \
  --from-literal=DATABASE_HOST=postgres \
  --from-literal=LOG_LEVEL=debug

# Create ConfigMap from file
echo "key=value" > /tmp/config.properties
kubectl create configmap file-config --from-file=/tmp/config.properties

# Apply the demo pod
kubectl apply -f 01-configmap-pod.yaml

# Check environment variables
kubectl exec configmap-demo -- env | grep APP_

# Check mounted files
kubectl exec configmap-demo -- cat /etc/config/settings.json

# Clean up
kubectl delete -f 01-configmap.yaml
kubectl delete -f 01-configmap-pod.yaml
kubectl delete configmap my-config file-config
```

**Key Takeaways:**
- ConfigMaps decouple configuration from images
- Can be used as environment variables or files
- Changes to ConfigMaps don't auto-update running pods

---

### Exercise 2: Secrets

Secrets store sensitive data (passwords, tokens, keys).

```bash
# Create Secret from literal values
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=changeme

# View the secret (base64 encoded)
kubectl get secret db-credentials -o yaml

# Decode a value
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d

# Create from manifest
kubectl apply -f 02-secret.yaml

# Apply demo pod
kubectl apply -f 02-secret-pod.yaml

# Check environment variables
kubectl exec secret-demo -- env | grep DB_

# Clean up
kubectl delete -f 02-secret.yaml
kubectl delete -f 02-secret-pod.yaml
kubectl delete secret db-credentials
```

**Key Takeaways:**
- Secrets are base64 encoded, NOT encrypted by default
- Use external secret managers for production
- `stringData` allows plain text in manifests (encoded on apply)

---

### Exercise 3: PersistentVolumeClaims

PVCs request storage from the cluster.

```bash
# Create PVC and pod
kubectl apply -f 03-pvc.yaml

# Check PVC status (should be Bound)
kubectl get pvc data-pvc

# Check the automatically created PV
kubectl get pv

# Write data to the volume
kubectl exec pvc-demo -- sh -c 'echo "Hello from K8s" > /data/test.txt'
kubectl exec pvc-demo -- cat /data/test.txt

# Delete the pod (but NOT the PVC)
kubectl delete pod pvc-demo

# Recreate the pod
kubectl apply -f 03-pvc.yaml

# Data persists!
kubectl exec pvc-demo -- cat /data/test.txt

# Clean up (this deletes the data)
kubectl delete -f 03-pvc.yaml
```

**Key Takeaways:**
- PVCs abstract storage provisioning
- K3s uses `local-path` provisioner by default
- Data persists across pod restarts

---

### Exercise 4: StatefulSets

StatefulSets manage stateful applications with stable identities.

```bash
# Create StatefulSet
kubectl apply -f 04-statefulset.yaml

# Watch pods being created (ordered: web-0, web-1, web-2)
kubectl get pods -w

# Notice stable hostnames
kubectl exec web-0 -- hostname
kubectl exec web-1 -- hostname

# Each pod has its own PVC
kubectl get pvc

# Scale the StatefulSet
kubectl scale statefulset web --replicas=5
kubectl get pods -w

# Delete a pod - same identity returns
kubectl delete pod web-1
kubectl get pods -w

# Clean up
kubectl delete -f 04-statefulset.yaml
# PVCs are NOT deleted automatically
kubectl delete pvc -l app=nginx
```

**Key Takeaways:**
- Pods have stable, predictable names (web-0, web-1, ...)
- Pods are created/deleted in order
- Each pod gets its own PVC
- Use for databases, message queues, etc.

---

## Cleanup

```bash
kubectl delete -f .
kubectl delete pvc --all
```

---

## Next Week

In Week 4, you'll learn about:
- Helm package manager
- Installing applications with Helm
- Customizing charts with values
- Creating your own charts
