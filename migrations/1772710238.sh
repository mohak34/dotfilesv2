echo "Example migration: Ensure scripts are executable"

SCRIPTS_DIR="$HOME/.local/bin/scripts"

if [[ -d "$SCRIPTS_DIR" ]]; then
  for script in "$SCRIPTS_DIR"/*.sh; do
    [[ -f "$script" ]] || continue
    chmod +x "$script" 2>/dev/null || true
  done
fi
