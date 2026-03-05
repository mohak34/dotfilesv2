#!/bin/bash
set -euo pipefail

backup_config() {
	local src="$1"
	local dest="$2"
	local backup
	backup="${dest}.backup.$(date +%s)"

	if [[ -f "$dest" ]]; then
		cp "$dest" "$backup"
		echo "Backed up file $dest -> $backup"
	elif [[ -d "$dest" ]]; then
		cp -r "$dest" "$backup"
		echo "Backed up directory $dest -> $backup"
	fi
}

copy_config_dir() {
	local src_dir="$DOTFILES_PATH/config/$1"
	local dest_dir="$HOME/.config/$1"

	if [[ ! -d "$src_dir" ]]; then
		echo "Source config dir not found: $src_dir"
		return 1
	fi

	mkdir -p "$(dirname "$dest_dir")"

	if [[ -d "$dest_dir" ]]; then
		backup_config "$src_dir" "$dest_dir"
	fi

	rsync -av "$src_dir/" "$dest_dir/"
	echo "Copied $src_dir -> $dest_dir"
}

copy_config_file() {
	local src_file="$DOTFILES_PATH/config/$1"
	local dest_file="$HOME/.config/$1"

	if [[ ! -f "$src_file" ]]; then
		echo "Source config file not found: $src_file"
		return 1
	fi

	mkdir -p "$(dirname "$dest_file")"

	if [[ -f "$dest_file" ]]; then
		backup_config "$src_file" "$dest_file"
	fi

	cp "$src_file" "$dest_file"
	echo "Copied $src_file -> $dest_file"
}

install_configs() {
	echo "Installing configurations..."

	local config_dirs=(
		"hypr"
		"waybar"
		"wofi"
		"ghostty"
		"btop"
		"tmux"
		"zsh"
		"git"
	)

	for dir in "${config_dirs[@]}"; do
		if [[ -d "$DOTFILES_PATH/config/$dir" ]]; then
			copy_config_dir "$dir"
		fi
	done

	echo "Configurations installed!"
}
