#!/bin/bash

install_neovim() {
  echo ">>> Installing Neovim..."
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
	chmod u+x nvim-linux-x86_64.appimage
	sudo mkdir -p /opt/nvim
	sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim

	BASHRC="$HOME/.bashrc"
	LINE='export PATH="$PATH:/opt/nvim/"'

	if grep -Fxq "$LINE" "$BASHRC"; then
		echo "PATH entry already exists in .bashrc"
	else
		echo "" >> "$BASHRC"
		echo "# Add Neovim to PATH"
		echo "$LINE" >> "$BASHRC"
		echo "# Added Neovim to PATH in .bashrc"
	fi
}

install_nvim_deps() {
  echo ">>> Installing neovim plugins dependencies"
  sudo apt install -y build-essential

  # Download and install nvm:
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  # in lieu of restarting the shell
  \. "$HOME/.nvm/nvm.sh"

  # Download and install Node.js:
  nvm install 24

  # Verify the Node.js version:
  node -v # Should print "v24.12.0".

  # Verify npm version:
  npm -v # Should print "11.6.2".
}

install_i3() {
  echo ">>> Installing i3 window manager..."
  sudo apt install -y \
    i3-wm \
    i3status \
    i3lock \
    i3blocks
}

install_polybar() {
  echo ">>> Installing polybar..."
  sudo apt install -y  \
    polybar \
    fonts-font-awesome\
    fonts-materialdesignicons-webfont\
    feh \
    pulseaudio-utils \
    brightnessctl \
    playerctl \
    x11-xserver-utils
}

install_rofi() {
  echo ">>> Installing rofi..."
  sudo apt install rofi 
}

install_lazygit() {
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

echo ">>> Updating package lists..."
sudo apt-get update

if command -v nvim &>/dev/null; then
	echo "Neovim is already installed"
else
	install_neovim
fi

install_nvim_deps
install_polybar
install_rofi
install_lazygit

echo
echo ">>> Installation complete!"
echo "If you are using dotfiles + stow, run:"
echo "    cd ~/dotfiles && stow i3"
echo "    cd ~/dotfiles && stow polybar"
echo "    cd ~/dotfiles && stow rofi"
echo "    cd ~/dotfiles && stow nvim"
echo
echo ">>> Log out and log back in to start i3 (or restart i3 with \$mod+Shift+r)."
