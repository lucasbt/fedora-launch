#!/usr/bin/env bash
# Description: GNOME settings and tweaks
# Category: desktop
# Priority: 3

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

# Apply filesystem tweaks
apply_filesystem_tweaks() {
    log_section "Applying SSD TRIM..."    
    # Enable TRIM for SSDs
    if sudo fstrim -v / &>/dev/null; then
        enable_service "fstrim.timer" "TRIM Timer"
        log_success "SSD TRIM enabled"
    fi
}

# Configure development environment
configure_folders_development_environment() {
    log_section "Configuring development and folders environment..."

    # Create common development directories
    ensure_dir "$HOME/Develop"
    ensure_dir "$HOME/Develop/personal"
    ensure_dir "$HOME/Develop/work"
    ensure_dir "$HOME/Develop/tools"
    ensure_dir "$HOME/Documents/projects"
    ensure_dir "$HOME/Documents/resources"
    ensure_dir "$HOME/Documents/resources/brain"
    ensure_dir "$HOME/Documents/resources/pictures"
    ensure_dir "$HOME/Documents/resources/pictures/wallpapers"
    ensure_dir "$HOME/Documents/resources/music"
    ensure_dir "$HOME/Documents/resources/videos"
    ensure_dir "$HOME/Documents/archives"
    ensure_dir "$HOME/Documents/areas"
    ensure_dir "$HOME/.local/bin"

    cp -r "$HOME/Pictures/"* "$HOME/Documents/resources/pictures/" 2>/dev/null || true
    rm -rf "$HOME/Pictures" && ln -s "$HOME/Documents/resources/pictures" "$HOME/Pictures"

    # add 'new empty file' in the context menu
	touch ~/Templates/Empty\ File

    log_success "Development and folders environment configured"
}

# Setup directory bookmarks
setup_directory_bookmarks() {
    log_section "Configuring directory bookmarks..."
    
    local bookmarks_file="$HOME/.bookmarks"

    if [ ! -f "$bookmarks_file" ]; then
        cat > "$bookmarks_file" << EOF
# Directory bookmarks
h=$HOME
p=$HOME/Documents/projects
dev=$HOME/Develop
dw=$HOME/Downloads
d=$HOME/Documents
c=$HOME/.config
l=$HOME/.local
r=$HOME/Documents/resources
b=$HOME/Documents/resources/brain
a=$HOME/Documents/archives
EOF

        # Add bookmark functions to shell functions
        cat >> "$HOME/.bash_functions" << 'EOF'

# Bookmark functions
bm() {
    local bookmark=$(grep "^$1=" ~/.bookmarks 2>/dev/null | cut -d'=' -f2)
    if [ -n "$bookmark" ]; then
        cd "$bookmark"
    else
        echo "Bookmark '$1' not found"
        echo "Available bookmarks:"
        cat ~/.bookmarks | grep -v '^#' | cut -d'=' -f1
    fi
}

bookmark() {
    if [ -z "$1" ]; then
        echo "Usage: bookmark <name>"
        return 1
    fi
    echo "$1=$(pwd)" >> ~/.bookmarks
    echo "Bookmarked $(pwd) as '$1'"
}

bookmarks() {
    echo "Available bookmarks:"
    cat ~/.bookmarks | grep -v '^#' | while IFS='=' read -r name path; do
        printf "  %-15s %s\n" "$name" "$path"
    done
}
EOF

        log_success "Directory bookmarks configured"
    else
        log_info "Directory bookmarks already configured"
    fi
}

