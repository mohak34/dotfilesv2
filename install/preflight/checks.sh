#!/bin/bash
set -euo pipefail

require_sudo() {
  sudo -v
}

check_arch_linux() {
  if [[ -f /etc/arch-release ]]; then
    return 0
  fi
  return 1
}

check_internet() {
  curl -s --max-time 10 https://archlinux.org >/dev/null 2>&1
}

check_disk_space() {
  local available
  available=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
  [[ $available -ge 10 ]]
}

run_preflight_checks() {
  local failed=0
  
  echo "Running preflight checks..."
  
  if ! check_arch_linux; then
    echo "ERROR: Not Arch Linux"
    failed=1
  else
    echo "OK: Arch Linux detected"
  fi
  
  if ! check_internet; then
    echo "ERROR: No internet connection"
    failed=1
  else
    echo "OK: Internet connection available"
  fi
  
  if ! check_disk_space; then
    echo "WARN: Less than 10GB disk space available"
  else
    echo "OK: Sufficient disk space"
  fi
  
  if [[ $failed -eq 1 ]]; then
    return 1
  fi
  
  require_sudo
  
  return 0
}
