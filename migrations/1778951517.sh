echo "Remove old hyprlang .conf files replaced by .lua equivalents"

hypr_dir="$HOME/.config/hypr"

# Remove old top-level .conf files (now .lua)
rm -f "$hypr_dir/hyprland.conf"
rm -f "$hypr_dir/colors.conf"
rm -f "$hypr_dir/nvidia.conf"
rm -f "$hypr_dir/asus.conf"

# Remove old core/ .conf files (now .lua)
if [[ -d "$hypr_dir/core" ]]; then
  rm -f "$hypr_dir/core/"*.conf
fi

# Remove old local/ .conf files (now .lua)
if [[ -d "$hypr_dir/local" ]]; then
  rm -f "$hypr_dir/local/"*.conf
fi

# Remove old modules/ dir from early Lua migration if it exists
if [[ -d "$hypr_dir/modules" ]]; then
  echo "Found old modules/ directory — renaming to modules.migrated/ for backup"
  mv "$hypr_dir/modules" "$hypr_dir/modules.migrated.$(date +%s)"
fi
