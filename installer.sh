#!/bin/bash
# Minimal Arch setup script for Intel i3-115G4 with GUI tools

if [[ $EUID -ne 0 ]]; then
   echo "Run as root" 
   exit 1
fi

# Update system
pacman -Syu --noconfirm

# Basic tools
pacman -S --noconfirm git vim neovim base-devel wget curl unzip

# Zsh and plugins
pacman -S --noconfirm zsh zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting /usr/share/zsh/plugins/zsh-syntax-highlighting

# Terminal and GUI tools
pacman -S --noconfirm kitty rofi flameshot firefox brightnessctl auto-cpu-freq nautilus zenity dunst

# Audio and multimedia
pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack

# Bluetooth
pacman -S --noconfirm bluez bluez-utils
systemctl enable --now bluetooth.service

# Yay for AUR
cd /opt
git clone https://aur.archlinux.org/yay.git
chown -R $SUDO_USER:$SUDO_USER yay
cd yay
sudo -u $SUDO_USER makepkg -si --noconfirm

# Eww from AUR
sudo -u $SUDO_USER yay -S --noconfirm eww

# Lutris for gaming
pacman -S --noconfirm lutris

# Starship prompt
curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# Nerd Fonts (JetBrains Mono)
sudo -u $SUDO_USER yay -S --noconfirm ttf-jetbrains-mono-nerd

# Configure zsh for user
USERHOME=$(eval echo ~$SUDO_USER)
ZSHRC="$USERHOME/.zshrc"

cat << 'EOF' >> $ZSHRC
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# Starship prompt
eval "$(starship init zsh)"

# Add user binaries and eww path
export PATH="$HOME/eww/target/release:$PATH"

autoload -Uz compinit
compinit

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# Set zsh as default shell
chsh -s $(which zsh) $SUDO_USER

echo "Installation complete. Reboot recommended."
