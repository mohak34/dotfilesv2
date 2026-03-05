#!/bin/bash
# post-install finalize script
# Shows completion message and next steps

echo "Generating initial color scheme..."
DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/defaultwallpaper.jpg"
if command -v matugen >/dev/null 2>&1 && [[ -f "$DEFAULT_WALLPAPER" ]]; then
  matugen image -t scheme-tonal-spot "$DEFAULT_WALLPAPER"
  echo "Color scheme generated."
else
  echo "matugen not found or wallpaper missing, skipping color generation."
fi

echo ""
echo "============================================"
echo "       Dotfiles Installation Complete!     "
echo "============================================"
echo ""
echo "Next steps:"
echo ""
echo "  1. Reboot your system:"
echo "     sudo reboot"
echo ""
echo "  2. After reboot, login with Hyprland"
echo ""
echo "  3. Your configurations:"
echo "     - Hyprland: ~/.config/hypr/"
echo "       (core/ = defaults, local/ = your overrides)"
echo "     - QuickShell: ~/.config/quickshell/"
echo "     - Ghostty: ~/.config/ghostty/"
echo "     - Scripts: ~/.local/bin/scripts/"
echo ""
echo "  4. To update dotfiles later:"
echo "     dotfiles-update"
echo ""
echo "  5. To check version:"
echo "     dotfiles-version"
echo ""
echo "============================================"
echo ""
