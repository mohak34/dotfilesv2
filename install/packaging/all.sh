#!/bin/bash
set -euo pipefail

source "$DOTFILES_INSTALL/helpers/all.sh"

run_packaging() {
  log_info "Starting package installation..."
  
  log_info "Installing base packages..."
  source "$DOTFILES_INSTALL/packaging/pacman.sh"
  install_base_packages
  
  log_info "Installing Hyprland packages..."
  install_hyprland_packages
  
  log_info "Installing AUR packages..."
  source "$DOTFILES_INSTALL/packaging/aur.sh"
  install_aur_packages
  
  log_info "Installing development tools..."
  source "$DOTFILES_INSTALL/packaging/dev-tools.sh"
  install_dev_tools
  
  log_info "Installing optional packages..."
  source "$DOTFILES_INSTALL/packaging/optional.sh"
  install_optional_packages "$INSTALL_NVIDIA" "$INSTALL_ASUS"
  
  log_success "Package installation complete!"
}
