#!/usr/bin/env bash
# Description: Base system configuration
# Category: system
# Priority: 1

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

system_base_main() {
    print_header "System Base Configuration"

    log_section "System init configuration"
    sudo systemctl disable NetworkManager-wait-online.service >/dev/null 2>&1 || true
    sudo rm -rf /etc/xdg/autostart/org.gnome.Software.desktop >/dev/null 2>&1 || true
    sudo rm -rf /etc/yum.repos.d/{_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo,rpmfusion-nonfree-nvidia-driver.repo,rpmfusion-nonfree-steam.repo} >/dev/null 2>&1 || true
    log_section "System init configuration applied."

    log_section "Update System"
    sudo dnf -y update --refresh 
    sudo dnf upgrade -y
    sudo dnf group upgrade core -y
    sudo dnf4 group install core -y
    log_success "System updated."

    log_section "Installing essential dependencies..."
    dnf_install flatpak curl wget git unzip tar gzip ca-certificates gnupg dnf-plugins-core lsb-release \
        dconf-editor util-linux fontconfig fzf fedora-workstation-repositories gnome-keyring libgnome-keyring
    log_success "Essential dependencies installed."

    log_section "Optimizing DNF"
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
        log_success "Set max parallel downloads to 10."
    else
        log_info "DNF is already optimized."
    fi

    log_section "Enabling RPM Fusion Repositories"
    if [ "${FEDORALAUNCH_ENABLE_RPMFUSION_FREE_NONFREE_REPOS}" = true ]; then
        dnf_install \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        dnf_install rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted

        log_success "RPM Fusion repositories enabled."
    else
        log_info "Skipping RPM Fusion repositories."
    fi

    log_section "Configuring Flathub repository"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak update -y
    log_success "Flathub repository configured."

    log_section "Installing Proprietary Firmware"
    if [ "${FEDORALAUNCH_INSTALL_PROPRIETARY_FIRMWARE}" = true ]; then
        dnf_install linux-firmware
        log_section "Update Firmwares"
        sudo fwupdmgr refresh --force >/dev/null 2>&1 || true
        sudo fwupdmgr get-devices >/dev/null 2>&1 || true
        sudo fwupdmgr get-updates >/dev/null 2>&1 || true
        sudo fwupdmgr update >/dev/null 2>&1 || true
        log_success "Firmwares updated."
    else
        log_info "Skipping proprietary firmware installation."
    fi

    log_section "Configuring Swappiness"
    echo "vm.swappiness=${FEDORALAUNCH_SWAPPINESS}" | sudo tee /etc/sysctl.d/99-swappiness.conf
    log_success "Swappiness configured to ${FEDORALAUNCH_SWAPPINESS}."

    log_section "Configuring VFS Cache Pressure"
    echo "vm.vfs_cache_pressure=${FEDORALAUNCH_VFS_CACHE_PRESSURE}" | sudo tee /etc/sysctl.d/99-vfs-cache-pressure.conf
    log_success "VFS cache pressure configured to ${FEDORALAUNCH_VFS_CACHE_PRESSURE}."
    
    log_section "Configuring Dirty Page Ratios"
    echo "vm.dirty_ratio=${FEDORALAUNCH_DIRTY_RATIO}" | sudo tee /etc/sysctl.d/99-dirty-ratio.conf
    echo "vm.dirty_background_ratio=${FEDORALAUNCH_DIRTY_BACKGROUND_RATIO}" | sudo tee -a /etc/sysctl.d/99-dirty-ratio.conf
    log_success "Dirty page ratios configured."
    
    log_section "Configuring I/O Scheduler"
    echo "ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTR{queue/scheduler}=\"${FEDORALAUNCH_IO_SCHEDULER}\"" | sudo tee /etc/udev/rules.d/60-ioscheduler.rules
    log_success "I/O scheduler configured to ${FEDORALAUNCH_IO_SCHEDULER}."
    
    log_section "Configuring Journal Max Size"
    sudo touch /etc/systemd/journald.conf
    sudo sed -i "s/#SystemMaxUse=/SystemMaxUse=${FEDORALAUNCH_JOURNAL_MAX_SIZE}/" /etc/systemd/journald.conf
    log_success "Journal max size configured to ${FEDORALAUNCH_JOURNAL_MAX_SIZE}."

    print_success "System Base Configuration Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    system_base_main
fi
