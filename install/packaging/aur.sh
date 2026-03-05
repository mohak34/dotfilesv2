#!/bin/bash
set -euo pipefail

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi
  
  echo "Installing yay AUR helper..."
  local temp_dir
  temp_dir=$(mktemp -d)
  
  (
    cd "$temp_dir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
  )
  
  rm -rf "$temp_dir"
}

install_aur_packages() {
  if ! command -v yay >/dev/null 2>&1; then
    install_yay
  fi
  
  local package_file="$DOTFILES_PATH/packages/aur.txt"
  
  if [[ ! -f "$package_file" ]]; then
    return 0
  fi
  
  local packages=()
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ "$pkg" =~ ^#.*$ ]] && continue
    [[ -z "$pkg" ]] && continue
    
    if yay -Q "$pkg" >/dev/null 2>&1; then
      echo "$pkg already installed"
    else
      packages+=("$pkg")
    fi
  done < "$package_file"
  
  if [[ ${#packages[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Installing ${#packages[@]} AUR packages..."
  yay -S --noconfirm --needed "${packages[@]}" || \
    echo "WARNING: Some AUR packages failed to install. Check output above."
}
