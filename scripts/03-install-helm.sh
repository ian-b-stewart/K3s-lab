#!/usr/bin/env bash
#
# 03-install-helm.sh
#
# PURPOSE:
#   Install Helm package manager and add common repositories
#
# USAGE:
#   ./scripts/03-install-helm.sh
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Colors and logging
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------
install_helm() {
    if command -v helm &> /dev/null; then
        log_info "Helm already installed: $(helm version --short)"
        return 0
    fi

    log_info "Installing Helm..."

    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

add_repositories() {
    log_info "Adding Helm repositories..."

    # Prometheus Community
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true

    # Grafana
    helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true

    # Bitnami
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true

    # Ingress NGINX
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true

    # Jetstack (cert-manager)
    helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true

    # ArgoCD
    helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true

    log_info "Updating repositories..."
    helm repo update
}

configure_completion() {
    log_info "Configuring bash completion..."

    if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
    else
        mkdir -p ~/.local/share/bash-completion/completions
        helm completion bash > ~/.local/share/bash-completion/completions/helm
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  Helm Installation"
    echo "========================================"
    echo ""

    install_helm
    echo ""

    add_repositories
    echo ""

    configure_completion
    echo ""

    log_info "Helm installation complete!"
    echo ""
    echo "Version: $(helm version --short)"
    echo ""
    echo "Available repositories:"
    helm repo list
    echo ""
}

main "$@"
