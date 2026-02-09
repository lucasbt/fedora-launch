#!/usr/bin/env bash
# Description: Base system configuration for Fedora Workstation
# Category: system
# Priority: 1

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

#
# -----------------------------
# Boot & Session Behavior
# -----------------------------
#
configure_boot_behavior() {
    log_section "Configuring boot and session behavior"

    sudo systemctl disable NetworkManager-wait-online.service >/dev/null 2>&1 || true
    sudo rm -f /etc/xdg/autostart/org.gnome.Software.desktop >/dev/null 2>&1 || true

    log_success "Boot behavior configured."
}

#
# -----------------------------
# System Update
# -----------------------------
#
update_system() {
    log_section "Updating system"

    sudo dnf upgrade --refresh -y
    sudo dnf group upgrade core -y

    log_success "System updated."
}

#
# -----------------------------
# Base Packages
# -----------------------------
#
install_base_packages() {
    log_section "Installing essential dependencies"

    dnf_install \
        flatpak curl wget git unzip tar gzip ca-certificates gnupg \
        dnf-plugins-core lsb-release dconf-editor util-linux \
        fontconfig fzf gnome-keyring libgnome-keyring \
        fedora-workstation-repositories openssl

    log_success "Base packages installed."
}

#
# -----------------------------
# Repositories
# -----------------------------
#
configure_repositories() {
    log_section "Configuring repositories"

    if [ "${FEDORALAUNCH_ENABLE_RPMFUSION_FREE_NONFREE_REPOS}" = true ]; then
        dnf_install \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        log_success "RPM Fusion enabled."
    else
        log_info "Skipping RPM Fusion."
    fi

    sudo flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

    log_success "Flathub configured."
}

#
# -----------------------------
# Firmware
# -----------------------------
#
configure_firmware() {
    if [ "${FEDORALAUNCH_INSTALL_PROPRIETARY_FIRMWARE}" != true ]; then
        log_info "Skipping firmware updates."
        return
    fi

    log_section "Updating firmware"

    dnf_install linux-firmware
    sudo fwupdmgr refresh --force || true
    sudo fwupdmgr update || true

    log_success "Firmware updated."
}

#
# -----------------------------
# Kernel Memory Tuning
# -----------------------------
#
configure_kernel_memory() {
    log_section "Applying kernel memory tuning (persistent)"

    # Resolve values at execution time (input → frozen state)
    local swappiness="${FEDORALAUNCH_SWAPPINESS}"
    local vfs_cache_pressure="${FEDORALAUNCH_VFS_CACHE_PRESSURE}"
    local dirty_ratio="${FEDORALAUNCH_DIRTY_RATIO}"
    local dirty_background_ratio="${FEDORALAUNCH_DIRTY_BACKGROUND_RATIO}"

    sudo tee /etc/sysctl.d/99-fedoralauch-memory.conf >/dev/null <<EOF
# Memory tuning for developer workstation
# Applied by fedoralauch on $(date -I)
# Source variables:
#   FEDORALAUNCH_SWAPPINESS=${swappiness}
#   FEDORALAUNCH_VFS_CACHE_PRESSURE=${vfs_cache_pressure}
#   FEDORALAUNCH_DIRTY_RATIO=${dirty_ratio}
#   FEDORALAUNCH_DIRTY_BACKGROUND_RATIO=${dirty_background_ratio}
#
vm.swappiness=${swappiness}
vm.vfs_cache_pressure=${vfs_cache_pressure}
vm.dirty_ratio=${dirty_ratio}
vm.dirty_background_ratio=${dirty_background_ratio}
EOF

    log_success "Kernel memory parameters written and frozen."
}


#
# -----------------------------
# Journald
# -----------------------------
#
configure_logging() {
    log_section "Configuring systemd-journald (persistent)"

    # Resolve value at execution time
    local journal_max_size="${FEDORALAUNCH_JOURNAL_MAX_SIZE}"

    sudo mkdir -p /etc/systemd/journald.conf.d
    sudo tee /etc/systemd/journald.conf.d/99-fedoralauch.conf >/dev/null <<EOF
[Journal]
# Applied by fedoralauch on $(date -I)
SystemMaxUse=${journal_max_size}
EOF

    log_success "Journald configuration written."
}

#
# -----------------------------
# Main
# -----------------------------
#
system_base_main() {
    print_header "System Base Configuration"

    configure_boot_behavior
    update_system
    install_base_packages
    configure_repositories
    configure_firmware
    configure_kernel_memory
    configure_logging

    print_footer "System Base Configuration Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    system_base_main
fi
