## Project Context

This repository is a Kubernetes learning lab using:
- K3s (lightweight Kubernetes)
- Debian 13 (Trixie) VMs
- Single-node cluster for learning

This project intentionally does NOT use:
- Production Kubernetes (EKS, GKE, AKS)
- Docker Compose (separate project)
- Complex multi-node setups

---

## Architectural Rules

- One directory per curriculum week (`week-01/` through `week-08/`)
- Each week must have a README.md with exercises
- Manifests should be simple and educational
- Prefer explicit YAML over Helm for learning weeks 1-3

---

## Script Conventions

- Bash scripts must use:
  - `#!/usr/bin/env bash`
  - `set -euo pipefail`
- Include header block with PURPOSE, USAGE, NOTES
- Use color-coded logging functions (log_info, log_warn, log_error)
- Check for root/sudo when required
- Detect architecture for binary downloads

---

## YAML & Kubernetes Guidelines

- Use `apiVersion` appropriate for K3s/K8s 1.28+
- Always include resource requests/limits in examples
- Use `local-path` as storageClassName (K3s default)
- Prefer `networking.k8s.io/v1` for Ingress
- Include comments explaining each manifest section

---

## Security Guidelines

- No credentials, tokens, or secrets in manifests
- Use `stringData` in Secret examples (not real secrets)
- Example passwords should be obvious placeholders (e.g., "changeme")
- No personal information or internal hostnames

---

## Design Philosophy

- Optimize for learning, not production
- Each exercise should teach one concept
- Prefer clarity over brevity
- Include cleanup instructions in every README
