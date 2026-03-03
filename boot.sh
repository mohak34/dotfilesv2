#!/bin/bash

set -euo pipefail

# Install prerequisites first
if ! command -v gum >/dev/null 2>&1; then
  echo "Installing gum..."
  sudo pacman -S --noconfirm gum
fi

if ! command -v go >/dev/null 2>&1; then
  echo "Installing go..."
  sudo pacman -S --noconfirm go
fi

export DOTFILES_PATH="$HOME/.local/share/dotfilesv2"
export DOTFILES_INSTALL="$DOTFILES_PATH/install"
export PATH="$DOTFILES_PATH/bin:$PATH"

if [[ -d "$DOTFILES_PATH" ]]; then
  echo "Dotfiles v2 already installed. Updating..."
  (
    cd "$DOTFILES_PATH"
    git pull --rebase
  )
else
  echo "Installing Dotfiles v2..."
  git clone https://github.com/mohak34/dotfilesv2.git "$DOTFILES_PATH"
fi

source "$DOTFILES_PATH/install.sh"
