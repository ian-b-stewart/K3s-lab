#!/usr/bin/env bash
#
# 02-install-kubectl.sh
#
# PURPOSE:
#   Install kubectl CLI tool
#
# USAGE:
#   ./scripts/02-install-kubectl.sh
#
# NOTES:
#   - Does not require root (installs to ~/.local/bin or uses sudo for /usr/local/bin)
#   - Enables bash completion
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Colors and logging
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------
detect_arch() {
    case "$(uname -m)" in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l)
            echo "arm"
            ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
}

install_kubectl() {
    if command -v kubectl &> /dev/null; then
        log_info "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
        return 0
    fi

    log_info "Downloading kubectl..."

    local arch
    arch=$(detect_arch)

    local version
    version=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    curl -LO "https://dl.k8s.io/release/${version}/bin/linux/${arch}/kubectl"
    chmod +x kubectl

    if [[ $EUID -eq 0 ]]; then
        mv kubectl /usr/local/bin/kubectl
        log_info "Installed to /usr/local/bin/kubectl"
    elif [[ -d /usr/local/bin ]] && sudo -n true 2>/dev/null; then
        sudo mv kubectl /usr/local/bin/kubectl
        log_info "Installed to /usr/local/bin/kubectl"
    else
        mkdir -p ~/.local/bin
        mv kubectl ~/.local/bin/kubectl
        log_info "Installed to ~/.local/bin/kubectl"
        log_warn "Add ~/.local/bin to your PATH if not already present"
    fi
}

configure_completion() {
    log_info "Configuring bash completion..."

    # System-wide completion (requires root)
    if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
        log_info "Bash completion installed to /etc/bash_completion.d/kubectl"
    else
        # User-local completion
        mkdir -p ~/.local/share/bash-completion/completions
        kubectl completion bash > ~/.local/share/bash-completion/completions/kubectl
        log_info "Bash completion installed to ~/.local/share/bash-completion/completions/kubectl"
    fi

    # Add alias
    if ! grep -q "alias k=kubectl" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# kubectl alias" >> ~/.bashrc
        echo "alias k=kubectl" >> ~/.bashrc
        echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
        log_info "Added alias 'k' for kubectl"
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "========================================"
    echo "  kubectl Installation"
    echo "========================================"
    echo ""

    install_kubectl
    echo ""

    configure_completion
    echo ""

    log_info "kubectl installation complete!"
    echo ""
    echo "Version: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    echo ""
    echo "Run 'source ~/.bashrc' or open a new terminal to use the 'k' alias"
    echo ""
}

main "$@"
