#!/bin/bash

set -uo pipefail

export DOTFILES_PATH="$HOME/.local/share/dotfilesv2"
export DOTFILES_INSTALL="$DOTFILES_PATH/install"
export PATH="$DOTFILES_PATH/bin:$PATH"

source "$DOTFILES_INSTALL/helpers/all.sh"
source "$DOTFILES_INSTALL/preflight/all.sh"
source "$DOTFILES_INSTALL/packaging/all.sh"
source "$DOTFILES_INSTALL/config/all.sh"
source "$DOTFILES_INSTALL/post-install/all.sh"

ERRORS=()
WARNINGS=()

track_error() {
  ERRORS+=("$1")
  echo "❌ ERROR: $1" >&2
}

track_warning() {
  WARNINGS+=("$1")
  echo "⚠️  WARNING: $1" >&2
}

show_installation_summary() {
  echo ""
  echo "=========================================="
  echo "    Installation Summary"
  echo "=========================================="
  echo ""

  if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo "✅ Installation completed successfully!"
    touch "$DOTFILES_PATH/.install-completed"
    echo ""
    echo "Next steps:"
    echo "  1. Reboot your system: sudo reboot"
    echo "  2. Login with Hyprland"
  else
    echo "⚠️  Installation completed with warnings/errors"
    echo ""
    echo "Errors encountered:"
    for error in "${ERRORS[@]}"; do
      echo "  ❌ $error"
    done

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
      echo ""
      echo "Warnings:"
      for warning in "${WARNINGS[@]}"; do
        echo "  ⚠️  $warning"
      done
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Review the errors above"
    echo "  2. Fix any issues manually"
    echo "  3. Re-run the install script:"
    echo "     curl -fsSL https://raw.githubusercontent.com/mohak34/dotfilesv2/main/boot.sh | bash"
  fi

  echo ""
  echo "=========================================="
}

main() {
  log_info "Starting Dotfiles v2 installation..."

  run_preflight || track_error "Preflight checks failed"
  run_packaging || track_error "Package installation failed"
  run_config || track_error "Configuration failed"
  run_post_install || track_error "Post-install failed"

  show_installation_summary
}

main "$@"
