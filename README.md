# Dotfiles v2

Arch Linux + Hyprland dotfiles

## Installation

```bash
curl -sL https://raw.githubusercontent.com/mohak34/dotfilesv2/main/boot.sh | bash
```

## Update

```bash
dotfiles-update
```

## Customization

Hyprland config uses core/local structure:

- `~/.config/hypr/core/` - Default configs (updated automatically)
- `~/.config/hypr/local/` - Your overrides

Create files in local/ to override core settings.

## Thunar Minimal UI

- Thunar default preferences are shipped via `config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml`.
- Menu bar (`File/Edit/View`) is hidden by default.
- Minimal GTK styling is shipped in `config/gtk-3.0/gtk.css` and `config/gtk-4.0/gtk.css`.
