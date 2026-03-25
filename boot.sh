#!/bin/bash

set -uo pipefail

# Install prerequisites first
if ! command -v git >/dev/null 2>&1; then
  echo "Installing git..."
  sudo pacman -S --noconfirm git
fi

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

if [[ -f "$DOTFILES_PATH/.install-completed" ]]; then
  echo "Dotfiles v2 already installed. Running update..."
  "$DOTFILES_PATH/bin/dotfiles-update"
else
  if [[ -d "$DOTFILES_PATH" ]]; then
    echo "Previous installation incomplete. Re-running install..."
  else
    echo "Installing Dotfiles v2..."
    git clone https://github.com/mohak34/dotfilesv2.git "$DOTFILES_PATH"
  fi
  source "$DOTFILES_PATH/install.sh"
fi
