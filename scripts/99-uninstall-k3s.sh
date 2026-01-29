#!/usr/bin/env bash
#
# 99-uninstall-k3s.sh
#
# PURPOSE:
#   Completely remove K3s from the system
#
# USAGE:
#   sudo ./scripts/99-uninstall-k3s.sh
#
# WARNING:
#   This will destroy all cluster data, pods, and volumes!
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Colors and logging
# -----------------------------------------------------------------------------
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

confirm_uninstall() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                        WARNING                             ║${NC}"
    echo -e "${RED}║  This will completely remove K3s and ALL cluster data!    ║${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}║  • All pods will be deleted                               ║${NC}"
    echo -e "${RED}║  • All persistent volumes will be deleted                 ║${NC}"
    echo -e "${RED}║  • All cluster configuration will be removed              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    read -p "Type 'yes' to confirm uninstall: " -r
    if [[ "$REPLY" != "yes" ]]; then
        log_info "Uninstall cancelled"
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Uninstall
# -----------------------------------------------------------------------------
uninstall_k3s() {
    if [[ -f /usr/local/bin/k3s-uninstall.sh ]]; then
        log_info "Running K3s uninstall script..."
        /usr/local/bin/k3s-uninstall.sh
    else
        log_warn "K3s uninstall script not found. Is K3s installed?"
        return 1
    fi
}

cleanup_kubeconfig() {
    local real_user="${SUDO_USER:-}"
    local real_home

    if [[ -n "$real_user" && "$real_user" != "root" ]]; then
        real_home=$(getent passwd "$real_user" | cut -d: -f6)

        if [[ -f "$real_home/.kube/config" ]]; then
            log_info "Removing kubeconfig..."
            rm -f "$real_home/.kube/config"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  K3s Uninstall"
    echo "========================================"

    check_root
    confirm_uninstall
    echo ""

    uninstall_k3s
    echo ""

    cleanup_kubeconfig
    echo ""

    log_info "K3s has been completely removed"
    echo ""
    echo "To reinstall, run:"
    echo "  sudo ./scripts/01-install-k3s.sh"
    echo ""
}

main "$@"
