#!/usr/bin/env bash
#
# lib/utils.sh
#
# Shared utility functions for fedoralaunch scripts.
#

# ---
# ## Variables
# ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/.env"
LOG_DIR="$HOME/.local/cache/fedoralaunch"
LOG_FILE="${LOG_DIR}/fedoralaunch.log"

# ---
# ## Logging
# ---

# Color codes
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'

log_info() {
    echo -e "${COLOR_BLUE}• $1${COLOR_RESET}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - INFO - $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${COLOR_GREEN}✓ $1${COLOR_RESET}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - SUCCESS - $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${COLOR_YELLOW}! $1${COLOR_RESET}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - WARNING - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${COLOR_RED}✗ $1${COLOR_RESET}" >&2
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERROR - $1" >> "$LOG_FILE"
}

log_debug() {
    if [ "${FEDORALAUNCH_VERBOSE:-false}" = true ]; then
        echo -e "${COLOR_CYAN}DEBUG: $1${COLOR_RESET}"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - DEBUG - $1" >> "$LOG_FILE"
    fi
}

print_header() {
    echo -e "\n${COLOR_CYAN}🔨 $1${COLOR_RESET}\n"
}

log_section() {
    echo -e "\n${COLOR_YELLOW}--- $1 ---${COLOR_RESET}"
}

show_banner() {
    echo -e "${COLOR_BLUE}"
    cat << "EOF"
 _______ _______ _____    _____  ______             
(_______|_______|____ \  / ___ \(_____ \   /\       
 _____   _____   _   \ \| |   | |_____) ) /  \      
|  ___) |  ___) | |   | | |   | (_____ ( / /\ \     
| |     | |_____| |__/ /| |___| |     | | |__| |    
|_|     |_______)_____/  \_____/      |_|______|    
                                                        
        _              _     _ ______   ______ _     _ 
        | |        /\  | |   | |  ___ \ / _____) |   | |
        | |       /  \ | |   | | |   | | /     | |__ | |
        | |      / /\ \| |   | | |   | | |     |  __)| |
        | |_____| |__| | |___| | |   | | \_____| |   | |
        |_______)______|\______|_|   |_|\______)_|   |_|
                                                    
EOF
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Post-install setup for Fedora 43+ made easy!${COLOR_RESET}\n"
}

# ---
# ## Command Execution
# ---

run_cmd() {
    log_debug "Running command: $1"
    if [ "${FEDORALAUNCH_VERBOSE:-false}" = true ]; then
        eval "$1"
    else
        eval "$1" &> /dev/null
    fi
}

run_cmd_visible() {
    log_debug "Running command: $1"
    eval "$1"
}

# ---
# ## System Checks
# ---

check_fedora() {
    if ! grep -q "Fedora" /etc/os-release; then
        log_error "This script is intended for Fedora only."
        exit 1
    fi
}

is_intel_gpu() {
    lspci | grep -i "VGA compatible controller" | grep -i "intel" &> /dev/null
}

detect_gpu_vendor() {
    lspci | grep -i "VGA compatible controller" | awk -F' ' '{print $5}'
}

# ---
# ## gsettings Management
# ---

gs_set() {
    local schema="$1"
    local key="$2"
    local value="$3"
    log_info "Setting gsettings key '$key' to '$value'"
    gsettings set "$schema" "$key" "$value"
}

gs_get() {
    local schema="$1"
    local key="$2"
    gsettings get "$schema" "$key"
}

# ---
# ## Package Management
# ---

dnf_install() {
    log_info "Installing DNF packages: $*"
    sudo dnf install -y "$@"
}

flatpak_install() {
    log_info "Installing Flatpak packages: $*"
    flatpak install -y --noninteractive flathub "$@"
}

# ---
# ## File System
# ---

ensure_dir() {
    local dir="$1"
    [ -n "$dir" ] || return 1

    # Expande ~ para $HOME
    dir="${dir/#\~/$HOME}"

    # Já existe? Nada a fazer
    [ -d "$dir" ] && return 0

    # Se o diretório estiver dentro do $HOME, cria sem sudo
    if [[ "$dir" == "$HOME"* ]]; then
        mkdir -p -- "$dir"
        log_info "Created directory: $dir"
        return 0
    fi

    # Caso contrário, verifica se o diretório pai é gravável
    local parent="$dir"
    while [ ! -e "$parent" ] && [ "$parent" != "/" ]; do
        parent=$(dirname "$parent")
    done

    if [ -w "$parent" ]; then
        mkdir -p -- "$dir"
        log_info "Created directory: $dir"
    else
        superuser_do mkdir -p -- "$dir"
        log_info "Created directory: $dir"
    fi
}

backup_file() {
    if [ -f "$1" ]; then
        log_info "Backing up file: $1 to $1.bak"
        cp "$1" "$1.bak"
    fi
}

create_script() {
    log_info "Creating script: $1"
    cat > "$1"
    chmod +x "$1"
}

# Service management
enable_service() {
    local service="$1"
    local description="${2:-$service}"

    log_info "Enabling $description service..."
    if superuser_do systemctl enable "$service"; then
        log_success "$description service enabled"
        return 0
    else
        log_failed "Failed to enable $description service"
        return 1
    fi
}

start_service() {
    local service="$1"
    local description="${2:-$service}"

    log_info "Starting $description service..."
    if superuser_do systemctl start "$service"; then
        log_success "$description service started"
        return 0
    else
        log_failed "Failed to start $description service"
        return 1
    fi
}

# ---
# ## Other Utilities
# ---

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log_debug "Loading configuration from $CONFIG_FILE"
        set -o allexport
        source "$CONFIG_FILE"
        set +o allexport
    else
        log_warning "Configuration file not found: $CONFIG_FILE"
    fi
}

init_logging() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
}
