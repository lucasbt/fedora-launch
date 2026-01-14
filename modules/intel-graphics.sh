#!/usr/bin/env bash
# Description: Intel graphics drivers and optimizations
# Category: hardware
# Priority: 2

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

intel_graphics_main() {
    print_header "Intel Graphics Configuration"

    if ! is_intel_gpu; then
        log_warning "No Intel GPU detected. Skipping."
        return 0
    fi

    log_section "Installing Mesa Drivers"
    dnf_install mesa-dri-drivers mesa-vulkan-drivers mesa-va-drivers
    log_success "Mesa drivers installed."

    log_section "Configuring VA-API"
    if [ -n "$FEDORALAUNCH_LIBVA_DRIVER_NAME" ]; then
        # /etc/environment
        if ! grep -q "LIBVA_DRIVER_NAME" /etc/environment 2>/dev/null; then
            echo "LIBVA_DRIVER_NAME=${FEDORALAUNCH_LIBVA_DRIVER_NAME}" | sudo tee -a /etc/environment > /dev/null
        else
            log_info "LIBVA_DRIVER_NAME already configured in /etc/environment"
        fi
        # /etc/profile.d/intel-vaapi.sh
        sudo mkdir -p /etc/profile.d
        echo "export LIBVA_DRIVER_NAME=${FEDORALAUNCH_LIBVA_DRIVER_NAME}" | sudo tee /etc/profile.d/intel-vaapi.sh
        sudo chmod 644 /etc/profile.d/intel-vaapi.sh
        log_success "VA-API driver configured to ${FEDORALAUNCH_LIBVA_DRIVER_NAME}."
    else
        log_info "No VA-API driver name specified. Skipping."
    fi

    print_footer "Intel Graphics Configuration Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    intel_graphics_main
fi
