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
███████╗███████╗██████╗  ██████╗ ██████╗  █████╗               
██╔════╝██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔══██╗              
█████╗  █████╗  ██║  ██║██║   ██║██████╔╝███████║              
██╔══╝  ██╔══╝  ██║  ██║██║   ██║██╔══██╗██╔══██║              
██║     ███████╗██████╔╝╚██████╔╝██║  ██║██║  ██║              
╚═╝     ╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝              
                                                               
            ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗
            ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║
            ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║
            ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║
            ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║
            ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝
                                                               
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

backup_file() {
    log_info "Creating backup file..."
    if [ -f "$1" ]; then
        log_info "Backing up file: $1"
        cp "$1" "/tmp/$(basename "$1").bak"
    fi
}

restore_file() {
    log_info "Restoring backup file..."
    if [ -f "$1" ]; then
        log_info "Restoring file: $1"
        rm -f "$1"
        cp "/tmp/$(basename "$1").bak" "$1" 
    fi
}

clone_repository() {
    if [ -d "$INSTALL_DIR" ]; then
        log_info "fedoralaunch is already installed. Next time, run: fedoralaunch self-update..."
        log_info "Force self update..."
        backup_file "$INSTALL_DIR/config/.env"
        git -C "$INSTALL_DIR" fetch --all > /dev/null
        git -C "$INSTALL_DIR" reset --hard @{u} > /dev/null
        restore_file "$INSTALL_DIR/config/.env"
        log_success "fedoralaunch updated successfully."
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

    # Appply permissions
    chmod +x \
        "$INSTALL_DIR/fedoralaunch" \
        "$INSTALL_DIR/modules"/* \
        "$INSTALL_DIR/lib"/*

    log_success "fedoralaunch installed successfully!"
    echo
    log_info "Please run 'source ~/.bashrc' or open a new terminal to use the 'fedoralaunch' command."
    log_info "Then, you can run 'fedoralaunch --help' to get started."
}

main
