#!/usr/bin/env bash
# Description: Multimedia, Fonts and Icons
# Category: customization
# Priority: 8

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

###############################################################################
# Multimedia
###############################################################################

install_multimedia_codecs() {
    log_section "Installing Multimedia Codecs"

    # OpenH264 (Firefox + GStreamer)
    dnf_install openh264 gstreamer1-plugin-openh264 mozilla-openh264

    # Base audio/video stack
    dnf_install --allowerasing \
        gstreamer1-plugins-base \
        gstreamer1-plugins-good \
        gstreamer1-plugins-bad-free \
        gstreamer1-plugins-ugly-free \
        gstreamer1-libav \
        lame lame-libs \
        ffmpeg-libs \
        x264 x265 \
        faac faad2 \
        libavcodec-freeworld \
        amrnb amrwb flac gpac-libs libde265 libfc14audiodecoder mencoder

    # VA / VDPAU / Intel
    dnf_install \
        mesa-dri-drivers \
        mesa-vulkan-drivers \
        mesa-va-drivers \
        mesa-vdpau-drivers \
        intel-media-driver \
        libva libva-utils \
        libva-intel-driver \
        libvdpau-va-gl

    # Non-free ugly plugins (if enabled)
    if dnf repolist | grep -q rpmfusion-nonfree; then
        dnf_install gstreamer1-plugins-ugly
    fi

    log_success "Multimedia codecs installed."
}

configure_multimedia_groups() {
    log_section "Configuring Multimedia Groups & FFmpeg"

    sudo dnf4 group install -y multimedia --skip-broken
    sudo dnf group install -y sound-and-video --skip-broken

    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf upgrade -y @multimedia \
        --setopt="install_weak_deps=False" \
        --exclude=PackageKit-gstreamer-plugin

    log_success "Multimedia groups configured."
}

###############################################################################
# Fonts
###############################################################################

install_fonts_repos() {
    log_section "Installing Fonts (Repositories)"

    dnf_install \
        xorg-x11-font-utils \
        fira-code-fonts \
        jetbrains-mono-fonts \
        rsms-inter-fonts \
        google-roboto-fonts \
        google-noto-sans-fonts \
        liberation-fonts \
        dejavu-sans-fonts \
        fontconfig \
        unzip curl cabextract

    log_success "Repository fonts installed."
}

install_microsoft_fonts() {
    log_section "Installing Microsoft Core Fonts"

    if rpm -q msttcore-fonts-installer &>/dev/null; then
        log_info "Microsoft Core Fonts already installed."
        return 0
    fi

    local rpm_tmp="$CACHE_DIR/msttcore-fonts-installer.rpm"

    curl -L \
        "https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm" \
        -o "$rpm_tmp" || {
            log_warning "Failed to download Microsoft fonts RPM."
            return 0
        }

    sudo rpm -i --nodigest --percent "$rpm_tmp" || \
        log_warning "Microsoft fonts installation failed (SourceForge instability)."

    log_success "Microsoft Core Fonts processed."
}

refresh_font_cache() {
    log_info "Updating font cache..."
    fc-cache -f
    log_success "Font cache updated."
}

###############################################################################
# Icons
###############################################################################

install_icon_themes_repo() {
    log_section "Installing Icon Themes (Repositories)"

    dnf_install \
        papirus-icon-theme \
        libreoffice-icon-theme-papirus \
        paper-icon-theme \
        numix-icon-theme-square \
        material-icons-fonts

    log_success "Repository icon themes installed."
}

install_tela_icons() {
    log_section "Installing Tela Icon Theme"

    local target_dir="$HOME/.local/share/icons/Tela"

    if [[ -d "$target_dir" ]]; then
        log_info "Tela Icon Theme already installed."
        return 0
    fi

    local tmp_dir="$CACHE_DIR/tela-icon-theme"
    mkdir -p "$temp_dir"

    git clone https://github.com/vinceliuice/Tela-icon-theme.git "$tmp_dir"
    "$tmp_dir/install.sh" -d "$HOME/.local/share/icons"

    log_success "Tela Icon Theme installed."
}

###############################################################################
# Main
###############################################################################

media_fonts_icons_main() {
    print_header "Multimedia, Fonts & Icons"

    install_multimedia_codecs
    configure_multimedia_groups

    install_fonts_repos
    install_microsoft_fonts
    refresh_font_cache

    install_icon_themes_repo
    install_tela_icons

    print_footer "Multimedia, Fonts & Icons installation completed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    media_fonts_icons_main
fi
