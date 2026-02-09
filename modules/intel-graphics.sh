#!/usr/bin/env bash
# Description: Intel graphics drivers and VA-API configuration (Haswell-friendly)
# Category: hardware
# Priority: 2

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

# --------------------------------------------------
# Validation
# --------------------------------------------------
check_intel_gpu() {
    if ! is_intel_gpu; then
        log_warning "No Intel GPU detected. Skipping Intel graphics configuration."
        return 1
    fi
    return 0
}

# --------------------------------------------------
# Drivers
# --------------------------------------------------
install_intel_graphics_drivers() {
    log_section "Installing Intel Mesa and VA-API drivers"

    dnf_install \
        mesa-dri-drivers \
        mesa-vulkan-drivers \
        mesa-va-drivers \
        libva-utils \
        intel-media-driver

    log_success "Mesa and VA-API drivers installed."
}

# --------------------------------------------------
# VA-API Environment
# --------------------------------------------------
configure_vaapi_environment() {
    log_section "Configuring VA-API environment variables (Haswell)"

    sudo mkdir -p /etc/profile.d

    cat <<EOF | sudo tee /etc/profile.d/intel-vaapi.sh > /dev/null
# Intel Haswell VA-API configuration
export LIBVA_DRIVER_NAME=i965

# Force Firefox to run natively on Wayland
export MOZ_ENABLE_WAYLAND=1
EOF

    sudo chmod 644 /etc/profile.d/intel-vaapi.sh

    log_success "VA-API environment configured (i965 + Wayland)."
}

# --------------------------------------------------
# Validation helper (non-fatal)
# --------------------------------------------------
validate_vaapi() {
    log_section "Validating VA-API availability (optional)"

    if command -v vainfo >/dev/null 2>&1; then
        vainfo >/dev/null 2>&1 && \
            log_success "VA-API appears functional (vainfo OK)." || \
            log_warning "vainfo failed — check VA-API after reboot."
    else
        log_info "vainfo not available. Skipping validation."
    fi
}

configure_firefox_media_policies() {
    log_section "Configuring Firefox media policies (VA-API + Night Light friendly)"

    sudo mkdir -p /etc/firefox/policies

    cat <<'EOF' | sudo tee /etc/firefox/policies/policies.json > /dev/null
{
  "policies": {
    "Preferences": {
      "media.ffmpeg.vaapi.enabled": true,
      "media.hardware-video-decoding.enabled": true,
      "media.ffmpeg.vaapi-drm-display.enabled": false,
      "gfx.webrender.all": true,
      "media.av1.enabled": false
    }
  }
}
EOF

    log_success "Firefox media policies optimized for Night Light."
}

# --------------------------------------------------
# Main
# --------------------------------------------------
intel_graphics_main() {
    print_header "Intel Graphics Configuration (Wayland + VA-API)"

    check_intel_gpu || return 0

    install_intel_graphics_drivers
    configure_vaapi_environment
    configure_firefox_media_policies
    validate_vaapi

    log_warning "Reboot required for environment variables to take effect."
    print_footer "Intel Graphics Configuration Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    intel_graphics_main
fi
