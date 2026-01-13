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
    flatpak_install com.getpostman.Postman
    flatpak_install rest.insomnia.Insomnia
    flatpak_install com.usebottles.bottles
    flatpak_install org.localsend.localsend_app
    flatpak_install it.mijorus.gearlever
    flatpak_install com.rtosta.zapzap
    flatpak_install io.github.flattool.Warehouse
    flatpak_install io.bassi.Amberol
    flatpak_install org.gnome.gitlab.somas.Apostrophe
    flatpak_install be.alexandervanhee.gradia
    log_success "Flatpak applications installed."

    log_section "Configuring Flatpak Themes"
    sudo flatpak override --filesystem=~/.themes
    sudo flatpak override --filesystem=~/.icons
    sudo flatpak override --env=GTK_THEME=Adwaita:dark
    log_success "Flatpak themes configured."

    print_success "Flatpak Applications Installation Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    flatpak_apps_main
fi
