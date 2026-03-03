#!/bin/bash
set -euo pipefail

install_nvidia_packages() {
  local package_file="$DOTFILES_PATH/packages/nvidia.txt"
  
  if [[ ! -f "$package_file" ]]; then
    return 0
  fi
  
  local packages=()
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ "$pkg" =~ ^#.*$ ]] && continue
    [[ -z "$pkg" ]] && continue
    
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      echo "$pkg already installed"
    else
      packages+=("$pkg")
    fi
  done < "$package_file"
  
  if [[ ${#packages[@]} -eq 0 ]]; then
    return 0
  fi
  
  echo "Installing NVIDIA packages..."
  sudo pacman -S --noconfirm --needed "${packages[@]}"
}

install_asus_packages() {
  if ! command -v yay >/dev/null 2>&1; then
    echo "yay not installed, skipping ASUS packages"
    return 1
  fi
  
  local package_file="$DOTFILES_PATH/packages/asus.txt"
  
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
  
  echo "Installing ASUS packages..."
  yay -S --noconfirm --needed "${packages[@]}"
}

install_optional_packages() {
  local install_nvidia="${1:-false}"
  local install_asus="${2:-false}"
  
  if [[ "$install_nvidia" == "true" ]]; then
    install_nvidia_packages
  fi
  
  if [[ "$install_asus" == "true" ]]; then
    install_asus_packages
  fi
}
