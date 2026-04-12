echo "Seed Thunar defaults (hide menu bar)"

dotfiles_path="${DOTFILES_PATH:-$HOME/.local/share/dotfilesv2}"
src="$dotfiles_path/config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
dest_dir="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
dest="$dest_dir/thunar.xml"

if [[ -f "$src" ]]; then
  mkdir -p "$dest_dir"
  cp "$src" "$dest"
fi
