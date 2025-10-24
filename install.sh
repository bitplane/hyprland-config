#!/bin/bash

# Hyprland Configuration Installer

set -e

echo "Installing Hyprland configuration..."

# Create config directories
mkdir -p ~/.config/{hypr,waybar,fuzzel}
mkdir -p ~/.local/bin

# Install configs with symlinks
echo "Linking configuration files..."
ln -sf "$(pwd)/config/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf
ln -sf "$(pwd)/config/waybar/config" ~/.config/waybar/config
ln -sf "$(pwd)/config/waybar/style.css" ~/.config/waybar/style.css

# Install scripts
echo "Installing scripts..."
chmod +x scripts/*
for script in scripts/*; do
    script_name=$(basename "$script" .py)
    ln -sf "$(pwd)/$script" ~/.local/bin/"$script_name"
    echo "  Linked $script_name"
done

# Check if hyprworm is available
if command -v hyprworm &> /dev/null; then
    echo "✓ hyprworm is installed"
else
    echo "⚠ hyprworm not found - install from https://github.com/liammmcauliffe/hyprworm"
fi

# Check critical dependencies
echo "Checking dependencies..."
DEPS=(hyprland waybar kitty fuzzel mako grim slurp wf-recorder wl-copy wtype rofimoji)
MISSING=()

for dep in "${DEPS[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "✓ $dep"
    else
        echo "✗ $dep (missing)"
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "Missing dependencies. Install with:"
    echo "sudo apt install ${MISSING[*]}"
    echo ""
fi

echo ""
echo "Configuration installed! Restart Hyprland or logout/login to apply changes."
echo ""
echo "To enable OpenRazer keyboard RGB:"
echo "  sudo gpasswd -a \$USER plugdev"
echo "  sudo systemctl enable --now openrazer-daemon"
echo ""