#!/bin/bash
set -euo pipefail

source "$DOTFILES_INSTALL/helpers/all.sh"

run_config() {
  log_info "Installing configurations..."
  
  source "$DOTFILES_INSTALL/config/dotfiles.sh"
  install_configs
  
  source "$DOTFILES_INSTALL/config/shell.sh"
  install_shell
  
  source "$DOTFILES_INSTALL/config/services.sh"
  install_services
  
  log_success "Configuration complete!"
}
