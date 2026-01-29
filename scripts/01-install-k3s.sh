#!/usr/bin/env bash
#
# 01-install-k3s.sh
#
# PURPOSE:
#   Install K3s single-node cluster for learning
#
# USAGE:
#   sudo ./scripts/01-install-k3s.sh
#
# OPTIONS:
#   --with-traefik    Include Traefik ingress controller (default: disabled)
#
# NOTES:
#   - Traefik and ServiceLB are disabled by default for learning
#   - Use NGINX Ingress or install Traefik manually for ingress exercises
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
K3S_VERSION=""  # Empty = latest stable
INSTALL_TRAEFIK=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-traefik)
            INSTALL_TRAEFIK=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Colors and logging
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_existing() {
    if command -v k3s &> /dev/null; then
        log_warn "K3s is already installed"
        k3s --version
        echo ""
        read -p "Reinstall K3s? This will reset the cluster. (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing installation"
            exit 0
        fi

        log_info "Uninstalling existing K3s..."
        /usr/local/bin/k3s-uninstall.sh || true
    fi
}

check_memory() {
    local mem_kb
    mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local mem_gb=$((mem_kb / 1024 / 1024))

    if [[ $mem_gb -lt 2 ]]; then
        log_warn "Only ${mem_gb}GB RAM detected. 4GB recommended."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_info "Memory check: ${mem_gb}GB available"
    fi
}

check_swap() {
    if [[ $(swapon --show | wc -l) -gt 0 ]]; then
        log_warn "Swap is enabled. Kubernetes recommends disabling swap."
        log_info "Run: sudo swapoff -a"
    fi
}

# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------
install_k3s() {
    log_info "Installing K3s..."

    local install_args=(
        "--write-kubeconfig-mode" "644"
    )

    # Disable components for learning (install manually later)
    if [[ "$INSTALL_TRAEFIK" == false ]]; then
        install_args+=("--disable" "traefik")
        install_args+=("--disable" "servicelb")
    fi

    # Run installer
    curl -sfL https://get.k3s.io | sh -s - "${install_args[@]}"
}

wait_for_k3s() {
    log_info "Waiting for K3s to be ready..."

    local max_attempts=30
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if k3s kubectl get nodes 2>/dev/null | grep -q "Ready"; then
            log_info "K3s is ready!"
            return 0
        fi
        ((attempt++))
        sleep 2
    done

    log_error "K3s did not become ready within 60 seconds"
    return 1
}

configure_kubeconfig() {
    log_info "Configuring kubeconfig..."

    local real_user="${SUDO_USER:-}"
    local real_home

    if [[ -n "$real_user" && "$real_user" != "root" ]]; then
        real_home=$(getent passwd "$real_user" | cut -d: -f6)

        mkdir -p "$real_home/.kube"
        cp /etc/rancher/k3s/k3s.yaml "$real_home/.kube/config"
        chown -R "$real_user:$real_user" "$real_home/.kube"

        log_info "Kubeconfig copied to $real_home/.kube/config"
    else
        log_warn "Could not determine non-root user. Copy kubeconfig manually:"
        log_info "  mkdir -p ~/.kube"
        log_info "  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config"
        log_info "  sudo chown \$USER:\$USER ~/.kube/config"
    fi
}

# -----------------------------------------------------------------------------
# Verification
# -----------------------------------------------------------------------------
verify_installation() {
    log_info "Verifying installation..."
    echo ""

    log_info "K3s version:"
    k3s --version
    echo ""

    log_info "Node status:"
    k3s kubectl get nodes -o wide
    echo ""

    log_info "System pods:"
    k3s kubectl get pods -n kube-system
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  K3s Installation"
    echo "========================================"
    echo ""

    check_root
    check_existing
    check_memory
    check_swap
    echo ""

    install_k3s
    echo ""

    wait_for_k3s
    echo ""

    configure_kubeconfig
    echo ""

    verify_installation
    echo ""

    log_info "K3s installation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Open a new terminal (or run: source ~/.bashrc)"
    echo "  2. Run: ./scripts/02-install-kubectl.sh"
    echo "  3. Run: ./scripts/03-install-helm.sh"
    echo "  4. Run: ./scripts/04-validate-cluster.sh"
    echo ""
    echo "Quick test:"
    echo "  kubectl get nodes"
    echo ""
}

main "$@"
