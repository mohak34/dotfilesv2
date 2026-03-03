#!/bin/bash

set -euo pipefail

export DOTFILES_PATH="$HOME/.local/share/dotfilesv2"
export DOTFILES_INSTALL="$DOTFILES_PATH/install"
export PATH="$DOTFILES_PATH/bin:$PATH"

source "$DOTFILES_INSTALL/helpers/all.sh"
source "$DOTFILES_INSTALL/preflight/all.sh"
source "$DOTFILES_INSTALL/packaging/all.sh"
source "$DOTFILES_INSTALL/config/all.sh"
source "$DOTFILES_INSTALL/themes/all.sh"
source "$DOTFILES_INSTALL/post-install/all.sh"

main() {
  log_info "Starting Dotfiles v2 installation..."
  
  run_preflight
  run_packaging
  run_config
  
  log_success "Installation complete! Please log out and log back in for all changes to take effect."
}

main "$@"