gnome_tweaks_main() {
    print_header "GNOME Tweaks" 

    log_section "Applying GNOME Settings" #######################################
    
    gs_set org.gnome.desktop.interface clock-format '24h'
    gs_set org.gnome.desktop.interface enable-animations "${FEDORALAUNCH_GNOME_ENABLE_ANIMATIONS}"
    gs_set org.gnome.desktop.interface monospace-font-name "'${FEDORALAUNCH_FONT_MONOSPACE}'"
    gs_set org.gnome.desktop.interface color-scheme 'prefer-dark'

    gs_set org.gnome.desktop.wm.keybindings close "['<Super>w']"
    gs_set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
    # Make it easy to maximize like you can fill left/right
    gs_set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    # Full-screen with title/navigation bar
    gs_set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"
    # Use super for workspaces
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
    gs_set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"
    # Reserve slots for custom keybindings
    gs_set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/']"
    
    # Set flameshot (with the sh fix for starting under Wayland) on alternate print screen key
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Flameshot'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'sh -c -- "flameshot gui"'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Control>Print'

    gs_set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'taskmanager'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-system-monitor'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Control><Shift>Escape'

    gs_set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'terminal'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'ptyxis'
    gs_set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Control><Alt>t'

    # Center new windows in the middle of the screen
    gs_set org.gnome.mutter center-new-windows true

    gs_set org.gnome.desktop.wm.preferences num-workspaces 4
    
    gs_set org.gnome.desktop.peripherals.keyboard numlock-state true
    gs_set org.gnome.desktop.sound allow-volume-above-100-percent true
    gs_set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

    gs_set org.gnome.nautilus.preferences show-create-link 'true'
    gs_set org.gnome.nautilus.preferences show-delete-permanently 'true'
    gs_set org.gtk.Settings.FileChooser sort-directories-first 'true'
    gs_set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

    gs_set org.gnome.TextEditor show-line-numbers 'true'
    gs_set org.gnome.TextEditor spellcheck 'false'
    gs_set org.gnome.TextEditor show-map 'true'
    gs_set org.gnome.TextEditor highlight-current-line 'true'

    gs_set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>s']"
    gs_set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

    gs_set org.gtk.Settings.FileChooser sort-directories-first 'true'
    gs_set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
    gs_set org.gnome.desktop.peripherals.touchpad tap-to-click 'true'
    gs_set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled 'true'

    gs_set org.gtk.gtk4.Settings.FileChooser show-hidden 'true'
    gs_set org.gtk.gtk4.Settings.FileChooser show-size-column 'true'
    gs_set org.gtk.gtk4.Settings.FileChooser show-type-column 'true'
    gs_set org.gtk.gtk4.Settings.FileChooser sort-column 'modified'
    gs_set org.gtk.gtk4.Settings.FileChooser sort-order 'ascending'
    gs_set org.gtk.gtk4.Settings.FileChooser view-type 'list'
    gs_set org.gnome.desktop.background show-desktop-icons 'false'
    gs_set org.gnome.desktop.calendar show-weekdate 'true'
    gs_set org.gnome.nautilus.preferences show-delete-permanently 'true'
    gs_set org.gnome.nautilus.preferences show-create-link 'true'

    log_success "GNOME settings applied."

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
            log_info "File not found: $file"
        fi
    done
    log_success "Set display false to gnome apps grid for some apps applied."

    log_section "Enabling nano syntax highlighting..." ##############################################

    local nanorc_file="$HOME/.nanorc"
    local include_line="include /usr/share/nano/*"

    # Check if the include line is already present
    if grep -Fxq "$include_line" "$nanorc_file" 2>/dev/null; then
        log_info "Syntax highlighting already enabled in $nanorc_file"
        return 0
    fi

    # Add the include line with a comment
    {
        echo ""
        echo "# Enable syntax highlighting for all filetypes"
        echo "$include_line"
    } >> "$nanorc_file"
    log_success "Nano syntax highlighting enabled in $nanorc_file"

    
    # Install Starship prompt
    log_section "Installing Starship prompt"    #####################################
    local bashrc="$HOME/.bashrc"
    if ! command -v starship &>/dev/null; then
        log_info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
        log_success "Starship installed"
    else
        log_info "Starship already installed"
    fi

    STARSHIP_CMD='eval "$(starship init bash)"'
    # Verifica se a linha já existe
    if ! grep -Fxq "$STARSHIP_CMD" "$bashrc"; then
        echo "" >> "$bashrc"               # adiciona uma linha em branco
        echo "$STARSHIP_CMD" >> "$bashrc"  # adiciona o comando
        log_success "Starship init added in ~/.bashrc"
    else
        log_info "Starship init already exists in ~/.bashrc"
    fi

    log_section "Installing Gnome Extensions" #############################################
    dnf_install gnome-shell-extension-appindicator gnome-shell-extension-auto-move-windows \
        gnome-shell-extension-background-logo gnome-shell-extension-caffeine gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-just-perfection gnome-shell-extension-user-theme
    log_success "Gnome Extensions installed."

    log_section "Some adjusts to GNOME and Apps"
    sudo rm -rf /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js
    curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
    log_section "Adjusts to GNOME and Apps applied."

    # Configure fzf
    log_section "Configuring fzf" ##########################################################
    # Add fzf key bindings and completion
    local fzf_config="# fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND=\"\$FZF_DEFAULT_COMMAND\"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# load fzf only when pressing CTRL+T or first fzf command
zle -N fzf-file-widget fzf_lazy

# Set up fzf key bindings and fuzzy completion"

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ] && ! grep -q "fzf configuration" "$HOME/.bashrc"; then
        echo "$fzf_config" >> "$HOME/.bashrc"
        echo "source <(fzf --bash)" >> "$HOME/.bashrc"
    fi
    log_success "fzf configured"

    apply_filesystem_tweaks()
    configure_folders_development_environment()
    setup_directory_bookmarks()

    print_footer "GNOME Tweaks Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    gnome_tweaks_main
fi
