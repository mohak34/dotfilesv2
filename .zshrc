#If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/cuda/bin:$PATH"
export TF_CUDA_LIBDEVICE=/opt/cuda/nvvm/libdevice
export CUDA_DIR=/opt/cuda
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
export XLA_FLAGS=--xla_gpu_cuda_data_dir=/opt/cuda
export EDITOR=nvim
export VISUAL=nvim
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland


ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking

plugins=(git)


# Auto-start tmux or attach to existing session
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    # Check if there are any tmux sessions
    tmux has-session &> /dev/null
    if [ $? -eq 0 ]; then
        # Attach to existing session
        tmux attach
    else
        # Create a new session
        tmux
    fi
fi

source $ZSH/oh-my-zsh.sh

# Aliases
alias pacup="sudo pacman -Syu --noconfirm --needed"
alias yayup="yay -Syu --noconfirm --needed"
alias pacin="sudo pacman -S --noconfirm --needed"
alias yayin="yay -S --noconfirm --needed"
alias pacrm="sudo pacman -R"
alias yayrm="yay -R"
alias pacrmf="sudo pacman -Rns"
alias yayrmf="yay -Rns"
alias psec="pacman -Ss"
alias ysec="yay -Ss"
alias conf="cd; cd ~/.config/"
alias proj="cd; cd ~/Workspace/Projects/"
alias work="cd; cd ~/Workspace/"
alias down="cd; cd ~/Downloads/"
alias ta="tmux a"
alias tks="tmux kill-server"
alias eza="eza --long --git --tree --level=2 --no-permissions --no-user --color=always --icons=always"
alias vdl="yt-dlp -r, --limit-rate 20M"
alias gac="git add .; git commit -m "
alias gpm="git push -u origin main"
alias spo="spotify_player"
alias wcon="warp-cli connect"
alias wdis="warp-cli disconnect"
alias wstat="warp-cli status"
alias lg="lazygit"
alias oc="OPENCODE_EXPERIMENTAL=1 opencode"

# LLM Proxy management (fallback)
alias proxy-start='tmux new-session -d -s llm-proxy -c ~/Workspace/Projects/LLM-API-Key-Proxy \
    "uv run python src/proxy_app/main.py --host 127.0.0.1 --port 8000" \; \
    split-window -h -t llm-proxy -c ~/Workspace/Projects/LLM-API-Key-Proxy \
    "sleep 2 && uv run python -m src.proxy_app.quota_viewer" \; \
    select-pane -t llm-proxy:0.0 \
    && echo "Proxy started! Use Ctrl+S,a to view"'

alias proxy-stop='tmux kill-session -t llm-proxy 2>/dev/null && echo "Proxy stopped" || echo "Proxy not running"'

alias proxy-restart='tmux kill-session -t llm-proxy 2>/dev/null; sleep 1; \
    tmux new-session -d -s llm-proxy -c ~/Workspace/Projects/LLM-API-Key-Proxy \
    "uv run python src/proxy_app/main.py --host 127.0.0.1 --port 8000" \; \
    split-window -h -t llm-proxy -c ~/Workspace/Projects/LLM-API-Key-Proxy \
    "sleep 2 && uv run python -m src.proxy_app.quota_viewer" \; \
    select-pane -t llm-proxy:0.0 \
    && echo "Proxy restarted!"'

alias proxy-attach='tmux attach -t llm-proxy 2>/dev/null || echo "Proxy not running. Use proxy-start first"'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


eval "$(fzf --zsh)"

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"




# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export GEM_HOME="$(gem env user_gemhome)"
export PATH="$PATH:$GEM_HOME/bin"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]


# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

eval "$(zoxide init --cmd cd zsh)"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# Rust
[ -f "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"

# Dotfiles v2
export DOTFILES_PATH="$HOME/.local/share/dotfilesv2"
export PATH="$DOTFILES_PATH/bin:$PATH"
