#===============================================================================
# VPSHero - Zsh Configuration
# Ottimizzato per DevOps con Claude Code
#===============================================================================

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme (disabilitato - usiamo Starship)
ZSH_THEME=""

# Plugins
plugins=(
    git
    docker
    docker-compose
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    sudo
    history
    command-not-found
    colored-man-pages
    extract
)

# Oh My Zsh
source $ZSH/oh-my-zsh.sh

#===============================================================================
# STARSHIP PROMPT
#===============================================================================
eval "$(starship init zsh)"

#===============================================================================
# ENVIRONMENT VARIABLES
#===============================================================================
export EDITOR='nano'
export VISUAL='nano'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/scripts:$PATH"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

#===============================================================================
# ZOXIDE (Smart cd)
#===============================================================================
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

#===============================================================================
# FZF Configuration
#===============================================================================
if command -v fzf &> /dev/null; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # Use fd for fzf if available
    if command -v fdfind &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview-window=right:50%'
fi

#===============================================================================
# MODERN CLI ALIASES
#===============================================================================

# eza (ls replacement)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=3 --icons -a'
    alias l='eza -l --icons'
else
    alias ll='ls -lah'
    alias l='ls -l'
fi

# bat (cat replacement)
if command -v batcat &> /dev/null; then
    alias cat='batcat --style=auto'
    alias bat='batcat'
elif command -v bat &> /dev/null; then
    alias cat='bat --style=auto'
fi

# fd (find replacement)
if command -v fdfind &> /dev/null; then
    alias find='fdfind'
    alias fd='fdfind'
fi

# ripgrep
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

#===============================================================================
# DOCKER ALIASES
#===============================================================================
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f'
alias dexec='docker exec -it'
alias dstop='docker stop $(docker ps -q)'
alias dprune='docker system prune -af'
alias dim='docker images'
alias dvol='docker volume ls'
alias dnet='docker network ls'

# lazydocker
if command -v lazydocker &> /dev/null; then
    alias ld='lazydocker'
fi

#===============================================================================
# GIT ALIASES
#===============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git pull'
alias gpush='git push'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gl='git log --oneline -10'
alias glog='git log --graph --oneline --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gf='git fetch --all'

# lazygit
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi

#===============================================================================
# GITHUB CLI ALIASES
#===============================================================================
alias ghpr='gh pr list'
alias ghprc='gh pr create'
alias ghprv='gh pr view'
alias ghprm='gh pr merge'
alias ghprd='gh pr diff'
alias ghi='gh issue list'
alias ghic='gh issue create'
alias ghiv='gh issue view'
alias ghw='gh workflow list'
alias ghwr='gh workflow run'
alias ghwv='gh run view'
alias ghwl='gh run list'

#===============================================================================
# SYSTEM ALIASES
#===============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'

# Monitoring
alias top='btop'
alias htop='btop'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

#===============================================================================
# SERVICE MANAGEMENT
#===============================================================================
alias sctl='sudo systemctl'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias sstatus='sudo systemctl status'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'
alias slogs='sudo journalctl -fu'

#===============================================================================
# CLAUDE CODE ALIASES
#===============================================================================
alias cc='claude'
alias ccp='claude -p'  # Print mode
alias ccr='claude --resume'  # Resume session
alias ccc='claude --continue'  # Continue last session

#===============================================================================
# CUSTOM FUNCTIONS
#===============================================================================

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Find process by name
psfind() {
    ps aux | grep -v grep | grep -i "$1"
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Docker shell
dsh() {
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

# View container logs with tail
dtail() {
    docker logs -f --tail="${2:-100}" "$1"
}

# Quick git commit and push
gcp() {
    git add --all && git commit -m "$1" && git push
}

# System health check
health() {
    echo "=== System Health ==="
    echo ""
    echo "Uptime: $(uptime)"
    echo ""
    echo "Memory:"
    free -h | head -2
    echo ""
    echo "Disk:"
    df -h / | tail -1
    echo ""
    echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo ""
    echo "Docker Containers: $(docker ps -q 2>/dev/null | wc -l) running"
    echo ""
    echo "Top 5 Memory Processes:"
    ps aux --sort=-%mem | head -6
}

# Deploy helper (wrapper for Claude)
deploy() {
    if [ -z "$1" ]; then
        echo "Usage: deploy <app-name> [environment]"
        return 1
    fi
    claude -p "/deploy $1 ${2:-production}"
}

# Quick rollback (wrapper for Claude)
rollback() {
    if [ -z "$1" ]; then
        echo "Usage: rollback <app-name> [version]"
        return 1
    fi
    claude -p "/rollback $1 $2"
}

#===============================================================================
# STARTUP
#===============================================================================

# Show quick system info on login
if [ -z "$TMUX" ]; then
    echo ""
    echo "Welcome to $(hostname)"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Load: $(cat /proc/loadavg | awk '{print $1}') | Memory: $(free | awk '/Mem/ {printf "%.0f%%", $3/$2*100}')"
    echo ""
fi
