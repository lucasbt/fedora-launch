#!/usr/bin/env bash
# Description: Visual comfort and eye-strain reduction settings for GNOME
# Focus: ocular sensitivity, anxiety-friendly UX, predictable visuals
# Category: health / ergonomics
# Priority: 4

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

#
# -----------------------------
# Night Light (schedule + color)
# -----------------------------
#
configure_night_light() {
    log_section "Configuring Night Light (fixed schedule, night use only)"

    gs_set org.gnome.settings-daemon.plugins.color night-light-enabled \
        "${FEDORALAUNCH_ENABLE_NIGHT_LIGHT}"

    # avoid geolocation-based changes
    gs_set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false

    gs_set org.gnome.settings-daemon.plugins.color night-light-schedule-from \
        "${FEDORALAUNCH_GNOME_NIGHT_LIGHT_FROM}"

    gs_set org.gnome.settings-daemon.plugins.color night-light-schedule-to \
        "${FEDORALAUNCH_GNOME_NIGHT_LIGHT_TO}"

    gs_set org.gnome.settings-daemon.plugins.color night-light-temperature \
        "${FEDORALAUNCH_GNOME_NIGHT_LIGHT_TEMP}"

    log_success "Night Light configured."
}

#
# -----------------------------
# Text, Fonts & Cursor
# -----------------------------
#
configure_readability() {
    log_section "Optimizing text, fonts and cursor for eye comfort"

    # text & fonts
    gs_set org.gnome.desktop.interface text-scaling-factor \
        "${FEDORALAUNCH_GNOME_TEXT_SCALING}"

    gs_set org.gnome.desktop.interface font-hinting \
        "${FEDORALAUNCH_FONT_HINTING}"

    gs_set org.gnome.desktop.interface font-antialiasing \
        "${FEDORALAUNCH_FONT_ANTIALIASING}"

    # cursor visibility
    gs_set org.gnome.desktop.interface cursor-size \
        "${FEDORALAUNCH_CURSOR_SIZE}"

    log_success "Readability and cursor settings applied."
}

#
# -----------------------------
# Visual Behavior (theme & UX)
# -----------------------------
#
configure_visual_behavior() {
    log_section "Configuring visual behavior (theme preference & animations)"

    # theme preference (not forced)
    gs_set org.gnome.desktop.interface color-scheme \
        "${FEDORALAUNCH_GNOME_COLOR_SCHEME}"

    # reduce cognitive load
    gs_set org.gnome.desktop.interface enable-animations \
        "${FEDORALAUNCH_GNOME_ENABLE_ANIMATIONS}"

    log_success "Visual behavior configured."
}

#
# -----------------------------
# Main
# -----------------------------
#
visual_comfort_main() {
    print_header "Visual Comfort & Eye Strain Reduction"

    configure_night_light
    configure_readability
    configure_visual_behavior

    print_footer "Visual Comfort Settings Applied"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    visual_comfort_main
fi
