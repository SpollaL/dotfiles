#!/usr/bin/env bash

set -e

echo ">>> Updating package lists..."
sudo apt update

echo ">>> Installing i3 window manager..."
sudo apt install -y i3-wm i3status i3lock i3blocks

echo ">>> Installing utilities required by your i3 config..."
sudo apt install -y \
    pulseaudio-utils \    # provides pactl
    brightnessctl \
    playerctl \
    x11-xserver-utils     # provides xrandr

echo ">>> Installing Polybar..."
sudo apt install -y polybar fonts-font-awesome fonts-materialdesignicons-webfont

echo ">>> Installing Rofi..."
sudo apt install -y rofi

echo ">>> Installing feh..."
sudo apt install -y feh

echo ">>> Creating config dirs (if missing)..."
mkdir -p ~/.config/i3
mkdir -p ~/.config/polybar
mkdir -p ~/.config/rofi

echo
echo ">>> Installation complete!"
echo "If you are using dotfiles + stow, run:"
echo "    cd ~/dotfiles && stow i3"
echo "    cd ~/dotfiles && stow polybar"
echo "    cd ~/dotfiles && stow rofi"
echo
echo ">>> Log out and log back in to start i3 (or restart i3 with \$mod+Shift+r)."

