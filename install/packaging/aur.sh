#!/bin/bash
set -uo pipefail

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing yay AUR helper..."
  sudo pacman -S --noconfirm --needed base-devel

  local temp_dir
  temp_dir=$(mktemp -d)

  if ! git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"; then
    echo "ERROR: Failed to clone yay repository"
    rm -rf "$temp_dir"
    return 1
  fi

  if ! (cd "$temp_dir/yay" && makepkg -si --noconfirm); then
    echo "ERROR: Failed to build and install yay"
    rm -rf "$temp_dir"
    return 1
  fi

  rm -rf "$temp_dir"

  if ! command -v yay >/dev/null 2>&1; then
    echo "ERROR: yay was not installed successfully"
    return 1
  fi
}

install_aur_packages() {
  if ! command -v yay >/dev/null 2>&1; then
    if ! install_yay; then
      echo "WARNING: yay is not available. Skipping AUR packages."
      return 0
    fi
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
  if ! yay -S --noconfirm --needed "${packages[@]}"; then
    echo "WARNING: Some AUR packages failed to install. Check output above."
  fi
}
