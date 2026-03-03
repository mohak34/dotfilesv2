# Dotfiles v2 - Development Guide

## Overview
Dotfiles v2 is a multi-user friendly dotfiles system for Arch Linux + Hyprland. Designed to be installed by anyone, not just the original author.

## Core Principles

1. **Multi-User Friendly**: Works for anyone, not just the author's specific hardware
2. **Hardware Detection**: Auto-detect hardware (NVIDIA, ASUS, etc.) with user confirmation
3. **Non-Destructive**: Always backup existing configs before overwriting
4. **Updateable**: Users can receive updates via omarchy-style update mechanism
5. **Modular**: Each phase is independent and can be fine-tuned

## Code Style

### Bash Conventions
- Shebang: `#!/bin/bash` (never `#!/usr/bin/env bash`)
- Strict mode: `set -euo pipefail` at start of all scripts
- Indentation: 2 spaces, no tabs
- Conditionals: 
  - Use `[[ ]]` for string/file tests
  - Use `(( ))` for numeric tests
  - Prefer `(( count < 50 ))` over `[[ $count -lt 50 ]]`
- Quoting:
  - Quote string literals when comparing: `[[ $branch == "dev" ]]`
  - Don't quote variables inside `[[ ]]`
  - Always quote paths/variables with spaces: `"$HOME/My Documents"`
- Functions: Use `snake_case`
- Variables:
  - `UPPER_CASE` for exports/constants
  - `lower_case` for local variables

### Gum Usage
Use Gum for all user interaction:
- `gum spin` - Long-running operations with progress
- `gum confirm` - Yes/no prompts
- `gum choose` - Selection menus
- `gum input` - Text input
- `gum style` - Styled output
- `gum log` - Logging with levels (info, warn, error, debug)

## Command Naming Convention

All commands prefixed with `dotfiles-`:

### Core Commands
- `dotfiles-update` - Update to latest version from git
- `dotfiles-version` - Show version and installation status
- `dotfiles-refresh-config <path>` - Refresh specific config from defaults
- `dotfiles-migrate` - Run pending migrations

### Helper Commands (Internal)
- `dotfiles-cmd-missing <cmd>` - Check if command missing
- `dotfiles-cmd-present <cmd>` - Check if command exists
- `dotfiles-pkg-missing <pkg>` - Check if package missing
- `dotfiles-pkg-present <pkg>` - Check if package installed
- `dotfiles-pkg-add <pkg>` - Install package (pacman or AUR)
- `dotfiles-hw-nvidia` - Detect NVIDIA GPU
- `dotfiles-hw-asus` - Detect ASUS hardware
- `dotfiles-hw-laptop` - Detect if system is laptop

### Theme Commands
- `dotfiles-theme-list` - List available themes
- `dotfiles-theme-apply <name>` - Apply theme
- `dotfiles-theme-current` - Show current theme

## Hardware Detection

Always detect hardware but ask user before installing specific drivers:

```bash
# Example hardware detection flow
if dotfiles-hw-nvidia; then
  if gum confirm "NVIDIA GPU detected. Install NVIDIA drivers?"; then
    install_nvidia=true
  fi
fi

if dotfiles-hw-asus; then
  if gum confirm "ASUS hardware detected. Install ASUS tools (asusctl, supergfxctl)?"; then
    install_asus=true
  fi
fi
```

## Update Mechanism (Omarchy-Style)

Users update via `dotfiles-update` command which:
1. Checks for updates in git repository
2. Pulls latest changes
3. Runs migrations if needed
4. Refreshes configs that haven't been locally modified

### Migration System
- Migrations are timestamped scripts in `migrations/`
- Run automatically during update
- Only run once per installation
- Format: No shebang, start with echo describing action

Example migration:
```bash
echo "Update hyprland config for new version"

# Migration logic here
if [[ -f ~/.config/hypr/hyprland.conf ]]; then
  sed -i 's/old_setting/new_setting/' ~/.config/hypr/hyprland.conf
fi
```

## Configuration Management

### Default Configs
- Stored in `config/` directory
- Copied to `~/.config/` during install
- Never modify directly in `~/.config/` during updates if user has customized

