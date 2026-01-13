# fedoralaunch Project Structure

## 📁 Repository Structure Example

```
fedora-launch/
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── STRUCTURE.md                 # This file
├── bootstrap.sh                 # Initial installation script
├── fedoralaunch                 # Main executable script
│
├── lib/
│   └── utils.sh                 # Shared functions library
│
├── config/
│   └── .env                      # Configuration default
│
└── modules/
    ├── system-base.sh           # [P:1] System base
    ├── intel-graphics.sh        # [P:2] Intel drivers
    ├── gnome-tweaks.sh          # [P:3] GNOME settings
    ├── anti-fatigue.sh          # [P:4] Visual comfort
    ├── dev-tools.sh             # [P:5] Development tools
    ├── rpm-apps.sh              # [P:6] RPM applications
    └── flatpak-apps.sh          # [P:7] Flatpak applications
```

## 📁 Structure After Installation (in ~/.local/share/fedoralaunch/)

```
~/.local/share/fedoralaunch/
├── fedoralaunch                 # Copy of main script
...
│
├── lib/
│   └── utils.sh                 # Functions library
│
├── config/
│   └── env                      # User configuration
│   └── env.bak                  # Backup (after self-update)
│
└── modules/
    ├── system-base.sh
    ├── intel-graphics.sh
    ├── gnome-tweaks.sh
    ├── anti-fatigue.sh
    ├── dev-tools.sh
    ├── rpm-apps.sh
    └── flatpak-apps.sh

~/.local/bin/
└── fedoralaunch                 # Symbolic link or copy

~/.local/cache/
└── fedoralaunch/              
    ├── *.log                    # log archives
    └── other-files
```

## 📄 File Descriptions

### 🔧 Main Files

#### `fedoralaunch`
- **Type**: Bash executable script
- **Function**: Main system script
- **Responsibilities**:
  - Command management
  - Module loading
  - Self-update (force overwrite from git) 
  - Configuration management
- **Link exec**: `~/.local/bin/fedoralaunch`

#### `bootstrap.sh`
- **Type**: Bash script
- **Function**: Initial installer
- **Usage**: `curl ... | bash`
- **Responsibilities**:
  - Clone repository
  - Configure PATH
  - Create initial structure
  - Show next steps

### 📚 Library

#### `lib/utils.sh`
- **Type**: Bash library (source)
- **Function**: Shared functions
- **Main functions**:
  - `log_info()`, `log_success()`, `log_warning()`, `log_error()`, `log_debug()`
  - `run_cmd()`, `run_cmd_visible()`
  - `gs_set()`, `gs_get()` - gsettings management
  - `dnf_install()`, `flatpak_install()`
  - `is_intel_gpu()`, `detect_gpu_vendor()`
  - `backup_file()`, `ensure_dir()`
  - And 50+ utility functions

### ⚙️ Configuration

#### `config/.env`
- **Type**: prop file
- **Function**: Configuration variables
- **Variables and default values**:
  - FEDORALAUNCH_VERBOSE=false              # Verbose mode (true/false)
  - FEDORALAUNCH_LIBVA_DRIVER_NAME=i965     # LIBVA driver for Intel (i965 for Haswell and earlier)
  - FEDORALAUNCH_GNOME_COLOR_SCHEME=prefer-dark      # Color scheme (prefer-dark/prefer-light)
  - FEDORALAUNCH_GNOME_ENABLE_ANIMATIONS=false      # Enable animations (true/false)
  - FEDORALAUNCH_GNOME_TEXT_SCALING=1.05        # Text scaling factor (1.0 = 100%)
  - FEDORALAUNCH_ENABLE_NIGHT_LIGHT=true        # Enable Night light (true/false)
  - FEDORALAUNCH_GNOME_NIGHT_LIGHT_TEMP=3700        # Night Light temperature (1000-4000, recommended: 3700)
  - FEDORALAUNCH_FONT_MONOSPACE="JetBrains Mono 11"  # Default monospace font
  - FEDORALAUNCH_FONT_HINTING=slight        # Font hinting (none/slight/medium/full)
  - FEDORALAUNCH_FONT_ANTIALIASING=rgba     # Antialiasing (none/grayscale/rgba)
  - FEDORALAUNCH_SDKMAN_JAVA_VERSION=25.0.1-tem # SDKMAN Java version
  - FEDORALAUNCH_SDKMAN_MAVEN_VERSION=          # SDKMAN Maven version (empty for latest)
  - FEDORALAUNCH_SDKMAN_GRADLE_VERSION=         # SDKMAN Gradle version (empty for latest)
  - FEDORALAUNCH_NODEJS_VERSION=               # NodeJS version (using NVM with major number or latest lts if empty)
  - FEDORALAUNCH_PYENV_PYTHON_VERSION=3.12.0    # Python version (via pyenv)
  - FEDORALAUNCH_GOLANG_VERSION=                # Go version (empty to fetch latest from official site)
  - FEDORALAUNCH_RUST_VERSION=                  # Rust version rustup (empty to fetch latest from official site)
  - FEDORALAUNCH_ENABLE_RPMFUSION_FREE_NONFREE_REPOS=true        # Enable RPMFUSION FREE and non-free repositories
  - FEDORALAUNCH_INSTALL_PROPRIETARY_FIRMWARE=true            # Install proprietary firmware
  - FEDORALAUNCH_SWAPPINESS=10               # Swappiness (0-100, recommended: 10 for desktop)
  - FEDORALAUNCH_VFS_CACHE_PRESSURE=50                   # VFS cache pressure (default: 100, lower = keep cache longer)
  - FEDORALAUNCH_DIRTY_RATIO=10                           # Dirty page ratios (percentage of RAM)
  - FEDORALAUNCH_DIRTY_BACKGROUND_RATIO=5                 # Dirty page ratios (percentage of RAM)
  - FEDORALAUNCH_IO_SCHEDULER=mq-deadline                       # I/O Scheduler (mq-deadline, kyber, bfq, none)
  - FEDORALAUNCH_JOURNAL_MAX_SIZE=100M                        # Journal max size
