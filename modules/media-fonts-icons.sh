#!/usr/bin/env bash
# Description: Multimedia, Fonts and Icons
# Category: customization
# Priority: 8

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

media_fonts_icons_main() {
    print_header "Multimedia, Fonts & Icons"

    # --- Multimedia ---
    log_section "Installing Multimedia Support"
    
    # OpenH264
    dnf_install openh264 gstreamer1-plugin-openh264 mozilla-openh264

    # Audio/Video Codecs
    # Installing base plugins and ffmpeg-based libav
    dnf_install --allowerasing gstreamer1-plugins-base gstreamer1-plugins-good \
        gstreamer1-plugins-bad-free gstreamer1-plugins-ugly-free \
        gstreamer1-libav lame lame-libs ffmpeg-libs x264 x265 faac faad2 \
        libavcodec-freeworld mesa-va-drivers mesa-vdpau-drivers intel-media-driver \
        libva libva-utils mesa-dri-drivers mesa-vulkan-drivers libva-intel-driver \
        libvdpau-va-gl amrnb amrwb flac gpac-libs libde265 libfc14audiodecoder mencoder

    # Attempt to install non-free ugly plugins if RPM Fusion is enabled
    if dnf repolist | grep -q "rpmfusion-nonfree"; then
        dnf_install gstreamer1-plugins-ugly
    fi

    log_info "Configuring multimedia groups and swapping ffmpeg..."
    sudo dnf4 group install multimedia -y --skip-broken
    sudo dnf group install -y --skip-broken sound-and-video
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    
    log_success "Multimedia support installed."

    # --- Fonts ---
    log_section "Installing Fonts"
    
    # Repository fonts & tools
    dnf_install xorg-x11-font-utils fira-code-fonts jetbrains-mono-fonts rsms-inter-fonts google-roboto-fonts \
        google-noto-sans-fonts liberation-fonts dejavu-sans-fonts unzip curl cabextract fontconfig

    # Microsoft Fonts (Core Fonts)
    if ! rpm -q msttcore-fonts-installer >/dev/null 2>&1; then
        log_info "Installing Microsoft Core Fonts..."
        local ms_fonts_rpm="/tmp/msttcore-fonts-installer.rpm"
        curl -L "https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm" -o "$ms_fonts_rpm"
        # We use || true to not break the script if sourceforge is down/slow
        sudo rpm -i --nodigest --percent "$ms_fonts_rpm" || log_warning "Microsoft fonts installation failed (SourceForge issue)."
        rm -f "$ms_fonts_rpm"
    else
        log_info "Microsoft Core Fonts already installed."
    fi
    log_success "Fonts installed."

    # --- Icons ---
    log_section "Installing Icon Themes"
    
    # Repository icons
    dnf_install papirus-icon-theme libreoffice-icon-theme-papirus paper-icon-theme numix-icon-theme-square material-icons-fonts

    # Tela Icons (from source)
    if [ ! -d "$HOME/.local/share/icons/Tela" ]; then
        log_info "Installing Tela Icon Theme..."
        local tela_dir="/tmp/tela-icon-theme"
        rm -rf "$tela_dir"
        git clone https://github.com/vinceliuice/Tela-icon-theme.git "$tela_dir"
        "$tela_dir/install.sh" -d "$HOME/.local/share/icons"
        rm -rf "$tela_dir"
        log_success "Tela Icon Theme installed."
    else
        log_info "Tela Icon Theme already installed."
    fi

    log_success "Icon themes installed."

    print_footer "Multimedia, Fonts & Icons installation completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    media_fonts_icons_main
fi