### User Overrides
- Templates in `default/` directory
- User customizes in `~/.config/dotfiles/local/`
- Not overwritten during updates

### Refresh Pattern
```bash
dotfiles-refresh-config hypr/hyprland.conf
```
This copies from `config/hypr/hyprland.conf` to `~/.config/hypr/hyprland.conf` with backup.

## Installation Phases

### Phase 1: Bootstrap
- `boot.sh` - Downloaded via curl, clones repo, runs install.sh
- Detects if already installed (update vs fresh install)

### Phase 2: Preflight
- Check Arch Linux
- Check internet connectivity
- Check disk space
- Detect hardware

### Phase 3: Dependencies
- Install base packages (git, curl, gum, etc.)
- Install AUR helper (yay)
- Install development tools (go, rust, node, bun, uv)

### Phase 4: Core System
- Install Hyprland stack
- Install applications (ghostty, btop, etc.)
- Install optional hardware-specific packages

### Phase 5: Configuration
- Deploy configs to `~/.config/`
- Setup shell (zsh, tmux)
- Enable services

### Phase 6: Themes
- Install themes
- Apply default theme
- Setup wallpapers

### Phase 7: Finalize
- Post-install messages
- Next steps for user
- Reboot recommendation

## Safety Rules

1. **Never execute system-modifying commands without user confirmation**
2. **Always backup before overwriting**: `cp -r ~/.config/app ~/.config/app.backup.$(date +%s)`
3. **Check if already installed** before reinstalling
4. **Use dry-run mode** for testing: `./install.sh --dry-run`
5. **Validate configs** before applying (e.g., `hyprctl reload` test)

## Package Lists

Keep package lists in separate `.txt` files:
- `packages/base.txt` - Essential packages
- `packages/hyprland.txt` - Hyprland stack
- `packages/dev.txt` - Development tools
- `packages/asus.txt` - ASUS-specific packages (optional)
- `packages/nvidia.txt` - NVIDIA packages (optional)

Format: One package per line, comments start with `#`

## Testing Checklist

Before committing changes:
- [ ] Run `bash -n` on all modified scripts
- [ ] Test install in clean VM
- [ ] Test update from previous version
- [ ] Verify hardware detection works
- [ ] Check that user configs aren't overwritten
- [ ] Validate all gum prompts display correctly

## Multi-User Considerations

1. **No hardcoded paths** - Use `$HOME` not `/home/username`
2. **No user-specific configs** - Don't include personal API keys, git config with name/email
3. **Optional components** - Everything optional should be selectable
4. **Clear documentation** - Users need to know what will be installed
5. **Easy uninstall** - Provide uninstall script or instructions

## File Organization

```
dotfilesv2/
├── AGENTS.md                  # This file
├── README.md                  # User-facing documentation
├── boot.sh                    # Bootstrap installer
├── install.sh                 # Main installer entry point
├── update.sh                  # Update mechanism
├── version                    # Version number
│
├── install/                   # Installation modules
│   ├── helpers/              # Shared functions
│   ├── preflight/            # System checks
│   ├── packaging/            # Package installation
│   ├── config/               # Config deployment
│   ├── themes/               # Theme installation
│   └── post-install/         # Finalization
│
├── config/                    # Default configurations
│   ├── hypr/
│   ├── waybar/
│   ├── ghostty/
│   └── ...
│
├── bin/                       # Utility commands
│   ├── dotfiles-update
│   ├── dotfiles-version
│   └── ...
│
├── themes/                    # Theme definitions
├── wallpapers/                # Default wallpapers
├── packages/                  # Package lists (.txt files)
├── migrations/                # Update migrations
└── default/                   # User override templates
```

## Commit Messages

Follow conventional commits:
- `feat: add NVIDIA hardware detection`
- `fix: backup existing configs before overwrite`
- `docs: update installation instructions`
- `refactor: simplify package installation logic`

## Questions?

When in doubt:
1. Check how omarchy does it
2. Make it optional and ask the user
3. Document the behavior
4. Test on a clean system
