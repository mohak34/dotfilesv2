#!/bin/bash
set -euo pipefail

source "$DOTFILES_INSTALL/helpers/all.sh"
source "$DOTFILES_INSTALL/preflight/checks.sh"
source "$DOTFILES_INSTALL/preflight/hardware.sh"

run_preflight() {
  run_logged "Running preflight checks..." run_preflight_checks
  
  detect_hardware
}
