#!/bin/bash
set -euo pipefail

is_arch_linux() {
  [[ -f /etc/arch-release ]]
}

has_internet() {
  curl -s --max-time 5 https://archlinux.org >/dev/null 2>&1
}

get_disk_space() {
  df -h "$HOME" | awk 'NR==2 {print $4}'
}

get_memory() {
  free -h | awk 'NR==2 {print $2}'
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

package_installed() {
  pacman -Q "$1" >/dev/null 2>&1
}

is_installed() {
  command_exists "$1" || package_installed "$1"
}

require_root() {
  [[ $EUID -eq 0 ]]
}

get_os_info() {
  uname -a
}

get_kernel_version() {
  uname -r
}
