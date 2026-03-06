#!/bin/bash
set -euo pipefail

enable_service() {
  local service="$1"
  
  if systemctl list-unit-files 2>/dev/null | grep -q "^$service"; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "Service $service not found, skipping"
  fi
}

start_service() {
  local service="$1"
  
  if systemctl list-unit-files 2>/dev/null | grep -q "^$service"; then
    echo "Starting $service..."
    sudo systemctl start "$service"
  fi
}

install_services() {
  echo "Setting up services..."

  enable_service "NetworkManager"
  start_service "NetworkManager"

  enable_service "bluetooth"

  if [[ "${INSTALL_LAPTOP:-false}" == "true" ]]; then
    enable_service "auto-cpufreq"
  fi

  if [[ "${INSTALL_ASUS:-false}" == "true" ]]; then
    enable_service "supergfxd"
  fi

  echo "Services configured!"
}
