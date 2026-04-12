echo "Normalize GTK config directories and remove broken symlinks"

dotfiles_path="${DOTFILES_PATH:-$HOME/.local/share/dotfilesv2}"

normalize_gtk_dir() {
  local dir_name="$1"
  local dest="$HOME/.config/$dir_name"
  local src="$dotfiles_path/config/$dir_name"
  local backup

  if [[ -L "$dest" ]]; then
    backup="$dest.backup.$(date +%s)"
    mv "$dest" "$backup"
    echo "Backed up symlink $dest -> $backup"
  fi

  mkdir -p "$dest"

  if [[ -d "$src" ]]; then
    cp -f "$src/gtk.css" "$dest/gtk.css"
  fi
}

normalize_gtk_dir "gtk-3.0"
normalize_gtk_dir "gtk-4.0"
