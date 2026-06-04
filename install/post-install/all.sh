#!/bin/bash
set -uo pipefail

run_post_install() {
  source "$DOTFILES_INSTALL/post-install/finalize.sh" || true
}
