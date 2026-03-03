#!/bin/bash
set -euo pipefail

hw_nvidia() {
  lspci | grep -iq nvidia
}

hw_asus() {
  local product
  product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
  local vendor
  vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")
  
  [[ "$product" == *"ROG"* ]] || \
  [[ "$product" == *"ASUS"* ]] || \
  [[ "$vendor" == *"ASUS"* ]] || \
  [[ -d /sys/class/dmi/id/board_name ]] && grep -qi "asus" /sys/class/dmi/id/board_name 2>/dev/null
}

hw_laptop() {
  [[ -d /sys/class/power_supply/BAT0 ]] || \
  [[ -d /sys/class/power_supply/BAT1 ]]
}

hw_amd_gpu() {
  lspci | grep -iq "radeon\|amd"
}

hw_intel_gpu() {
  lspci | grep -iq "intel"
}

get_display_manager() {
  if systemctl list-unit-files 2>/dev/null | grep -q "sddm"; then
    echo "sddm"
  elif systemctl list-unit-files 2>/dev/null | grep -q "lightdm"; then
    echo "lightdm"
  elif systemctl list-unit-files 2>/dev/null | grep -q "gdm"; then
    echo "gdm"
  else
    echo "none"
  fi
}

get_cpu_info() {
  lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | xargs
}

get_gpu_info() {
  lspci 2>/dev/null | grep -iE "VGA|3D" | cut -d':' -f3 | xargs
}
