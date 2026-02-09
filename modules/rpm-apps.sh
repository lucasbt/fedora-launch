#!/usr/bin/env bash
# Description: RPM applications
# Category: apps
# Priority: 6

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

###############################################################################
# Browsers
###############################################################################

install_chrome() {
    log_section "Installing Google Chrome"
    sudo dnf install -y fedora-workstation-repositories
    dnf_install google-chrome-stable
    log_success "Google Chrome installed."
}

###############################################################################
# Desktop Applications
###############################################################################

install_desktop_apps() {
    log_section "Installing Desktop Applications"
    dnf_install telegram vlc libreoffice
    log_success "Desktop applications installed."
}

###############################################################################
# Bitwarden
###############################################################################

install_bitwarden_gui() {
    log_section "Installing Bitwarden (GUI)"

    local install_dir="/opt/bitwarden"
    local appimage="$install_dir/Bitwarden.AppImage"
    local desktop="$HOME/.local/share/applications/bitwarden.desktop"
    local temp_dir="$CACHE_DIR"

    if [[ -x "$appimage" ]]; then
        log_info "Bitwarden GUI already installed"
        return 0
    fi

    mkdir -p "$temp_dir"
    sudo mkdir -p "$install_dir"

    curl -L \
        "https://vault.bitwarden.com/download/?app=desktop&platform=linux" \
        -o "$temp_dir/Bitwarden.AppImage"

    sudo mv "$temp_dir/Bitwarden.AppImage" "$appimage"
    sudo chmod +x "$appimage"

    sudo curl -L \
        https://raw.githubusercontent.com/bitwarden/clients/main/apps/desktop/resources/icons/256x256.png \
        -o "$install_dir/bitwarden.png"

    sudo ln -sf "$appimage" /usr/local/bin/bitwarden

    mkdir -p "$(dirname "$desktop")"
    cat > "$desktop" <<EOF
[Desktop Entry]
Name=Bitwarden
Exec=$appimage
Icon=$install_dir/bitwarden.png
Terminal=false
Type=Application
Categories=Utility;Security;
StartupNotify=true
EOF

    chmod +x "$desktop"

    log_success "Bitwarden GUI installed."
}

install_bitwarden_cli() {
    log_section "Installing Bitwarden CLI"

    local install_dir="/opt/bitwarden-cli"
    local temp_dir="$CACHE_DIR"

    if [[ -x "$install_dir/bw" ]]; then
        log_info "Bitwarden CLI already installed"
        return 0
    fi

    mkdir -p "$temp_dir"
    sudo mkdir -p "$install_dir"

    curl -L \
        "https://vault.bitwarden.com/download/?app=cli&platform=linux" \
        -o "$temp_dir/bw.zip"

    unzip -q "$temp_dir/bw.zip" -d "$temp_dir"
    sudo mv "$temp_dir/bw" "$install_dir/"
    sudo chmod +x "$install_dir/bw"
    sudo ln -sf "$install_dir/bw" /usr/local/bin/bw

    log_success "Bitwarden CLI installed."
}

###############################################################################
# CLI / System Utilities
###############################################################################

install_cli_tools() {
    log_section "Installing CLI & System Tools"

    dnf_install \
        htop btop tree rsync wget bat ripgrep fzf tmux \
        nmap telnet whois traceroute iperf3 iotop ncdu duf lsof strace \
        zip unzip tar gzip bzip2 xz unrar p7zip p7zip-plugins \
        jq yq sed gawk grep openssl readline bash-completion \
        exfatprogs inxi mediainfo pciutils openssh-clients \
        cloc fastfetch figlet lm_sensors timew cronie \
        xclip wl-clipboard tldr sqlite pv stow foliate \
        httpie flatseal file-roller dconf-editor \
        cifs-utils fuse fuse-sshfs gvfs-fuse \
        gnome-tweaks gnome-extensions-app \
        gtk-murrine-engine gtk2-engines gnome-themes-extra \
        fd-find

    log_success "CLI & system tools installed."
}

###############################################################################
# LibreOffice extras
###############################################################################

install_libreoffice_extras() {
    log_section "Installing LibreOffice extras (pt-BR)"

    dnf_install \
        libreoffice-help-pt-BR \
        libreoffice-langpack-pt-BR \
        autocorr-pt

    log_success "LibreOffice extras installed."
}

###############################################################################
# GNOME tweaks
###############################################################################

hide_apps_from_gnome_grid() {
    log_section "Hiding some CLI apps from GNOME grid"

    for file in /usr/share/applications/htop.desktop /usr/share/applications/btop.desktop; do
        if [[ -f "$file" ]]; then
            if grep -q "^NoDisplay=" "$file"; then
                sudo sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$file"
            else
                sudo sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
            fi
        fi
    done

    log_success "GNOME app grid cleaned."
}

###############################################################################
# Main
###############################################################################

rpm_apps_main() {
    print_header "RPM Applications Installation"

    install_chrome
    install_desktop_apps

    install_bitwarden_gui
    install_bitwarden_cli

    install_cli_tools
    install_libreoffice_extras
    hide_apps_from_gnome_grid

    print_footer "RPM Applications Installation Completed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    rpm_apps_main
fi
