# Fedora Launch 🚀

**Post-install setup for Fedora 43+ made easy!**<br/>
*...by the community, for the community*

Modular and intelligent post-install for Fedora Workstation, optimized for older Intel hardware (Haswell+), visual comfort and productivity.

## 🎯 Features

- **Modular**: Install only what you need
- **Configurable**: All variables in a central file
- **Hardware-aware**: Optimized for Intel Haswell+
- **Anti-fatigue**: Night Light 3700K, enlarged text, dark theme
- **RPM-first**: Preference for RPMs with official repositories
- **Self-update**: Automatic updates from GitHub
- **Shared library**: Reusable code between modules

## 📦 Requirements

- Fedora 43+ Workstation
- GNOME Desktop
- Wayland (recommended)
- Internet connection

## 🚀 Quick Installation

### Via Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/lucasbt/fedora-launch/main/bootstrap.sh | bash
source ~/.bashrc
```

### Manual Installation

```bash
git clone https://github.com/lucasbt/fedora-launch.git ~/.local/share/fedoralaunch
ln -s ~/.local/share/fedoralaunch/fedoralaunch ~/.local/bin/fedoralaunch
chmod +x ~/.local/bin/fedoralaunch
```

## 📖 Basic Usage

```bash
# List modules
fedoralaunch list

# View status
fedoralaunch status

# Install specific module
fedoralaunch install system-base

# Install all modules
fedoralaunch install all

# Edit configuration
fedoralaunch config

# Update fedoralaunch
fedoralaunch self-update

# Uninstall
fedoralaunch self-uninstall
```

## 🧩 Modules

| Priority | Module | Description |
|---|---|---|
| 1 | system-base | Base system configuration |
| 2 | intel-graphics | Intel graphics drivers and optimizations |
| 3 | gnome-tweaks | GNOME settings and tweaks |
| 4 | anti-fatigue | Visual comfort settings |
| 5 | dev-tools | Development tools |
| 6 | rpm-apps | RPM applications |
| 7 | flatpak-apps | Flatpak applications |
| 8 | media-fonts-icons | Multimedia, Fonts and Icons |


## ⚙️ Configuration

Edit the file:

```bash
fedoralaunch config
# or
nano ~/.local/share/fedoralaunch/config/.env
```

## 📄 Recommended Flow

For a new system:

```bash
# 1. Bootstrap
curl -fsSL https://raw.githubusercontent.com/lucasbt/fedora-launch/main/bootstrap.sh | bash
source ~/.bashrc

fedoralaunch install all 

Or....

# 2. Configure preferences
fedoralaunch config

# 3. System base
fedoralaunch install system-base

# 4. Intel drivers
fedoralaunch install intel-graphics

# 5. Desktop
fedoralaunch install gnome-tweaks

# 6. Visual comfort
fedoralaunch install anti-fatigue

# 7. Development (optional)
fedoralaunch install dev-tools

# 8. Applications
fedoralaunch install rpm-apps
fedoralaunch install flatpak-apps

# 9. Reboot
sudo reboot
```

## 📊 Supported Hardware

### Intel Graphics

- **Haswell (4th gen)** - i965 ✅
  - Core i3/i5/i7-4xxx (i7-4510U)
  - HD Graphics 4400/4600/5000
  
- **Broadwell (5th gen)** - iHD (change config)
  - Core i3/i5/i7-5xxx
  
- **Skylake+ (6th+)** - iHD
  - Core i3/i5/i7-6xxx+

### Tested

- ✅ Dell Inspiron 15 (2014) - i7-4510U
- ✅ Lenovo ThinkPad T440 - i5-4300U
- ✅ HP Pavilion 14 - i7-4500U

## 🛠 Troubleshooting


## 📋 Logs

View log:

```bash
tail -f ~/.local/cache/fedoralaunch/fedoralaunch.log
```

## 🔐 Security

- Scripts run with user permissions
- `sudo` only when necessary
- Automatic config backups

## 🎯 Project Philosophy

### RPM-First Approach

fedoralaunch prioritizes RPMs because:
1. **Native integration** with system
2. **Updates via DNF** (single command)
3. **Official repositories** when available
4. **Lower overhead** than Flatpak

### Selective Flatpak

Flatpak used **only** for:
- Apps without official RPM (Obsidian)
- Apps with newer versions (Spotify)
- Development apps preferring sandboxing (Postman, Insomnia)

### Shared Library

`lib/utils.sh` provides:
- Logging functions (`log_info`, `log_success`)
- Command execution (`run_cmd`, `run_cmd_visible`)
- gsettings management (`gs_set`, `gs_get`)
- System checks (`check_fedora`, `is_intel_gpu`)
- Package installation (`dnf_install`, `flatpak_install`)
- File helpers (`ensure_dir`, `create_script`)

**Benefit**: DRY code, centralized maintenance, consistency

## 🤝 Contributing

1. Fork the project
2. Create your branch (`git checkout -b feature/MyFeature`)
3. Commit (`git commit -m 'Add MyFeature'`)
4. Push (`git push origin feature/MyFeature`)
5. Open Pull Request

## 📄 License

MIT License

## 📬 Contact

- GitHub: [@lucasbt](https://github.com/lucasbt)
- Issues: [github.com/lucasbt/fedora-launch/issues](https://github.com/lucasbt/fedora-launch/issues)

---

**fedoralaunch** *...by the community, for the community*

>_Fedora is a trademark of Red Hat, Inc. This project is not affiliated with, endorsed, or sponsored by the Fedora Project or Red Hat._