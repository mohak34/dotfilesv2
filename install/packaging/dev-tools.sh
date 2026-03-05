#!/bin/bash
set -euo pipefail

install_go() {
  if command -v go >/dev/null 2>&1; then
    echo "Go already installed: $(go version)"
    return 0
  fi
  
  echo "Installing Go..."
  sudo pacman -S --noconfirm --needed go
}

install_rust() {
  if command -v rustc >/dev/null 2>&1; then
    echo "Rust already installed: $(rustc --version)"
    return 0
  fi
  
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  
  source "$HOME/.cargo/env"
}

install_uv() {
  if command -v uv >/dev/null 2>&1; then
    echo "UV already installed: $(uv --version)"
    return 0
  fi
  
  echo "Installing UV..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  
  export PATH="$HOME/.local/bin:$PATH"
}

install_node_nvm() {
  if command -v node >/dev/null 2>&1; then
    echo "Node already installed: $(node --version)"
    return 0
  fi
  
  if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  fi
  
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  
  echo "Installing Node.js 25..."
  nvm install 25
  nvm alias default 25
}

install_bun() {
  if command -v bun >/dev/null 2>&1; then
    echo "Bun already installed: $(bun --version)"
    return 0
  fi
  
  echo "Installing Bun..."
  curl -fsSL https://bun.com/install | bash
  
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
}

install_dev_tools() {
  echo "Installing development tools..."
  
  install_go
  install_rust
  install_uv
  install_node_nvm
  install_bun
  
  echo "Development tools installed!"
}
