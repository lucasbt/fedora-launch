#!/usr/bin/env bash
# Description: RPM applications
# Category: apps
# Priority: 6

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

install_bitwarden_gui() {
    log_info "Installing Bitwarden (GUI)..."

    local install_dir="/opt/bitwarden"
    local appimage_path="$install_dir/Bitwarden.AppImage"
    local bin_symlink="/usr/local/bin/bitwarden"
    local desktop_file="$HOME/.local/share/applications/bitwarden.desktop"
    local temp_dir="/tmp/bitwarden"
    local temp_appimage="$temp_dir/Bitwarden.AppImage"
    local download_url="https://vault.bitwarden.com/download/?app=desktop&platform=linux" # redirects to AppImage

    # Check if already installed
    if [[ -f "$appimage_path" && -x "$appimage_path" ]]; then
        log_info "Bitwarden already installed at $install_dir"
        return 0
    fi

    mkdir -p "$temp_dir"
    sudo mkdir -p "$install_dir"
    sudo chmod 755 "$install_dir"

    log_info "Downloading Bitwarden AppImage..."
    if curl -L -o "$temp_appimage" "$download_url"; then
        sudo mv "$temp_appimage" "$appimage_path"
        sudo chmod +x "$appimage_path"
        sudo curl -L -o "$install_dir/bitwarden.png" https://raw.githubusercontent.com/bitwarden/clients/main/apps/desktop/resources/icons/256x256.png        

        # Create symlink
        sudo ln -sf "$appimage_path" "$bin_symlink"
        log_info "Created symlink: $bin_symlink → Bitwarden"

        # Create .desktop launcher
        mkdir -p "$(dirname "$desktop_file")"
        cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Bitwarden
Exec=$appimage_path
Icon=$install_dir/bitwarden.png
Terminal=false
Categories=Utility;Security;
StartupNotify=true
EOF

        chmod +x "$desktop_file"
        log_success "Bitwarden GUI installed successfully and launcher created"
    else
        log_warning "Failed to download Bitwarden"
        return 1
    fi

    # Clean temp
    rm -rf "$temp_dir"
}

install_bitwarden_cli() {
    log_info "Installing Bitwarden CLI..."

    local install_dir="/opt/bitwarden-cli"
    local bin_symlink="/usr/local/bin/bw"
    local temp_dir="/tmp/bitwarden-cli"
    local archive_path="$temp_dir/bw.zip"
    local download_url="https://vault.bitwarden.com/download/?app=cli&platform=linux"

    # Check if already installed
    if [[ -f "$install_dir/bw" && -x "$install_dir/bw" ]]; then
        log_info "Bitwarden CLI already installed at $install_dir"
        return 0
    fi

    mkdir -p "$temp_dir"
    sudo mkdir -p "$install_dir"

    log_info "Downloading Bitwarden CLI..."
    if curl -L -o "$archive_path" "$download_url"; then
        unzip -q "$archive_path" -d "$temp_dir"
        sudo mv "$temp_dir/bw" "$install_dir/"
        sudo chmod +x "$install_dir/bw"

        # Create symlink
        sudo ln -sf "$install_dir/bw" "$bin_symlink"
        log_info "Created symlink: $bin_symlink → bw"

        log_success "Bitwarden CLI installed successfully"
    else
        log_failed "Failed to download Bitwarden CLI"
        return 1
    fi

    # Clean temp
    rm -rf "$temp_dir"
}

rpm_apps_main() {
    print_header "RPM Applications Installation"

    log_section "Installing Google Chrome"
    sudo dnf install -y fedora-workstation-repositories
    dnf_install google-chrome-stable
    log_success "Google Chrome installed."

    log_section "Installing Brave Browser"
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo tee /etc/yum.repos.d/brave-browser.repo <<EOF
[brave-browser]
name=Brave Browser
baseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF

    dnf_install brave-browser
    log_success "Brave Browser installed."
    
    log_section "Installing Telegram"
    dnf_install telegram
    log_success "Telegram installed."
    
    log_section "Installing VLC"
    dnf_install vlc
    log_success "VLC installed."
    
    log_section "Installing LibreOffice"
    dnf_install libreoffice
    log_success "LibreOffice installed."

    log_section "Installing Bitwarden GUI and CLI"
    install_bitwarden_gui
    install_bitwarden_cli
    log_success "Bitwarden GUI and CLI installed."

    log_section "Installing extras rpm tools"
    dnf_install htop btop tree rsync wget bat ripgrep fzf tmux libvirt cabextract \
        nmap telnet whois traceroute iperf3 iotop ncdu duf lsof strace nautilus-extensions \
        zip unzip tar gzip bzip2 xz unrar p7zip p7zip-plugins jq yq sed gawk grep \
        openssl zlib readline bash-completion gnome-tweaks gnome-extensions-app exfatprogs \
        inxi mediainfo gparted pciutils openssh-clients symlinks youtube-dl libreoffice \
        autocorr-pt libreoffice-help-pt-BR libreoffice-langpack-pt-BR cozy transmission \
        cloc fastfetch figlet lsd hplip hplip-common hplip-libs lm_sensors timew cronie \
        xclip tldr sqlite pv stow foliate wl-clipboard util-linux-user \
        httpie flatseal file-roller dconf-editor cifs-utils fuse fuse-sshfs gvfs-fuse \
        gtk-murrine-engine gtk2-engines adw-gtk3-theme sassc glib2-devel gnome-themes-extra fd-find
    log_success "Extras RPM tools installed."

    log_section "Set display false to gnome apps grid for some apps..." #############################
    for file in /usr/share/applications/htop.desktop /usr/share/applications/btop.desktop; do
        if [ -f "$file" ]; then
            if grep -q "^NoDisplay=" "$file"; then
                # Já existe uma linha NoDisplay, vamos alterar seu valor para true
                sudo sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$file"
            else
                # Adiciona NoDisplay=true logo após a linha [Desktop Entry]
                sudo sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
            fi
        else
            log_warning "File not found: $file"
        fi
    done
    log_success "Set display false to gnome apps grid for some apps applied."

    print_footer "RPM Applications Installation Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    rpm_apps_main
fi