- **Editable**: `fedoralaunch config`

### 🧩 Modules

All modules follow the pattern:

```bash
#!/usr/bin/env bash
# Description: Short description
# Category: category
# Priority: number

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

# Module-specific functions

module_name_main() {
    print_header "Module Name"
    
    # Module logic
    
    print_success "Completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    module_name_main
fi
```

#### `modules/system-base.sh`
- **Priority**: 1
- **Category**: system
- **Function**: Base configuration
- **Includes**: DNF, RPM Fusion, firmware, updates

#### `modules/intel-graphics.sh`
- **Priority**: 2
- **Category**: hardware
- **Function**: Intel drivers
- **Includes**: Mesa, VA-API

#### `modules/gnome-tweaks.sh`
- **Priority**: 3
- **Category**: desktop
- **Function**: GNOME settings
- **Includes**: Animations, Monospace Font

#### `modules/anti-fatigue.sh`
- **Priority**: 4
- **Category**: health
- **Function**: Visual Comfort
- **Includes**: Night Light, font configs, display configs

#### `modules/dev-tools.sh`
- **Priority**: 5
- **Category**: development
- **Function**: Development tools
- **Includes**: SDK Man, Docker, NVM, pyenv, Go, Rust, CLI tools, Vscode, Intellij, Spring Tool for Eclipse

#### `modules/rpm-apps.sh`
- **Priority**: 6
- **Category**: apps
- **Function**: RPM applications
- **Includes**: 
  - RPMs: Chrome, Brave, VS Code, Telegram, VLC, LibreOffice

#### `modules/flatpak-apps.sh`
- **Priority**: 7
- **Category**: apps
- **Function**: Flatpak applications
- **Includes**: 
  - Flatpaks: Obsidian, Spotify, Postman, Insomnia, Bottles, LocalSend, Gear Lever, ZapZap

## 🔄 Data Flow Examples

### Initialization

```
bootstrap.sh
    ├─> Clone repository
    ├─> Create ~/.local/share/fedoralaunch/
    ├─> Copy files
    ├─> Add to PATH (~/.local/bin/fedoralaunch/fedoralaunch)
    └─> Show next steps

fedoralaunch
    ├─> Load lib/utils.sh
    ├─> Load config/.env
    ├─> Create structure if needed
    └─> Execute command
```

### Module Execution

```
fedoralaunch install module-name
    ├─> Load lib/utils.sh
    ├─> Load config/env
    ├─> Source modules/module-name.sh
    │   └─> Module loads lib/utils.sh
    ├─> Execute module_name_main()
    └─> Log to fedoralaunch.log
```

### Self-Update

```
fedoralaunch self-update
    ├─> Clone temp from GitHub
    ├─> Backup config/.env
    ├─> Remove old and Copy new files
    ├─> Restore config/env
    └─> Remove temp
```

## 🎯 Dependencies Between Files

```
fedoralaunch (main)
    └── requires: lib/utils.sh

modules/*.sh
    └── requires: lib/utils.sh
    └── reads: config/.env

bootstrap.sh
    └── standalone (no dependencies)
```

## 📝 Conventions

### Files
- **Scripts**: kebab-case (`system-base.sh`)
- **Functions**: snake_case (`install_module`)
- **Global variables**: UPPER_SNAKE_CASE (`INSTALL_DIR`)
- **Local variables**: lower_snake_case (`module_name`)

### Main Functions
Each module has a main function:
- **Pattern**: `<module-name-with-underscores>_main()`
- **Example**: `system_base_main()`, `intel_graphics_main()`

### Logging
- `log_info()` - Information
- `log_success()` - Success
- `log_warning()` - Warning
- `log_error()` - Error
- `log_debug()` - Debug (only if FEDORALAUNCH_DEBUG=true)

### Sections
Use `log_section "Title"` to divide outputs

### Banners
Use `print_header "Text"` at module start

## 🔐 Permissions

- Executable scripts: `755`
- Libraries: `644`
- Configuration: `644`
- Log: `644`

## 🚀 To Publish on GitHub

1. Repository `lucasbt/fedora-launch`
2. Organize files according to structure above
3. Add LICENSE (MIT)
5. For execute: `curl -fsSL https://raw.githubusercontent.com/lucasbt/fedora-launch/main/bootstrap.sh | bash`