# Hyprland Configuration

Hyprland setup with waybar, RGB keyboard control, and all the bells and whistles.

## Installation

```bash
git clone <repo-url> ~/src/hyprland-config
cd ~/src/hyprland-config
make install
```

The Makefile will check for missing dependencies and tell you what to install.

## Features

- **Status Bar**: Waybar with system monitoring, media controls, and network info
- **Window Management**: Fuzzel launcher, wofi app menu
- **Screenshots**: grim + slurp with Print Screen keybindings
- **Screen Recording**: wf-recorder with toggle keybinding
- **RGB Keyboard**: OpenRazer integration with per-key control
- **Media Keys**: Volume, brightness, playback controls
- **Notifications**: Mako notification daemon
- **Voice Dictation**: Whisper-based speech to text

## Keybindings

| Key Combo | Action |
|-----------|--------|
| Super + Q | Terminal |
| Super + C | Close window |
| Super + R | App launcher (wofi) |
| Super + E | File manager |
| Super + Period | Emoji picker |
| Alt + Tab | Window switcher |
| Print | Screenshot |
| Shift + Print | Area screenshot |
| Ctrl + Print | Window screenshot |
| Super + Shift + R | Toggle screen recording |
| Super + Ctrl + R | Record selected area |
| Super + F | Toggle fullscreen |
| Super + A (hold) | Voice dictation |
| Media Keys | Volume/brightness/playback |
