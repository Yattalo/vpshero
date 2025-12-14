#!/bin/bash
#===============================================================================
# VPSHero - Setup Script per VPS Ubuntu 24.04 LTS
# Ecosistema DevOps Avanzato con Claude Code come Cervello Centrale
#===============================================================================

set -e

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
header() { echo -e "\n${PURPLE}══════════════════════════════════════════════════════════════${NC}"; echo -e "${PURPLE}  $1${NC}"; echo -e "${PURPLE}══════════════════════════════════════════════════════════════${NC}\n"; }

# Verifica root
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        error "Non eseguire come root! Usa un utente con sudo."
    fi
}

# Verifica Ubuntu
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        error "Questo script richiede Ubuntu"
    fi
    log "Sistema operativo: $(lsb_release -d | cut -f2)"
}

#===============================================================================
# FASE 1: AGGIORNAMENTO SISTEMA
#===============================================================================
update_system() {
    header "FASE 1: Aggiornamento Sistema"

    log "Aggiornamento repository..."
    sudo apt update

    log "Aggiornamento pacchetti..."
    sudo apt upgrade -y

    log "Installazione pacchetti essenziali..."
    sudo apt install -y \
        curl wget git vim nano \
        build-essential \
        unzip zip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg lsb-release

    log "Sistema aggiornato!"
}

#===============================================================================
# FASE 2: SICUREZZA BASE
#===============================================================================
setup_security() {
    header "FASE 2: Configurazione Sicurezza"

    # Fail2ban
    log "Installazione Fail2ban..."
    sudo apt install -y fail2ban

    # Configurazione Fail2ban
    sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 3
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

    sudo systemctl enable fail2ban
    sudo systemctl restart fail2ban
    log "Fail2ban configurato!"

    # UFW
    log "Configurazione firewall UFW..."
    sudo apt install -y ufw

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh comment 'SSH'
    sudo ufw allow 80/tcp comment 'HTTP'
    sudo ufw allow 443/tcp comment 'HTTPS'
    sudo ufw allow 3000/tcp comment 'Dokploy Dashboard'

    # Abilita UFW (non-interactive)
    echo "y" | sudo ufw enable
    log "Firewall UFW attivato!"

    sudo ufw status verbose

    # Unattended upgrades
    log "Configurazione aggiornamenti automatici..."
    sudo apt install -y unattended-upgrades
    sudo dpkg-reconfigure -plow unattended-upgrades

    log "Sicurezza base configurata!"
}

#===============================================================================
# FASE 3: ZSH + OH MY ZSH + STARSHIP
#===============================================================================
setup_shell() {
    header "FASE 3: Shell Avanzata"

    # Zsh
    log "Installazione Zsh..."
    sudo apt install -y zsh

    # Oh My Zsh (non-interactive)
    log "Installazione Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        warn "Oh My Zsh già installato"
    fi

    # Plugin Zsh
    log "Installazione plugin Zsh..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    fi

    # Starship
    log "Installazione Starship..."
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        warn "Starship già installato"
    fi

    log "Shell avanzata configurata!"
}

#===============================================================================
# FASE 4: STRUMENTI CLI MODERNI
#===============================================================================
setup_cli_tools() {
    header "FASE 4: Strumenti CLI Moderni"

    # Pacchetti da apt
    log "Installazione strumenti da apt..."
    sudo apt install -y \
        ripgrep \
        fd-find \
        bat \
        fzf \
        htop \
        btop \
        ncdu \
        tree \
        jq \
        httpie \
        tldr \
        tmux \
        git-delta

    # eza (ls moderno)
    log "Installazione eza..."
    if ! command -v eza &> /dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # zoxide (cd intelligente)
    log "Installazione zoxide..."
    if ! command -v zoxide &> /dev/null; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # lazygit
    log "Installazione lazygit..."
    if ! command -v lazygit &> /dev/null; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit.tar.gz lazygit
    fi

    # lazydocker
    log "Installazione lazydocker..."
    if ! command -v lazydocker &> /dev/null; then
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi

    log "Strumenti CLI installati!"
}

#===============================================================================
# FASE 5: GITHUB CLI
#===============================================================================
setup_github_cli() {
    header "FASE 5: GitHub CLI"

    log "Installazione GitHub CLI..."
    if ! command -v gh &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    fi

    info "Per autenticarsi eseguire: gh auth login"
    log "GitHub CLI installato!"
}

#===============================================================================
# FASE 6: NODE.JS
#===============================================================================
setup_nodejs() {
    header "FASE 6: Node.js 20.x"

    log "Installazione Node.js 20.x..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
    fi

    # npm global senza sudo
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'

    log "Node.js $(node --version) installato!"
    log "npm $(npm --version)"
}

#===============================================================================
# FASE 7: DOKPLOY
#===============================================================================
setup_dokploy() {
    header "FASE 7: Dokploy"

    log "Installazione Dokploy (include Docker)..."
    info "Questo processo richiede 3-5 minuti..."

    if ! command -v docker &> /dev/null; then
        curl -sSL https://dokploy.com/install.sh | sh
    else
        warn "Docker già presente. Installazione Dokploy standalone..."
        curl -sSL https://dokploy.com/install.sh | sh
    fi

    log "Dokploy installato!"
    info "Accedi a http://$(curl -s ifconfig.me):3000 per completare il setup"
}

#===============================================================================
# FASE 8: CLAUDE CODE
#===============================================================================
setup_claude_code() {
    header "FASE 8: Claude Code"

    log "Installazione Claude Code..."

    # Assicurati che npm global sia nel PATH
    export PATH="$HOME/.npm-global/bin:$PATH"

    if ! command -v claude &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
    fi

    log "Claude Code installato!"
    info "Per autenticarsi eseguire: claude"
}

