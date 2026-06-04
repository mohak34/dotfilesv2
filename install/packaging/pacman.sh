#!/bin/bash
set -uo pipefail

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
  if ! sudo pacman -S --noconfirm --needed "${packages[@]}"; then
    echo "WARNING: Batch install failed. Retrying packages individually..."
    local failed=0
    for pkg in "${packages[@]}"; do
      if ! sudo pacman -S --noconfirm --needed "$pkg"; then
        echo "WARNING: Failed to install $pkg"
        ((failed++))
      fi
    done
    if (( failed > 0 )); then
      echo "WARNING: $failed package(s) failed to install from $package_file"
    fi
  fi
}

update_system() {
  echo "Updating system..."
  sudo pacman -Syu --noconfirm
}

install_base_packages() {
  update_system

  if [[ -n "${CPU_UCODE:-}" ]]; then
    echo "Installing CPU microcode: $CPU_UCODE"
    sudo pacman -S --noconfirm --needed "$CPU_UCODE"
  fi

  install_pacman_packages "$DOTFILES_PATH/packages/base.txt"
}

install_hyprland_packages() {
  install_pacman_packages "$DOTFILES_PATH/packages/hyprland.txt"
}
