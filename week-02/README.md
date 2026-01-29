# Week 2: Advanced Workloads

## Learning Objectives

By the end of this week, you will understand:
- How ReplicaSets work under the hood
- Rolling updates and rollbacks
- One-time Jobs
- Scheduled CronJobs

## Prerequisites

- Completed Week 1
- `kubectl` working

---

## Exercises

### Exercise 1: ReplicaSets

ReplicaSets ensure a specified number of pod replicas are running.

```bash
# Create a ReplicaSet directly (usually managed by Deployments)
kubectl apply -f 01-replicaset.yaml

# Watch the pods
kubectl get pods -w

# Check ReplicaSet status
kubectl get rs whoami-rs

# Delete a pod - watch it recreate immediately
POD=$(kubectl get pods -l app=whoami-rs -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD
kubectl get pods -w

# Scale the ReplicaSet
kubectl scale rs whoami-rs --replicas=5
kubectl get pods

# Clean up
kubectl delete -f 01-replicaset.yaml
```

**Key Takeaways:**
- ReplicaSets maintain desired pod count
- Deployments create and manage ReplicaSets
- Rarely create ReplicaSets directly

---

### Exercise 2: Rolling Updates

Deployments support zero-downtime rolling updates.

```bash
# Create initial deployment
kubectl apply -f 02-deployment-v1.yaml

# Watch pods
kubectl get pods -w &

# Check current image
kubectl get deployment webapp -o jsonpath='{.spec.template.spec.containers[0].image}'

# Trigger rolling update by changing image
kubectl set image deployment/webapp webapp=nginx:1.25

# Watch the rollout
kubectl rollout status deployment/webapp

# View rollout history
kubectl rollout history deployment/webapp

# Rollback to previous version
kubectl rollout undo deployment/webapp

# Rollback to specific revision
kubectl rollout undo deployment/webapp --to-revision=1

# Clean up
kubectl delete -f 02-deployment-v1.yaml
```

**Key Takeaways:**
- Rolling updates replace pods gradually
- `maxSurge` and `maxUnavailable` control the rollout speed
- Rollback is instant with `rollout undo`

---

### Exercise 3: Jobs

Jobs run tasks to completion (batch processing).

```bash
# Run a simple job
kubectl apply -f 03-job.yaml

# Watch it complete
kubectl get jobs -w

# View the pod it created
kubectl get pods

# Check the output
kubectl logs job/pi-calculator

# Jobs with multiple completions
kubectl apply -f 03-job-parallel.yaml
kubectl get pods -w

# Clean up
kubectl delete -f 03-job.yaml
kubectl delete -f 03-job-parallel.yaml
```

**Key Takeaways:**
- Jobs run to completion, not continuously
- `completions` = how many times to run
- `parallelism` = how many pods run at once
- `backoffLimit` = retry count on failure

---

### Exercise 4: CronJobs

CronJobs run Jobs on a schedule.

```bash
# Create a CronJob
kubectl apply -f 04-cronjob.yaml

# Watch it (runs every minute)
kubectl get cronjobs
kubectl get jobs -w

# Wait a minute, then check jobs created
kubectl get jobs

# View logs from a job
kubectl logs job/<job-name>

# Suspend the CronJob
kubectl patch cronjob hello-cron -p '{"spec":{"suspend":true}}'

# Resume
kubectl patch cronjob hello-cron -p '{"spec":{"suspend":false}}'

# Clean up
kubectl delete -f 04-cronjob.yaml
```

**Key Takeaways:**
- Uses standard cron syntax
- `successfulJobsHistoryLimit` controls cleanup
- Can be suspended without deletion

---

## Cleanup

```bash
kubectl delete -f .
```

---

## Next Week

In Week 3, you'll learn about:
- ConfigMaps for configuration
- Secrets for sensitive data
- PersistentVolumeClaims for storage
- StatefulSets for stateful applications
