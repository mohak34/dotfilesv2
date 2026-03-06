#!/bin/bash
set -euo pipefail

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh already installed"
    return 0
  fi
  
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://install.ohmyz.sh/)" -- --unattended
  
  echo "Oh My Zsh installed!"
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  
  if [[ -d "$tpm_dir" ]]; then
    echo "TPM already installed"
    return 0
  fi
  
  echo "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  
  echo "TPM installed!"
}

set_default_shell() {
  local zsh_path
  zsh_path=$(command -v zsh)

  if [[ -z "$zsh_path" ]]; then
    echo "zsh not found"
    return 1
  fi

  if [[ "$SHELL" == *"$zsh_path"* ]]; then
    echo "zsh already default shell"
    return 0
  fi

  echo "Setting zsh as default shell..."
  chsh -s "$zsh_path"

  echo "Default shell set to zsh. Log out and back in to apply."
}

install_shell() {
  echo "Setting up shell..."

  install_oh_my_zsh
  install_tpm

  echo "Shell setup complete!"
}

setup_shell_paths() {
  echo "Setting up shell paths..."
  
  local shell_rc="$HOME/.zshrc"
  
  if [[ -f "$shell_rc" ]]; then
    if ! grep -q "DOTFILES_PATH" "$shell_rc"; then
      echo '' >> "$shell_rc"
      echo '# Dotfiles v2' >> "$shell_rc"
      echo 'export DOTFILES_PATH="$HOME/.local/share/dotfilesv2"' >> "$shell_rc"
      echo 'export PATH="$DOTFILES_PATH/bin:$PATH"' >> "$shell_rc"
    fi
    
    if ! grep -q "BUN_INSTALL" "$shell_rc"; then
      echo '' >> "$shell_rc"
      echo '# Bun' >> "$shell_rc"
      echo 'export BUN_INSTALL="$HOME/.bun"' >> "$shell_rc"
      echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$shell_rc"
    fi
    
    if ! grep -q "NVM_DIR" "$shell_rc"; then
      echo '' >> "$shell_rc"
      echo '# NVM' >> "$shell_rc"
      echo 'export NVM_DIR="$HOME/.nvm"' >> "$shell_rc"
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$shell_rc"
    fi
    
    if ! grep -q ".cargo/env" "$shell_rc"; then
      echo '' >> "$shell_rc"
      echo '# Rust' >> "$shell_rc"
      echo '[ -f "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"' >> "$shell_rc"
    fi
  fi
  
  echo "Shell paths configured!"
}

install_shell() {
  echo "Setting up shell..."
  
  install_oh_my_zsh
  install_tpm
  set_default_shell
  setup_shell_paths
  
  echo "Shell setup complete!"
}
