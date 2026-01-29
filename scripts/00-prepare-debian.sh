#!/usr/bin/env bash
#
# 00-prepare-debian.sh
#
# PURPOSE:
#   Prepare a fresh Debian 13 (Trixie) VM for K3s installation
#
# USAGE:
#   sudo ./scripts/00-prepare-debian.sh
#
# OPERATIONS:
#   1. Verify Debian 13
#   2. Update system packages
#   3. Install prerequisites
#   4. Configure system settings
#   5. Disable swap (required for Kubernetes)
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
REQUIRED_PACKAGES=(
    curl
    wget
    git
    ca-certificates
    gnupg
    lsb-release
    apt-transport-https
    iptables
    open-iscsi
    nfs-common
    jq
    bash-completion
)

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

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS (missing /etc/os-release)"
        exit 1
    fi

    # shellcheck source=/dev/null
    . /etc/os-release

    log_info "Detected OS: $PRETTY_NAME"

    if [[ "$ID" != "debian" ]]; then
        log_error "This script is designed for Debian (detected: $ID)"
        exit 1
    fi

    local version="${VERSION_ID:-0}"
    if [[ "$version" -lt 12 ]]; then
        log_warn "This script is designed for Debian 12+ (detected: $version)"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# System preparation
# -----------------------------------------------------------------------------
update_system() {
    log_info "Updating system packages..."
    apt-get update
    apt-get upgrade -y
}

install_prerequisites() {
    log_info "Installing prerequisites..."
    apt-get install -y "${REQUIRED_PACKAGES[@]}"
}

disable_swap() {
    log_info "Disabling swap (required for Kubernetes)..."

    # Disable swap immediately
    swapoff -a || true

    # Remove swap entries from fstab
    if grep -q swap /etc/fstab; then
        log_info "Removing swap entries from /etc/fstab..."
        sed -i '/swap/d' /etc/fstab
    fi

    log_info "Swap disabled"
}

configure_kernel_modules() {
    log_info "Configuring kernel modules..."

    cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

    modprobe overlay
    modprobe br_netfilter
}

configure_sysctl() {
    log_info "Configuring sysctl for Kubernetes..."

    cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sysctl --system > /dev/null 2>&1
}

configure_iscsi() {
    log_info "Enabling open-iscsi service..."
    systemctl enable --now iscsid || true
}

# -----------------------------------------------------------------------------
# Verification
# -----------------------------------------------------------------------------
verify_setup() {
    log_info "Verifying setup..."

    local errors=0

    # Check swap
    if [[ $(swapon --show | wc -l) -gt 0 ]]; then
        log_error "Swap is still enabled"
        ((errors++))
    else
        log_info "✓ Swap is disabled"
    fi

    # Check kernel modules
    if lsmod | grep -q br_netfilter; then
        log_info "✓ br_netfilter module loaded"
    else
        log_error "br_netfilter module not loaded"
        ((errors++))
    fi

    # Check IP forwarding
    if [[ $(cat /proc/sys/net/ipv4/ip_forward) == "1" ]]; then
        log_info "✓ IP forwarding enabled"
    else
        log_error "IP forwarding not enabled"
        ((errors++))
    fi

    # Check required packages
    for pkg in curl git jq; do
        if command -v "$pkg" &> /dev/null; then
            log_info "✓ $pkg installed"
        else
            log_error "$pkg not installed"
            ((errors++))
        fi
    done

    if [[ $errors -gt 0 ]]; then
        log_error "$errors verification check(s) failed"
        return 1
    fi

    log_info "All verification checks passed!"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  Debian 13 Preparation for K3s"
    echo "========================================"
    echo ""

    check_root
    check_os
    echo ""

    update_system
    echo ""

    install_prerequisites
    echo ""

    disable_swap
    configure_kernel_modules
    configure_sysctl
    configure_iscsi
    echo ""

    verify_setup
    echo ""

    log_info "Debian preparation complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Reboot the system: sudo reboot"
    echo "  2. Run: ./scripts/01-install-k3s.sh"
    echo ""
}

main "$@"
