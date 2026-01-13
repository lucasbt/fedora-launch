#!/usr/bin/env bash
#
# bootstrap.sh - Installer for fedoralaunch
#
# Usage: curl -fsSL https://raw.githubusercontent.com/lucasbt/fedora-launch/main/bootstrap.sh | bash
#

set -euo pipefail

# ---
# ## Variables
# ---
INSTALL_DIR="$HOME/.local/share/fedoralaunch"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/lucasbt/fedora-launch.git"

# ---
# ## Functions
# ---

# Color codes
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'

log_info() {
    echo -e "${COLOR_BLUE}•${COLOR_RESET} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $1"
}

print_header() {
    echo -e "\n${COLOR_CYAN}🔨 $1${COLOR_RESET}\n"
}

show_banner() {
    echo -e "${COLOR_BLUE}"
    cat << "EOF"
  ___ ___ ___  ___  ___   _   _      _   _  _  _  _  ___ _  _ 
 | __| __|   \/ _ \| _ \ /_\ | |    /_\ | || \| || |/ __| || |
 | _|| _|| |)| (_) |   // _ \| |__ / _ \| \/ | || | (__| __ |
 |_| |___|___/\___/|_|_/_/ \_\____/_/ \_\___/ \__/ \___|_||_|
EOF
    echo -e "${COLOR_RESET}"
    echo -e "             ${COLOR_CYAN}Fedora Workstation Post-Install Setup${COLOR_RESET}\n"
}

check_dependencies() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install it first."
        exit 1
    fi
}

clone_repository() {
    if [ -d "$INSTALL_DIR" ]; then
        log_info "fedoralaunch is already installed. To update run: fedoralaunch self-update..."
        git -C "$INSTALL_DIR" pull
    else
        log_info "Cloning fedoralaunch repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
}

setup_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_info "Adding $BIN_DIR to your PATH."
        echo "export PATH=\"
$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
    fi
}

create_symlink() {
    mkdir -p "$BIN_DIR"
    ln -sf "$INSTALL_DIR/fedoralaunch" "$BIN_DIR/fedoralaunch"
}

# ---
# ## Main Execution
# ---

main() {
    show_banner
    print_header "Installing fedoralaunch"    
    check_dependencies
    clone_repository
    setup_path
    create_symlink

    log_success "fedoralaunch installed successfully!"
    echo
    log_info "Please run 'source ~/.bashrc' or open a new terminal to use the 'fedoralaunch' command."
    log_info "Then, you can run 'fedoralaunch --help' to get started."
}

main
