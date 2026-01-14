#!/usr/bin/env bash
# Description: Visual comfort settings
# Category: health
# Priority: 4

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

anti_fatigue_main() {
    print_header "Anti-Fatigue Settings"

    log_section "Enabling Night Light"
    gs_set org.gnome.settings-daemon.plugins.color night-light-enabled "${FEDORALAUNCH_ENABLE_NIGHT_LIGHT}"
    gs_set org.gnome.settings-daemon.plugins.color night-light-temperature "${FEDORALAUNCH_GNOME_NIGHT_LIGHT_TEMP}"
    log_success "Night Light settings applied."

    log_section "Optimizing Text"
    gs_set org.gnome.desktop.interface text-scaling-factor "${FEDORALAUNCH_GNOME_TEXT_SCALING}"
    gs_set org.gnome.desktop.interface font-hinting "${FEDORALAUNCH_FONT_HINTING}"
    gs_set org.gnome.desktop.interface font-antialiasing "${FEDORALAUNCH_FONT_ANTIALIASING}"
    log_success "Text optimization settings applied."

    log_section "Forcing Dark Theme"
    gs_set org.gnome.desktop.interface color-scheme "${FEDORALAUNCH_GNOME_COLOR_SCHEME}"
    log_success "Dark theme applied."

    log_section "Disabling Animations"
    gs_set org.gnome.desktop.interface enable-animations "${FEDORALAUNCH_GNOME_ENABLE_ANIMATIONS}"
    log_success "Animations disabled."

    print_footer "Anti-Fatigue Settings Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    anti_fatigue_main
fi
