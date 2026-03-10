#!/bin/bash
set -euo pipefail

backup_config() {
  local src="$1"
  local dest="$2"
  local backup
  backup="${dest}.backup.$(date +%s)"

  if [[ -f "$dest" ]]; then
    cp "$dest" "$backup"
    echo "Backed up file $dest -> $backup"
  elif [[ -d "$dest" ]]; then
    cp -r "$dest" "$backup"
    echo "Backed up directory $dest -> $backup"
  fi
}

copy_config_dir() {
  local src_dir="$DOTFILES_PATH/config/$1"
  local dest_dir="$HOME/.config/$1"

  if [[ ! -d "$src_dir" ]]; then
    echo "Source config dir not found: $src_dir"
    return 1
  fi

  mkdir -p "$dest_dir"

  if [[ -d "$dest_dir" ]]; then
    backup_config "$src_dir" "$dest_dir"
  fi

  rsync -av "$src_dir/" "$dest_dir/"
  echo "Copied $src_dir -> $dest_dir"
}

copy_config_file() {
  local src_file="$DOTFILES_PATH/config/$1"
  local dest_file="$HOME/.config/$1"

  if [[ ! -f "$src_file" ]]; then
    echo "Source config file not found: $src_file"
    return 1
  fi

  mkdir -p "$(dirname "$dest_file")"

  if [[ -f "$dest_file" ]]; then
    backup_config "$src_file" "$dest_file"
  fi

  cp "$src_file" "$dest_file"
  echo "Copied $src_file -> $dest_file"
}

install_configs() {
  echo "Installing configurations..."
  
  local config_dirs=(
    "hypr"
    "quickshell"
    "ghostty"
    "btop"
    "wlogout"
    "environment.d"
    "opencode"
    "matugen"
    "auto-cpufreq"
  )
  
  for dir in "${config_dirs[@]}"; do
    if [[ -d "$DOTFILES_PATH/config/$dir" ]]; then
      copy_config_dir "$dir"
    fi
  done

  if [[ "${INSTALL_ASUS:-false}" == "true" ]]; then
    touch "$HOME/.config/.dotfiles-install-asus"
    cp "$DOTFILES_PATH/config/hypr/asus.conf" "$HOME/.config/hypr/asus.conf"
    echo "Installed ASUS-specific hypr config"
  else
    rm -f "$HOME/.config/.dotfiles-install-asus"
    rm -f "$HOME/.config/hypr/asus.conf"
  fi

  if [[ "${INSTALL_NVIDIA:-false}" == "true" ]]; then
    echo "Appending NVIDIA environment variables to hyprland nvidia.conf..."

    local nvidia_card="" igpu_card=""
    for card in /sys/class/drm/card[0-9]/device/vendor; do
      [[ -f "$card" ]] || continue
      local vendor
      vendor=$(cat "$card")
      local card_node
      card_node=$(echo "$card" | grep -o 'card[0-9]')
      if [[ "$vendor" == "0x10de" ]]; then
        nvidia_card="/dev/dri/${card_node}"
      else
        igpu_card="/dev/dri/${card_node}"
      fi
    done

    local aq_drm_devices
    if [[ -n "$nvidia_card" && -n "$igpu_card" ]]; then
      aq_drm_devices="${igpu_card}:${nvidia_card}"
    elif [[ -n "$nvidia_card" ]]; then
      aq_drm_devices="$nvidia_card"
    else
      aq_drm_devices="/dev/dri/card0:/dev/dri/card1"
    fi

    cat >> "$HOME/.config/hypr/nvidia.conf" <<EOF

env = AQ_DRM_DEVICES,${aq_drm_devices}
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
env = WLR_NO_HARDWARE_CURSORS,1
EOF
  fi
  
  if [[ -f "$DOTFILES_PATH/.tmux.conf" ]]; then
    local dest_tmux="$HOME/.tmux.conf"
    if [[ -f "$dest_tmux" ]]; then
      backup_config "$DOTFILES_PATH/.tmux.conf" "$dest_tmux"
    fi
    cp "$DOTFILES_PATH/.tmux.conf" "$dest_tmux"
    echo "Copied .tmux.conf"
  fi
  
  if [[ -f "$DOTFILES_PATH/.zshrc" ]]; then
    local dest_zshrc="$HOME/.zshrc"
    if [[ -f "$dest_zshrc" ]]; then
      backup_config "$DOTFILES_PATH/.zshrc" "$dest_zshrc"
    fi
    cp "$DOTFILES_PATH/.zshrc" "$dest_zshrc"
    echo "Copied .zshrc"
  fi
  
  echo "Installing scripts..."
  mkdir -p "$HOME/.local/bin/scripts"
  if [[ -d "$DOTFILES_PATH/bin/scripts" ]]; then
    for script in "$DOTFILES_PATH"/bin/scripts/*; do
      if [[ -f "$script" ]]; then
        cp "$script" "$HOME/.local/bin/scripts/"
        chmod +x "$HOME/.local/bin/scripts/$(basename "$script")"
        echo "Installed script: $(basename "$script")"
      fi
    done
  fi
  
  echo "Creating dotfiles bin symlinks..."
  mkdir -p "$HOME/.local/bin"
  ln -sf "$DOTFILES_PATH/bin/dotfiles-update" "$HOME/.local/bin/dotfiles-update"
  ln -sf "$DOTFILES_PATH/bin/dotfiles-version" "$HOME/.local/bin/dotfiles-version"
  ln -sf "$DOTFILES_PATH/bin/dotfiles-refresh-config" "$HOME/.local/bin/dotfiles-refresh-config"
  
  echo "Installing wallpapers..."
  mkdir -p "$HOME/Pictures/Wallpapers"
  rsync -av "$DOTFILES_PATH/wallpapers/" "$HOME/Pictures/Wallpapers/"

  echo "Configurations installed!"
}
