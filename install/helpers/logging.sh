#!/bin/bash
set -euo pipefail

log_info() {
  gum log --level info "$1"
}

log_warn() {
  gum log --level warn "$1"
}

log_error() {
  gum log --level error "$1"
}

log_success() {
  gum log --level info "$1"
}

log_debug() {
  gum log --level debug "$1"
}

run_logged() {
  local description="$1"
  shift
  echo "$description"
  "$@"
}

confirm() {
  local prompt="$1"
  gum confirm "$prompt"
}

choose() {
  local prompt="$1"
  shift
  gum choose "$prompt" "$@"
}

input() {
  local prompt="$1"
  local default="$2"
  gum input --prompt "$prompt" --value "$default"
}

style() {
  gum style "$@"
}
