#!/bin/bash
set -euo pipefail

run_post_install() {
  source "$DOTFILES_INSTALL/post-install/finalize.sh" || true
}
