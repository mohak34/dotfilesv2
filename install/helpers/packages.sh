#!/bin/bash
set -euo pipefail

pkg_is_installed() {
  pacman -Q "$1" >/dev/null 2>&1
}

pkg_install() {
  local package="$1"
  local use_aur="${2:-false}"
  
  if pkg_is_installed "$package"; then
    return 0
  fi
  
  if [[ "$use_aur" == "true" ]]; then
    if command -v yay >/dev/null 2>&1; then
      yay -S --noconfirm "$package"
    elif command -v paru >/dev/null 2>&1; then
      paru -S --noconfirm "$package"
    else
      echo "No AUR helper (yay/paru) found"
      return 1
    fi
  else
    sudo pacman -S --noconfirm --needed "$package"
  fi
}

pkg_install_from_file() {
  local file="$1"
  local use_aur="${2:-false}"
  
  if [[ ! -f "$file" ]]; then
    echo "Package file not found: $file"
    return 1
  fi
  
  while IFS= read -r package || [[ -n "$package" ]]; do
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue
    
    echo "Installing $package..."
    pkg_install "$package" "$use_aur" || true
  done < "$file"
}

aur_helper_installed() {
  command -v yay >/dev/null 2>&1 || command -v paru >/dev/null 2>&1
}

install_aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi
  
  if command -v paru >/dev/null 2>&1; then
    return 0
  fi
  
  echo "Installing yay AUR helper..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/yay
}
