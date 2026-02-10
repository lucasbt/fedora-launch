#!/usr/bin/env bash
#
# bootstrap.sh - Installer for fedoralaunch
#
# Usage: curl -fsSL https://raw.githubusercontent.com/lucasbt/fedora-launch/main/bootstrap.sh | bash
#

set -euo pipefail

###############################################################################
# Variables
###############################################################################

INSTALL_DIR="$HOME/.local/share/fedoralaunch"
BIN_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/lucasbt/fedora-launch.git"

###############################################################################
# Logging helpers
###############################################################################

COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_RED='\033[0;31m'

log_info() {
    echo -e "${COLOR_BLUE}•${COLOR_RESET} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_RED}✗${COLOR_RESET} $1" >&2
}

print_header() {
    echo -e "\n${COLOR_CYAN}🔨 $1${COLOR_RESET}\n"
}

###############################################################################
# UI
###############################################################################

show_banner() {
    echo -e "${COLOR_BLUE}"
    cat << "EOF"
     ______         __                     __                           __  
    / ____/__  ____/ /___  _________ _    / /   ____ ___  ______  _____/ /_ 
   / /_  / _ \/ __  / __ \/ ___/ __ `/   / /   / __ `/ / / / __ \/ ___/ __ \
  / __/ /  __/ /_/ / /_/ / /  / /_/ /   / /___/ /_/ / /_/ / / / / /__/ / / /
 /_/    \___/\__,_/\____/_/   \__,_/   /_____/\__,_/\__,_/_/ /_/\___/_/ /_/ 
EOF
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_CYAN} ================ Fedora Workstation Post-Install Setup ==================${COLOR_RESET}\n"
}

###############################################################################
# Helpers
###############################################################################

check_dependencies() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install it first."
        exit 1
    fi
}

backup_file() {
    if [ -f "$1" ]; then
        log_info "Backing up file: $1"
        cp "$1" "/tmp/$(basename "$1").bak"
    fi
}

restore_file() {
    local backup="/tmp/$(basename "$1").bak"
    if [ -f "$backup" ]; then
        log_info "Restoring file: $1"
        rm -f "$1"
        cp "$backup" "$1"
    fi
}

###############################################################################
# Core logic
###############################################################################

clone_repository() {
    if [ -d "$INSTALL_DIR" ]; then
        log_info "fedoralaunch is already installed. Forcing self-update..."

        backup_file "$INSTALL_DIR/config/.env"

        git config --global credential.helper 'cache --timeout=3600'
        git -C "$INSTALL_DIR" fetch --all
        git -C "$INSTALL_DIR" reset --hard origin/main
        git -C "$INSTALL_DIR" pull origin main

        restore_file "$INSTALL_DIR/config/.env"
        log_success "fedoralaunch self updated."
    else
        log_info "Cloning fedoralaunch repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
}

setup_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_info "Adding $BIN_DIR to your PATH."
        echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
    fi
}

create_symlink() {
    mkdir -p "$BIN_DIR"
    ln -sf "$INSTALL_DIR/fedoralaunch" "$BIN_DIR/fedoralaunch"
}

###############################################################################
# Main
###############################################################################

main() {
    show_banner
    print_header "Installing fedoralaunch"

    if [ ! -f /etc/fedora-release ]; then
        log_error "This script is intended for Fedora Workstation only."
        exit 1
    fi

    check_dependencies
    clone_repository
    setup_path
    create_symlink

    find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;
    chmod +x "$INSTALL_DIR/fedoralaunch"

    log_success "fedoralaunch installed successfully!"
    echo
    log_info "Run 'source ~/.bashrc' or open a new terminal."
    log_info "Then execute: fedoralaunch --help"
}

main
