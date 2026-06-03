echo "Migrate hyprland config from .conf to .lua"

dotfiles_path="${DOTFILES_PATH:-$HOME/.local/share/dotfilesv2}"
hypr_dir="$HOME/.config/hypr"
src="$dotfiles_path/config/hypr"

# Remove old .conf files (replaced by .lua)
rm -f "$hypr_dir/hyprland.conf"
rm -f "$hypr_dir/colors.conf"
rm -f "$hypr_dir/nvidia.conf"
rm -f "$hypr_dir/asus.conf"
rm -f "$hypr_dir/core/"*.conf
rm -f "$hypr_dir/local/"*.conf

# Remove old modules/ dir from early manual Lua migration if it exists
if [[ -d "$hypr_dir/modules" ]]; then
  echo "Backing up old modules/ -> modules.migrated/"
  mv "$hypr_dir/modules" "$hypr_dir/modules.migrated.$(date +%s)"
fi

# Copy new .lua core modules
mkdir -p "$hypr_dir/core"
for f in "$src"/core/*.lua; do
  [[ -f "$f" ]] || continue
  cp "$f" "$hypr_dir/core/"
done

# Copy top-level .lua + .conf files
cp "$src/hyprland.lua" "$hypr_dir/"
cp "$src/hypridle.conf" "$hypr_dir/"
cp "$src/hyprlock.conf" "$hypr_dir/"
cp "$src/nvidia.lua" "$hypr_dir/"
cp "$src/colors.lua" "$hypr_dir/"

if [[ -f "$HOME/.config/.dotfiles-install-asus" ]]; then
  cp "$src/asus.lua" "$hypr_dir/"
else
  : > "$hypr_dir/asus.lua"
fi

# Create dummy .conf stubs in the repo dir so the old copy_hypr_core_only()
# (still running from old dotfiles-update in memory) doesn't crash on set -e
for f in hyprland.conf colors.conf nvidia.conf asus.conf; do
  touch "$dotfiles_path/config/hypr/$f"
done