#===============================================================================
# FASE 9: CONFIGURAZIONI
#===============================================================================
setup_configurations() {
    header "FASE 9: Configurazioni"

    # Directory
    log "Creazione directory..."
    mkdir -p ~/projects ~/logs ~/scripts ~/.config
    mkdir -p ~/.claude/{commands,agents,skills,hooks}

    # Copia configurazioni se presenti nella stessa directory dello script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$SCRIPT_DIR/configs/.zshrc" ]; then
        log "Copiando .zshrc..."
        cp "$SCRIPT_DIR/configs/.zshrc" ~/.zshrc
    fi

    if [ -f "$SCRIPT_DIR/configs/starship.toml" ]; then
        log "Copiando starship.toml..."
        cp "$SCRIPT_DIR/configs/starship.toml" ~/.config/starship.toml
    fi

    if [ -d "$SCRIPT_DIR/claude" ]; then
        log "Copiando configurazioni Claude Code..."
        cp -r "$SCRIPT_DIR/claude/"* ~/.claude/
        chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
        chmod +x ~/.claude/statusline-vps.sh 2>/dev/null || true
    fi

    log "Configurazioni applicate!"
}

#===============================================================================
# FASE 10: CAMBIO SHELL
#===============================================================================
change_shell() {
    header "FASE 10: Cambio Shell Predefinita"

    if [ "$SHELL" != "$(which zsh)" ]; then
        log "Impostazione Zsh come shell predefinita..."
        chsh -s "$(which zsh)"
        info "Shell cambiata. Effettua logout/login per applicare."
    else
        log "Zsh è già la shell predefinita"
    fi
}

#===============================================================================
# RIEPILOGO FINALE
#===============================================================================
print_summary() {
    header "SETUP COMPLETATO!"

    echo -e "${GREEN}Componenti installati:${NC}"
    echo "  - Zsh + Oh My Zsh + Starship"
    echo "  - Plugin: autosuggestions, syntax-highlighting, completions"
    echo "  - CLI tools: eza, bat, fd, rg, fzf, zoxide, lazygit, lazydocker, btop"
    echo "  - GitHub CLI"
    echo "  - Node.js $(node --version 2>/dev/null || echo 'N/A')"
    echo "  - Docker + Dokploy"
    echo "  - Claude Code"
    echo ""
    echo -e "${YELLOW}Prossimi passi:${NC}"
    echo "  1. Effettua logout e login per attivare Zsh"
    echo "  2. Accedi a http://$(curl -s ifconfig.me 2>/dev/null || echo '<IP>'):3000 per Dokploy"
    echo "  3. Esegui 'gh auth login' per GitHub CLI"
    echo "  4. Esegui 'claude' per autenticare Claude Code"
    echo "  5. Configura SSH hardening manualmente (vedi docs)"
    echo ""
    echo -e "${CYAN}Directory Claude Code:${NC}"
    echo "  ~/.claude/settings.json    - Configurazione principale"
    echo "  ~/.claude/commands/        - Slash commands"
    echo "  ~/.claude/agents/          - Agenti specializzati"
    echo "  ~/.claude/skills/          - Skills"
    echo "  ~/.claude/hooks/           - Hooks"
    echo ""
    echo -e "${GREEN}Buon lavoro con VPSHero!${NC}"
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   ██╗   ██╗██████╗ ███████╗██╗  ██╗███████╗██████╗  ██████╗   ║"
    echo "║   ██║   ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔══██╗██╔═══██╗  ║"
    echo "║   ██║   ██║██████╔╝███████╗███████║█████╗  ██████╔╝██║   ██║  ║"
    echo "║   ╚██╗ ██╔╝██╔═══╝ ╚════██║██╔══██║██╔══╝  ██╔══██╗██║   ██║  ║"
    echo "║    ╚████╔╝ ██║     ███████║██║  ██║███████╗██║  ██║╚██████╔╝  ║"
    echo "║     ╚═══╝  ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ║"
    echo "║                                                               ║"
    echo "║   VPS DevOps Avanzata con Claude Code                        ║"
    echo "║   Setup Script v1.0                                           ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    check_not_root
    check_ubuntu

    # Menu interattivo
    echo ""
    echo "Seleziona cosa installare:"
    echo "  1) Setup completo (raccomandato)"
    echo "  2) Solo sicurezza (UFW, Fail2ban)"
    echo "  3) Solo shell (Zsh, Oh My Zsh, Starship)"
    echo "  4) Solo CLI tools"
    echo "  5) Solo Dokploy"
    echo "  6) Solo Claude Code"
    echo "  7) Solo configurazioni Claude"
    echo ""
    read -p "Scelta [1-7]: " choice

    case $choice in
        1)
            update_system
            setup_security
            setup_shell
            setup_cli_tools
            setup_github_cli
            setup_nodejs
            setup_dokploy
            setup_claude_code
            setup_configurations
            change_shell
            print_summary
            ;;
        2)
            setup_security
            ;;
        3)
            setup_shell
            setup_configurations
            change_shell
            ;;
        4)
            setup_cli_tools
            ;;
        5)
            setup_dokploy
            ;;
        6)
            setup_nodejs
            setup_claude_code
            ;;
        7)
            setup_configurations
            ;;
        *)
            error "Scelta non valida"
            ;;
    esac

    log "Script terminato!"
}

# Esecuzione
main "$@"
