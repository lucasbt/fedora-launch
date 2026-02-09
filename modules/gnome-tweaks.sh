#!/usr/bin/env bash
# Description: GNOME behavior, workflow and background services
# Category: desktop
# Priority: 3

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

# --------------------------------------------------
# Filesystem & Background Services
# --------------------------------------------------
apply_background_services_tweaks() {
    log_section "Background services and indexing"

    if sudo fstrim -v / &>/dev/null; then
        enable_service "fstrim.timer" "SSD TRIM Timer"
    fi

    # Disable Tracker / LocalSearch (predictability + performance)
    systemctl --user stop localsearch-3.service || true
    systemctl --user mask localsearch-3.service || true

    sudo rm -f /usr/share/localsearch3/extract-rules/* || true

    gs_set org.gnome.desktop.search-providers disable-external true
    gs_set org.gnome.desktop.search-providers enabled "['org.gnome.Shell.Applications']"
    gs_set org.gnome.desktop.search-providers disabled "[]"
    gs_set org.gnome.desktop.search-providers sort-order "['org.gnome.Shell.Applications']"

    log_success "Background services adjusted"
}

# --------------------------------------------------
# Core GNOME Behavior (non-visual)
# --------------------------------------------------
configure_gnome_behavior() {
    log_section "GNOME core behavior"

    gs_set org.gnome.desktop.interface clock-format '24h'
    gs_set org.gnome.desktop.calendar show-weekdate true
    gs_set org.gnome.desktop.peripherals.keyboard numlock-state true

    # Sound: reduce cognitive noise (not ocular)
    gs_set org.gnome.desktop.sound event-sounds false
    gs_set org.gnome.desktop.sound allow-volume-above-100-percent true

    log_success "GNOME behavior configured"
}

# --------------------------------------------------
# Window Management & Workspaces
# --------------------------------------------------
configure_window_management() {
    log_section "Window management"

    gs_set org.gnome.mutter center-new-windows false
    gs_set org.gnome.mutter workspaces-only-on-primary true
    gs_set org.gnome.mutter dynamic-workspaces false

    gs_set org.gnome.desktop.wm.preferences num-workspaces 4
    gs_set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

    log_success "Window management configured"
}

# --------------------------------------------------
# Keybindings (workflow only)
# --------------------------------------------------
configure_keybindings() {
    log_section "Keybindings"

    gs_set org.gnome.desktop.wm.keybindings close "['<Super>w']"
    gs_set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
    gs_set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    gs_set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"

    for i in {1..6}; do
        gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    done

    gs_set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>s']"
    gs_set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

    log_success "Keybindings configured"
}

# --------------------------------------------------
# Nautilus & File Chooser (neutral visuals)
# --------------------------------------------------
configure_file_manager() {
    log_section "File manager behavior"

    gs_set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
    gs_set org.gnome.nautilus.preferences show-create-link true
    gs_set org.gnome.nautilus.preferences show-delete-permanently true

    gs_set org.gtk.Settings.FileChooser sort-directories-first true
    gs_set org.gtk.Settings.FileChooser show-hidden true

    log_success "File manager configured"
}

# --------------------------------------------------
# Firefox Red Hat Defaults (explicitly kept)
# --------------------------------------------------
remove_firefox_redhat_defaults() {
    log_section "Removing Red Hat Firefox defaults"

    sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js || true

    log_success "Firefox Red Hat defaults removed"
}

# --------------------------------------------------
# Main
# --------------------------------------------------
gnome_tweaks_main() {
    print_header "GNOME Behavior & Workflow Configuration"

    apply_background_services_tweaks
    configure_gnome_behavior
    configure_window_management
    configure_keybindings
    configure_file_manager
    remove_firefox_redhat_defaults

    print_footer "GNOME Configuration Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    gnome_tweaks_main
fi
