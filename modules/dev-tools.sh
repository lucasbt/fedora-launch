#!/usr/bin/env bash
# Description: Development tools (profiles + cache + podman)
# Category: development
# Priority: 5

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

PROFILE="${FEDORALAUNCH_DEV_PROFILE:-dev}"

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
cached_download() {
    local url="$1"
    local output="$2"

    if [ ! -f "$output" ]; then
        log_info "Downloading $(basename "$output")"
        curl -L "$url" -o "$output"
    else
        log_info "Using cached $(basename "$output")"
    fi
}

# ------------------------------------------------------------
# Base toolchains
# ------------------------------------------------------------
install_build_essentials() {
    log_section "Installing Build Essentials"
    dnf_install gcc make cmake automake gcc-c++ \
        kernel-devel kernel-headers \
        autoconf libtool pkg-config \
        clang openssl-devel libffi-devel \
        zlib-devel bzip2-devel xz-devel \
        readline-devel sqlite-devel
}

install_git() {
    log_section "Installing Git"
    dnf_install git git-lfs git-delta meld
    git config --global credential.helper 'cache --timeout=14400000'
}

# ------------------------------------------------------------
# JVM stack
# ------------------------------------------------------------
install_java_stack() {
    log_section "Installing SDKMAN + Java Stack"

    set +u
    [ -d "$HOME/.sdkman" ] || curl -s https://get.sdkman.io | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    sdk install java "${FEDORALAUNCH_SDKMAN_JAVA_VERSION}"
    sdk install maven
    sdk install gradle
    set -u
}

# ------------------------------------------------------------
# Go
# ------------------------------------------------------------
install_go() {
    log_section "Installing Go"

    local ver="${FEDORALAUNCH_GOLANG_VERSION}"
    [[ "$ver" == go* ]] || ver="go${ver}"

    local tar="$CACHE_DIR/${ver}.linux-amd64.tar.gz"

    cached_download \
        "https://go.dev/dl/${ver}.linux-amd64.tar.gz" \
        "$tar"

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$tar"

    grep -q "/usr/local/go/bin" "$HOME/.bashrc" || \
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
}

# ------------------------------------------------------------
# IDEs
# ------------------------------------------------------------
install_ides() {
    log_section "Installing IDEs"

    # IntelliJ
    if [ ! -d /opt/intellij ]; then
        local json url tar
        json=$(curl -s "https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release")
        url=$(echo "$json" | jq -r '.IIC[0].downloads.linux.link')
        tar="$CACHE_DIR/intellij.tar.gz"

        cached_download "$url" "$tar"

        sudo mkdir -p /opt/intellij
        sudo tar -xzf "$tar" -C /opt/intellij --strip-components=1

        sudo tee /usr/share/applications/intellij.desktop >/dev/null <<EOF
[Desktop Entry]
Name=IntelliJ IDEA Community
Exec=/opt/intellij/bin/idea.sh
Icon=/opt/intellij/bin/idea.svg
Type=Application
Categories=Development;IDE;
StartupWMClass=jetbrains-idea
EOF
    fi

    # Zed
    command -v zed &>/dev/null || curl -f https://zed.dev/install.sh | sh
}

# ------------------------------------------------------------
# Containers — Podman
# ------------------------------------------------------------
install_podman() {
    log_section "Installing Podman (rootless)"

    dnf_install podman podman-compose crun \
        slirp4netns fuse-overlayfs

    systemctl --user enable --now podman.socket

    mkdir -p ~/.config/containers

    tee ~/.config/containers/containers.conf >/dev/null <<EOF
[engine]
runtime="crun"
cgroup_manager="systemd"
events_logger="journald"
EOF

    tee ~/.config/containers/storage.conf >/dev/null <<EOF
[storage]
driver="overlay"
graphroot="\$HOME/.local/share/containers/storage"
runroot="/run/user/$(id -u)"

[storage.options.overlay]
mount_program="/usr/bin/fuse-overlayfs"
EOF
}

