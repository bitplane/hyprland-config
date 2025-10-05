# Hyprland Configuration

Complete Hyprland setup for Razer Blade 14 2022 with waybar, RGB keyboard control, and all the bells and whistles.

## Dependencies

### Core Packages
```bash
sudo apt install \
    hyprland \
    waybar \
    kitty \
    fuzzel \
    mako-notifier \
    grim \
    slurp \
    wf-recorder \
    wl-clipboard \
    wtype \
    rofimoji \
    brightnessctl \
    playerctl \
    blueman \
    network-manager-gnome \
    pavucontrol \
    btop \
    nautilus \
    firefox \
    openrazer-meta \
    python3-openrazer \
    libcjson-dev
```

### Optional Tools
```bash
# Window switcher (compiled from source)
git clone https://github.com/liammmcauliffe/hyprworm.git
cd hyprworm && make && sudo make install

# Keyboard RGB control
pip install openrazer[client]
```

## Installation

1. Clone this repository:
   ```bash
   git clone <repo-url> ~/src/hyprland-config
   ```

2. Install dependencies (see above)

3. Run the install script:
   ```bash
   cd ~/src/hyprland-config
   ./install.sh
   ```

4. Restart Hyprland or logout/login

## Features

- **Display**: 2560x1440 @ 165Hz with 1.25x scaling
- **Status Bar**: Waybar with system monitoring, media controls, and network info
- **Window Management**: Fuzzel launcher, hyprworm window switcher
- **Screenshots**: grim + slurp with Print Screen keybindings
- **Screen Recording**: wf-recorder with toggle keybinding
- **RGB Keyboard**: OpenRazer integration with per-key control
- **Media Keys**: Volume, brightness, playback controls
- **Notifications**: Mako notification daemon
- **System Tray**: Integrated in waybar

## Keybindings

| Key Combo | Action |
|-----------|--------|
| Super + Q | Terminal (kitty) |
| Super + C | Close window |
| Super + Shift + C | Force kill window |
| Super + Space | App launcher (fuzzel) |
| Super + Period | Emoji picker |
| Alt + Tab | Window switcher |
| Print | Screenshot |
| Shift + Print | Area screenshot |
| Ctrl + Print | Window screenshot |
| Super + Shift + R | Toggle screen recording |
| Super + F | Toggle fullscreen |
| Media Keys | Volume/brightness/playback |

## File Structure

```
├── config/
│   ├── hypr/hyprland.conf
│   ├── waybar/config
│   ├── waybar/style.css
│   └── fuzzel/fuzzel.ini
├── scripts/
│   ├── window-switcher
│   ├── screen-record
│   ├── weather-widget
│   └── keyboard-mapper.py
├── install.sh
└── README.md
```