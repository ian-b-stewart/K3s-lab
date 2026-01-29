#!/usr/bin/env bash
#
# 04-validate-cluster.sh
#
# PURPOSE:
#   Validate K3s cluster is healthy and ready for learning
#
# USAGE:
#   ./scripts/04-validate-cluster.sh
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Colors and logging
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_pass() { echo -e "${GREEN}✓${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; ((ERRORS++)); }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
log_info() { echo -e "  $1"; }

# -----------------------------------------------------------------------------
# Checks
# -----------------------------------------------------------------------------
check_k3s_service() {
    echo "K3s Service"
    echo "-----------"

    if systemctl is-active --quiet k3s; then
        log_pass "K3s service is running"
    else
        log_fail "K3s service is not running"
        log_info "Try: sudo systemctl start k3s"
    fi
    echo ""
}

check_kubectl() {
    echo "kubectl"
    echo "-------"

    if command -v kubectl &> /dev/null; then
        log_pass "kubectl is installed"
        log_info "$(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    else
        log_fail "kubectl is not installed"
        log_info "Run: ./scripts/02-install-kubectl.sh"
    fi
    echo ""
}

check_helm() {
    echo "Helm"
    echo "----"

    if command -v helm &> /dev/null; then
        log_pass "Helm is installed"
        log_info "$(helm version --short)"
    else
        log_warn "Helm is not installed (optional for weeks 1-3)"
        log_info "Run: ./scripts/03-install-helm.sh"
    fi
    echo ""
}

check_node() {
    echo "Node Status"
    echo "-----------"

    if ! kubectl get nodes &>/dev/null; then
        log_fail "Cannot connect to cluster"
        log_info "Check kubeconfig: export KUBECONFIG=~/.kube/config"
        return
    fi

    local node_status
    node_status=$(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}')

    if [[ "$node_status" == "Ready" ]]; then
        log_pass "Node is Ready"
        kubectl get nodes
    else
        log_fail "Node is not Ready (status: $node_status)"
        log_info "Check: kubectl describe node"
    fi
    echo ""
}

check_system_pods() {
    echo "System Pods"
    echo "-----------"

    local not_running
    not_running=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -v "Running\|Completed" | wc -l)

    if [[ "$not_running" -eq 0 ]]; then
        log_pass "All system pods are running"
    else
        log_fail "$not_running system pod(s) not running"
    fi

    kubectl get pods -n kube-system
    echo ""
}

check_coredns() {
    echo "CoreDNS"
    echo "-------"

    if kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers 2>/dev/null | grep -q "Running"; then
        log_pass "CoreDNS is running"
    else
        log_fail "CoreDNS is not running"
    fi
    echo ""
}

check_storage() {
    echo "Storage"
    echo "-------"

    if kubectl get storageclass local-path &>/dev/null; then
        log_pass "local-path StorageClass available"
    else
        log_warn "local-path StorageClass not found"
    fi
    echo ""
}

check_api_server() {
    echo "API Server"
    echo "----------"

    if kubectl cluster-info &>/dev/null; then
        log_pass "API server is responding"
    else
        log_fail "API server is not responding"
    fi
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  K3s Cluster Validation"
    echo "========================================"
    echo ""

    check_k3s_service
    check_kubectl
    check_helm
    check_node
    check_system_pods
    check_coredns
    check_storage
    check_api_server

    echo "========================================"
    echo "  Summary"
    echo "========================================"

    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
        echo ""
        echo "Your cluster is ready for learning."
        echo "Start with: cd week-01 && cat README.md"
        exit 0
    elif [[ $ERRORS -eq 0 ]]; then
        echo -e "${YELLOW}Passed with ${WARNINGS} warning(s)${NC}"
        exit 0
    else
        echo -e "${RED}Failed with ${ERRORS} error(s) and ${WARNINGS} warning(s)${NC}"
        exit 1
    fi
}

main "$@"
