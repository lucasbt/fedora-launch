#!/usr/bin/env bash
# Description: Flatpak applications
# Category: apps
# Priority: 7

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

flatpak_apps_main() {
    print_header "Flatpak Applications Installation"

    log_section "Installing Flatpak Applications"
    flatpak_install md.obsidian.Obsidian
    flatpak_install com.spotify.Client
    flatpak_install com.usebottles.bottles
    flatpak_install org.localsend.localsend_app
    flatpak_install it.mijorus.gearlever
    flatpak_install be.alexandervanhee.gradia
    log_success "Flatpak applications installed."

    print_footer "Flatpak Applications Installation Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    flatpak_apps_main
fi