# ------------------------------------------------------------
# Kubernetes / Cloud
# ------------------------------------------------------------
install_cloud_tools() {
    log_section "Installing Kubernetes & Cloud Tools"

    # kubectl
    if ! command -v kubectl &>/dev/null; then
        local ver bin
        ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
        bin="$CACHE_DIR/kubectl"

        cached_download \
            "https://storage.googleapis.com/kubernetes-release/release/${ver}/bin/linux/amd64/kubectl" \
            "$bin"

        sudo install "$bin" /usr/local/bin/kubectl
    fi

    # Minikube
    if ! command -v minikube &>/dev/null; then
        local url bin
        url=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest \
            | grep minikube-linux-amd64 | cut -d'"' -f4)
        bin="$CACHE_DIR/minikube"

        cached_download "$url" "$bin"
        sudo install "$bin" /usr/local/bin/minikube
    fi

    # Default driver = podman
    minikube config set driver podman
}

install_postman() {
    log_section "Installing Postman"

    local install_dir="/opt/postman"
    local cache_dir="${CACHE_DIR:-$HOME/.cache/fedoralaunch}"
    local archive="${cache_dir}/postman-linux-x64.tar.gz"

    mkdir -p "$cache_dir"

    if [ ! -d "$install_dir" ]; then
        log_info "Downloading Postman..."
        curl -L "https://dl.pstmn.io/download/latest/linux64" -o "$archive"

        log_info "Installing Postman to ${install_dir}..."
        sudo rm -rf "$install_dir"
        sudo mkdir -p "$install_dir"
        sudo tar -xzf "$archive" -C /opt
        sudo mv /opt/Postman "$install_dir"
        sudo chown -R $USER:$USER "$install_dir"

        log_success "Postman installed."
    else
        log_info "Postman already installed."
    fi

    # Desktop entry (user-level, GNOME friendly)
    local desktop_file="$HOME/.local/share/applications/postman.desktop"

    if [ ! -f "$desktop_file" ]; then
        log_info "Creating Postman desktop entry..."

        mkdir -p "$HOME/.local/share/applications"

        cat > "$desktop_file" <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Comment=API Development Environment
Exec=${install_dir}/app/Postman %U
Icon=${install_dir}/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
StartupWMClass=Postman
EOF

        log_success "Postman desktop entry created."
    else
        log_info "Postman desktop entry already exists."
    fi
}

install_insomnia() {
    log_section "Installing Insomnia"

    local cache_dir="${CACHE_DIR:-$HOME/.cache/fedoralaunch}"

    log_info "Querying latest Insomnia release from GitHub..."

    # Pega a tag da última versão
    local tag
    tag=$(curl -s https://api.github.com/repos/Kong/insomnia/releases/latest \
        | grep -oP '"tag_name":\s*"\K([^"]+)' )

    if [ -z "$tag" ]; then
        log_error "We were unable to identify the latest version of Insomnia on GitHub."
        return 1
    fi

    log_info "Latest Insomnia release: $tag"

    # Monta URL do RPM
    local rpm_asset
    rpm_asset=$(curl -s "https://api.github.com/repos/Kong/insomnia/releases/tags/${tag}" \
        | grep -oP 'browser_download_url":\s*"\K([^"]*Insomnia\.Core[^"]*\.rpm)' )

    if [ -z "$rpm_asset" ]; then
        log_error "I couldn't find an asset .rpm file for the release $tag"
        return 1
    fi

    log_info "Insomnia RPM asset found: $rpm_asset"

    # Define arquivo local
    local rpm_file="${cache_dir}/$(basename "${rpm_asset}")"

    # Baixa com cache
    if [ ! -f "$rpm_file" ]; then
        log_info "Downloading Insomnia RPM to cache..."
        curl -L "$rpm_asset" -o "$rpm_file"
    else
        log_info "Using Insomnia RPM already cached"
    fi

    # Instala com dnf (resolve deps)
    log_info "Installing Insomnia RPM..."
    sudo dnf install -y "$rpm_file"

    log_success "Insomnia installed via RPM (from GitHub release)"
}

# ------------------------------------------------------------
# Main (profiles)
# ------------------------------------------------------------
dev_tools_main() {
    print_header "Dev Tools (profile: $PROFILE)"

    install_build_essentials
    install_git
    install_postman
    install_insomnia

    case "$PROFILE" in
        dev)
            install_java_stack
            install_go
            install_ides
            install_podman
            install_cloud_tools
            ;;
        cloud)
            install_podman
            install_cloud_tools
            ;;
        java-only)
            install_java_stack
            install_ides
            ;;
        *)
            log_error "Unknown profile: $PROFILE"
            exit 1
            ;;
    esac

    print_footer "Dev Tools Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    dev_tools_main
fi
