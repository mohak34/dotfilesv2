#!/bin/bash
set -euo pipefail

install_pacman_packages() {
  local package_file="$1"
  
  if [[ ! -f "$package_file" ]]; then
    echo "Package file not found: $package_file"
    return 1
  fi
  
  local packages=()
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ "$pkg" =~ ^#.*$ ]] && continue
    [[ -z "$pkg" ]] && continue
    packages+=("$pkg")
  done < "$package_file"
  
  if [[ ${#packages[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Installing ${#packages[@]} packages from $package_file..."
  sudo pacman -S --noconfirm --needed "${packages[@]}"
}

update_system() {
  echo "Updating system..."
  sudo pacman -Syu --noconfirm
}

install_base_packages() {
  update_system
  install_pacman_packages "$DOTFILES_PATH/packages/base.txt"
}

install_hyprland_packages() {
  install_pacman_packages "$DOTFILES_PATH/packages/hyprland.txt"
}
