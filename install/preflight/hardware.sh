#!/bin/bash

detect_hardware() {
  echo "Detecting hardware..."
  
  export INSTALL_NVIDIA=false
  export INSTALL_ASUS=false
  export INSTALL_LAPTOP=false
  
  if hw_nvidia; then
    echo "Found: NVIDIA GPU"
    if gum confirm "NVIDIA GPU detected. Install NVIDIA drivers?"; then
      export INSTALL_NVIDIA=true
    fi
  else
    echo "No NVIDIA GPU detected"
  fi
  
  if gum confirm "Do you have an ASUS laptop? Install ASUS tools (asusctl, supergfxctl)?"; then
    echo "ASUS tools will be installed"
    export INSTALL_ASUS=true
  else
    echo "ASUS tools skipped"
  fi
  
  if hw_laptop; then
    echo "Found: Laptop"
    if gum confirm "Laptop detected. Install laptop-specific packages?"; then
      export INSTALL_LAPTOP=true
    fi
  else
    echo "Desktop system detected"
  fi
  
  echo ""
  echo "Hardware Summary:"
  echo "  NVIDIA drivers: $INSTALL_NVIDIA"
  echo "  ASUS tools: $INSTALL_ASUS"
  echo "  Laptop packages: $INSTALL_LAPTOP"
}
