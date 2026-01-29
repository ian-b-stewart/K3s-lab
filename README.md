# K3s Learning Lab

A structured 8-week curriculum to learn Kubernetes using K3s on Debian 13.

## Overview

This repository provides hands-on exercises for learning Kubernetes concepts
using K3s, a lightweight Kubernetes distribution perfect for learning and
homelab environments.

**Target Environment:**
- Debian 13 (Trixie) VM
- 4GB RAM, 2 vCPU, 20GB disk (minimum)
- Single-node cluster for learning

## Quick Start

```bash
# Clone this repository
git clone https://github.com/ian-b-stewart/k3s-lab.git /opt/k3s-lab
cd /opt/k3s-lab

# Prepare Debian 13 VM
sudo ./scripts/00-prepare-debian.sh

# Install K3s
sudo ./scripts/01-install-k3s.sh

# Install CLI tools
./scripts/02-install-kubectl.sh
./scripts/03-install-helm.sh

# Validate cluster
./scripts/04-validate-cluster.sh
```

## Curriculum

| Week | Directory | Topics |
|------|-----------|--------|
| 1 | [week-01](week-01/) | Pods, Deployments, Services, Ingress |
| 2 | [week-02](week-02/) | ReplicaSets, Rolling Updates, Jobs, CronJobs |
| 3 | [week-03](week-03/) | ConfigMaps, Secrets, PVCs, StatefulSets |
| 4 | [week-04](week-04/) | Helm charts, Prometheus, Grafana |
| 5 | [week-05](week-05/) | GitOps with ArgoCD |
| 6 | [week-06](week-06/) | Service Mesh with Linkerd |
| 7 | [week-07](week-07/) | Observability stack |
| 8 | [week-08](week-08/) | Production patterns (NetworkPolicy, ResourceQuotas, PDBs) |

## Prerequisites

### Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 2GB | 4GB |
| CPU | 1 vCPU | 2 vCPU |
| Disk | 10GB | 20GB |

### Software Requirements

- Debian 13 (Trixie) - fresh installation
- Root or sudo access
- Internet connectivity

## VM Setup (Proxmox)

1. Create a new VM in Proxmox
2. Install Debian 13 with default options
3. Configure static IP or DHCP reservation
4. Enable SSH access
5. Run the quick start commands above

## Scripts

| Script | Purpose |
|--------|---------|
| `00-prepare-debian.sh` | Install prerequisites on Debian 13 |
| `01-install-k3s.sh` | Install K3s single-node cluster |
| `02-install-kubectl.sh` | Install kubectl CLI |
| `03-install-helm.sh` | Install Helm package manager |
| `04-validate-cluster.sh` | Validate cluster health |
| `99-uninstall-k3s.sh` | Remove K3s completely |

## Reset

To start fresh:

```bash
sudo ./scripts/99-uninstall-k3s.sh
sudo ./scripts/01-install-k3s.sh
```

## Contributing

Contributions are welcome! Please ensure:
- YAML manifests pass linting
- Scripts follow existing conventions
- Each week has a README with exercises

## License

MIT License - See [LICENSE](LICENSE) for details.
