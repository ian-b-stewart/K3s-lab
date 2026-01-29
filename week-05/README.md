# Week 5: GitOps with ArgoCD

## Learning Objectives

By the end of this week, you will understand:
- GitOps principles and benefits
- Installing and configuring ArgoCD
- Deploying applications from Git
- Automated synchronization

## Prerequisites

- Completed Weeks 1-4
- A GitHub account (for pushing your own apps)

---

## What is GitOps?

GitOps uses Git as the single source of truth for infrastructure and applications:
- All changes go through Git (PRs, reviews)
- Cluster state matches Git state
- Automated sync detects and applies changes
- Full audit trail via Git history

---

## Exercises

### Exercise 1: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=argocd-server \
  -n argocd \
  --timeout=300s

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
echo ""

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open https://localhost:8080 (accept self-signed cert)
# Login: admin / <password from above>
```

---

### Exercise 2: Install ArgoCD CLI

```bash
# Download CLI
curl -sSL -o argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Login to ArgoCD
argocd login localhost:8080 --insecure

# Change password (optional)
argocd account update-password
```

---

### Exercise 3: Deploy from Public Git Repo

```bash
# Create an application from ArgoCD's example repo
argocd app create guestbook \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# View app status
argocd app get guestbook

# Sync (deploy) the application
argocd app sync guestbook

# Watch in UI or CLI
argocd app get guestbook

# Check pods
kubectl get pods

# Open the app
kubectl port-forward svc/guestbook-ui 8081:80 &
# Open http://localhost:8081

# Delete the app
argocd app delete guestbook
```

---

### Exercise 4: Deploy from Your Own Repo

First, push the example-app to your GitHub:

```bash
# Fork or create a new repo on GitHub
# Push the example-app folder contents

# Create ArgoCD application pointing to your repo
argocd app create my-app \
  --repo https://github.com/<your-username>/k3s-lab.git \
  --path week-05/example-app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Sync
argocd app sync my-app

# Enable auto-sync
argocd app set my-app --sync-policy automated

# Now push a change to Git and watch it auto-deploy!
```

---

### Exercise 5: App of Apps Pattern

Deploy multiple applications from a single ArgoCD Application:

```bash
# Apply the app-of-apps
kubectl apply -f app-of-apps.yaml

# This creates an ArgoCD app that manages other apps
argocd app get apps

# Sync all child apps
argocd app sync apps
```

---

## Cleanup

```bash
argocd app delete guestbook --yes
argocd app delete my-app --yes
kubectl delete namespace argocd
```

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Application** | ArgoCD resource linking Git repo to cluster |
| **Sync** | Process of applying Git state to cluster |
| **Refresh** | Check Git for changes |
| **Health** | Status of deployed resources |
| **Sync Policy** | Manual or automated sync |

---

## Next Week

In Week 6, you'll learn about:
- Service mesh concepts
- Installing Linkerd
- Automatic mTLS
- Traffic observability
