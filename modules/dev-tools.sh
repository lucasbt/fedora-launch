#!/usr/bin/env bash
# Description: Development tools
# Category: development
# Priority: 5

set -euo pipefail

source "${SCRIPT_DIR}/lib/utils.sh"

dev_tools_main() {
    print_header "Development Tools Installation"

    log_section "Installing Build Essentials"
    dnf_install gcc make cmake automake gcc-c++ kernel-devel autoconf libtool pkg-config pkgconf kernel-headers bison clang
    log_success "Build essentials installed."

    log_section "Installing Git"
    dnf_install git git-lfs git-delta git-subtree hexedit meld
    git config --global credential.helper 'cache --timeout=14400000'
    log_success "Git installed."

    log_section "Installing SDKMAN"
    set +u
    if [ ! -d "$HOME/.sdkman" ]; then
        curl -s "https://get.sdkman.io" | bash        
        log_success "SDKMAN installed."
    else
        log_info "SDKMAN is already installed."
    fi

    source "$HOME/.sdkman/bin/sdkman-init.sh"

    log_section "Installing Java"
    sdk install java "${FEDORALAUNCH_SDKMAN_JAVA_VERSION}"
    log_success "Java installed."

    log_section "Installing Maven"
    if [ -n "$FEDORALAUNCH_SDKMAN_MAVEN_VERSION" ]; then
        sdk install maven "${FEDORALAUNCH_SDKMAN_MAVEN_VERSION}"
    else
        sdk install maven
    fi
    log_success "Maven installed."

    log_section "Installing Gradle"
    if [ -n "$FEDORALAUNCH_SDKMAN_GRADLE_VERSION" ]; then
        sdk install gradle "${FEDORALAUNCH_SDKMAN_GRADLE_VERSION}"
    else
        sdk install gradle
    fi
    set -u
    log_success "Gradle installed."
    
    log_section "Installing NVM and Node.js"
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install "${FEDORALAUNCH_NODEJS_VERSION:---lts}"
    log_success "NVM and Node.js installed."

    log_section "Installing pyenv and Python"
    if [ ! -d "$HOME/.pyenv" ]; then
        curl https://pyenv.run | bash
    fi
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    pyenv install -s "${FEDORALAUNCH_PYENV_PYTHON_VERSION}"
    pyenv global "${FEDORALAUNCH_PYENV_PYTHON_VERSION}"
    log_success "pyenv and Python installed."

    log_section "Installing Go"
    local go_ver="${FEDORALAUNCH_GOLANG_VERSION}"
    
    if [ -z "$go_ver" ]; then
        log_info "Fetching latest Go version..."
        go_ver=$(curl -sL "https://go.dev/dl/?mode=json" | grep -o '"version": "go[^"]*"' | head -1 | cut -d'"' -f4)
    else
        if [[ "${go_ver}" != go* ]]; then
            go_ver="go${go_ver}"
        fi
    fi

    local current_go=""
    if [ -x "/usr/local/go/bin/go" ]; then
        current_go=$(/usr/local/go/bin/go version | awk '{print $3}')
    fi

    if [ "$current_go" != "$go_ver" ]; then
        log_info "Installing ${go_ver}..."
        curl -L "https://go.dev/dl/${go_ver}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        
        if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc"; then
            echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
        fi
        log_success "Go ${go_ver} installed."
    else
        log_info "Go ${go_ver} is already installed."
    fi

    log_section "Installing Rust"
    if [ ! -d "$HOME/.cargo" ]; then
        log_info "Installing Rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    source "$HOME/.cargo/env"
    if [ -n "$FEDORALAUNCH_RUST_VERSION" ]; then
        log_info "Installing Rust ${FEDORALAUNCH_RUST_VERSION}..."
        rustup install "${FEDORALAUNCH_RUST_VERSION}"
        rustup default "${FEDORALAUNCH_RUST_VERSION}"
        log_success "Rust ${FEDORALAUNCH_RUST_VERSION} installed."
    else
        log_info "Installing Rust (stable)..."
        rustup install stable
        rustup default stable
        log_success "Rust (stable) installed."
    fi

    log_section "Installing IntelliJ IDEA"
    if [ ! -d "/opt/intellij" ]; then
        local intellij_url=$(curl -s "https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release" | jq -r '.IIC[0].downloads.linux.link')
        if [ -n "$intellij_url" ]; then
            log_info "Downloading IntelliJ IDEA from $intellij_url..."
            curl -L "$intellij_url" -o /tmp/intellij.tar.gz
            sudo rm -rf /opt/intellij
            sudo mkdir -p /opt/intellij
            sudo tar -xzf /tmp/intellij.tar.gz -C /opt/intellij --strip-components=1
            rm /tmp/intellij.tar.gz            
            echo "[Desktop Entry]
Name=IntelliJ IDEA Community
Comment=The Drive to Develop
Exec=/opt/intellij/bin/idea.sh
Icon=/opt/intellij/bin/idea.svg
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=jetbrains-idea" | sudo tee /usr/share/applications/intellij-idea.desktop > /dev/null
            log_success "IntelliJ IDEA installed."
        else
            log_error "Could not find IntelliJ IDEA download URL."
        fi
    else
        log_info "Intellij IDEA is already installed."
    fi

    log_section "Installing Spring Tool Suite (STS)"
    if [ ! -d "/opt/sts" ]; then
        local sts_url=$(curl -s https://spring.io/tools | grep -o 'https://[^"]*linux.gtk.x86_64.tar.gz' | head -1)
        if [ -n "$sts_url" ]; then
            log_info "Downloading STS from $sts_url..."
            curl -L "$sts_url" -o /tmp/sts.tar.gz
            sudo rm -rf /opt/sts
            sudo mkdir -p /opt/sts
            sudo tar -xzf /tmp/sts.tar.gz -C /opt/sts --strip-components=1
            rm /tmp/sts.tar.gz

            echo "[Desktop Entry]
Name=Spring Tool Suite 4
Comment=Spring Boot IDE
Exec=/opt/sts/SpringToolSuite4
Icon=/opt/sts/icon.xpm
Terminal=false
Type=Application
Categories=Development;IDE;Java;
StartupWMClass=SpringToolSuite4" | sudo tee /usr/share/applications/sts4.desktop > /dev/null
            log_success "Spring Tool Suite installed."
        else
            log_error "Could not find STS download URL."
        fi
    else
        log_info "STS is already installed."

    fi

    log_section "Installing Microsoft Visual Studio Code"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf_install code
    log_success "Microsoft Visual Studio Code installed."

    log_section "Installing Zed Editor"
    if ! command -v zed &> /dev/null; then
        log_info "Installing Zed Editor..."
        curl -f https://zed.dev/install.sh | sh
        log_success "Zed Editor installed."
    else
        log_info "Zed Editor is already installed."
    fi

    log_section "Installing Docker"
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    sudo tee /etc/yum.repos.d/docker-ce.repo <<EOF
[Docker-CE]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    dnf_install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    log_success "Docker installed and configured."

    log_section "Installing Modern CLI Tools"
    dnf_install btop neovim vim-enhanced wget perf htop iotop 
    log_success "Modern CLI tools installed."

    log_section "Installing Other Programming Languages"
    dnf_install lua perl ruby 
    log_success "Other Programming Languages installed."

    log_section "Installing Cloud Tools"
    # Instalar kubectl se não existir
    if ! command -v kubectl &> /dev/null; then
        log_info "Installing kubectl..."
        local kubectl_url=$(curl -s "https://storage.googleapis.com/kubernetes-release/release/stable.txt")
        curl -LO "https://storage.googleapis.com/kubernetes-release/release/${kubectl_url}/bin/linux/amd64/kubectl" -o /tmp/kubectl
        sudo install /tmp/kubectl /usr/local/bin/kubectl
        rm /tmp/kubectl
        log_success "kubectl installed."
    else
        log_info "kubectl is already installed."
    fi

    # Instalar Minikube se não existir
    if ! command -v minikube &> /dev/null; then
        log_info "Installing Minikube..."
        local minikube_url=$(curl -s "https://api.github.com/repos/kubernetes/minikube/releases/latest" \
            | grep -o '"browser_download_url": "[^"]*minikube-linux-amd64"' | cut -d'"' -f4)
        if [ -n "$minikube_url" ]; then
            curl -L "$minikube_url" -o /tmp/minikube
            sudo install /tmp/minikube /usr/local/bin/minikube
            rm /tmp/minikube
            log_success "Minikube installed."
        else
            log_error "Could not find Minikube download URL."
        fi
    else
        log_info "Minikube is already installed."
    fi

    # Instalar AWS CLI se não existir
    if ! command -v aws &> /dev/null; then
        log_info "Installing AWS CLI..."
        local aws_cli_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
        curl "$aws_cli_url" -o "/tmp/awscliv2.zip"
        unzip -o /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
        rm -rf /tmp/aws /tmp/awscliv2.zip
        log_success "AWS CLI installed."
    else
        log_info "AWS CLI is already installed."
    fi

    log_success "Cloud tools installed."

    print_footer "Development Tools Installation Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    dev_tools_main
fi
