#!/usr/bin/env bash
#===============================================================================
# VPSHero - Setup Disk Safeguards
# Installa sistema automatico di prevenzione crash da spazio disco
#
# USAGE: sudo ./setup-disk-safeguards.sh
#===============================================================================

set -euo pipefail

# Determina path assoluti (risolve il problema dei path relativi)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# Verifica permessi root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Questo script richiede permessi root. Esegui con: sudo $0"
    fi
}

# Verifica Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker non trovato. Installa Docker prima di eseguire questo script."
    fi

    if ! docker ps &> /dev/null; then
        error "Docker daemon non raggiungibile. Verifica che Docker sia in esecuzione."
    fi
}

# Verifica file sorgente esistono
check_source_files() {
    local missing=0

    if [[ ! -f "$SCRIPT_DIR/disk-emergency-cleanup.sh" ]]; then
        error "File non trovato: $SCRIPT_DIR/disk-emergency-cleanup.sh"
        ((missing++))
    fi

    if [[ ! -f "$SCRIPT_DIR/docker-weekly-cleanup.sh" ]]; then
        warn "File non trovato: $SCRIPT_DIR/docker-weekly-cleanup.sh (opzionale)"
    fi

    if [[ ! -f "$REPO_ROOT/configs/systemd/disk-emergency-cleanup.service" ]]; then
        error "File non trovato: $REPO_ROOT/configs/systemd/disk-emergency-cleanup.service"
        ((missing++))
    fi

    if [[ ! -f "$REPO_ROOT/configs/systemd/disk-emergency-cleanup.timer" ]]; then
        error "File non trovato: $REPO_ROOT/configs/systemd/disk-emergency-cleanup.timer"
        ((missing++))
    fi

    if [[ $missing -gt 0 ]]; then
        error "File sorgente mancanti. Assicurati di essere nella directory vpshero/scripts/"
    fi
}

main() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        VPSHero - Disk Safeguards Setup                    ║${NC}"
    echo -e "${CYAN}║        PRODUCTION SAFE - Protegge Dokploy                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"

    # Pre-flight checks
    check_root
    check_docker
    check_source_files

    log "Script directory: $SCRIPT_DIR"
    log "Repository root: $REPO_ROOT"

    # 1. Crea directory
    log "Creazione directory..."
    mkdir -p /opt/scripts
    mkdir -p /var/log
    mkdir -p /var/run

    # 2. Copia script con path assoluti
    log "Installazione script di cleanup..."

    # Emergency cleanup
    cp "$SCRIPT_DIR/disk-emergency-cleanup.sh" /opt/scripts/
    chmod +x /opt/scripts/disk-emergency-cleanup.sh
    log "✓ Script emergency cleanup installato"

    # Weekly cleanup (opzionale)
    if [[ -f "$SCRIPT_DIR/docker-weekly-cleanup.sh" ]]; then
        cp "$SCRIPT_DIR/docker-weekly-cleanup.sh" /opt/scripts/
        chmod +x /opt/scripts/docker-weekly-cleanup.sh
        log "✓ Script weekly cleanup installato"
    fi

    # Verify script (opzionale)
    if [[ -f "$SCRIPT_DIR/verify-disk-safeguards.sh" ]]; then
        cp "$SCRIPT_DIR/verify-disk-safeguards.sh" /opt/scripts/
        chmod +x /opt/scripts/verify-disk-safeguards.sh
        log "✓ Script verify installato"
    fi

    # 3. Setup systemd service e timer
    log "Configurazione systemd service e timer..."

    SYSTEMD_DIR="/etc/systemd/system"

    # Service (con path assoluti)
    cp "$REPO_ROOT/configs/systemd/disk-emergency-cleanup.service" "$SYSTEMD_DIR/"
    log "✓ Service file copiato"

    # Timer
    cp "$REPO_ROOT/configs/systemd/disk-emergency-cleanup.timer" "$SYSTEMD_DIR/"
    log "✓ Timer file copiato"

    # Reload systemd
    log "Ricaricamento systemd daemon..."
    systemctl daemon-reload

    # Ferma timer se già attivo (per idempotenza)
    if systemctl is-active --quiet disk-emergency-cleanup.timer 2>/dev/null; then
        log "Timer già attivo, riavvio..."
        systemctl stop disk-emergency-cleanup.timer
    fi

    # Abilita e avvia timer (idempotente)
    log "Abilitazione e avvio timer..."
    systemctl enable disk-emergency-cleanup.timer
    systemctl start disk-emergency-cleanup.timer

    # 4. Setup cron per weekly cleanup (domenica alle 3am)
    if [[ -f /opt/scripts/docker-weekly-cleanup.sh ]]; then
        log "Configurazione cron per weekly cleanup..."

        # PATH esplicito nel cron job
        CRON_JOB="0 3 * * 0 /opt/scripts/docker-weekly-cleanup.sh >> /var/log/docker-weekly-cleanup.log 2>&1"

        # Verifica se già esiste (idempotente)
        if ! crontab -l 2>/dev/null | grep -q "docker-weekly-cleanup.sh"; then
            (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
            log "✓ Cron job configurato"
        else
            warn "Cron job già esistente, skip"
        fi
    fi

    # 5. Setup logrotate
    log "Configurazione log rotation..."
    cat > /etc/logrotate.d/vpshero-cleanup << 'EOF'
/var/log/disk-emergency-cleanup.log
/var/log/docker-weekly-cleanup.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 644 root root
}
EOF
    log "✓ Logrotate configurato"

    # 6. Info webhook
    echo ""
    info "Per abilitare notifiche, aggiungi in /etc/environment:"
    info "  TELEGRAM_BOT_TOKEN='your-bot-token'"
    info "  TELEGRAM_CHAT_ID='your-chat-id'"
    info ""
    info "Oppure per Discord:"
    info "  DISCORD_WEBHOOK='https://discord.com/api/webhooks/...'"

    # 7. Test esecuzione (dry run - solo check, no cleanup)
    log "Test connettività Docker..."
    if docker ps &> /dev/null; then
        log "✓ Docker raggiungibile"
    else
        warn "Docker non raggiungibile, verifica permessi"
    fi

    # 8. Riepilogo
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║             Setup Completato con Successo!                ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${CYAN}Componenti installati:${NC}"
    echo "  ✓ Emergency cleanup service (ogni 30 minuti)"
    echo "  ✓ Weekly cleanup cron job (domenica 3am)"
    echo "  ✓ Logrotate per gestione log"
    echo "  ✓ Protezione volumi Dokploy/database attiva"
    echo ""

    echo -e "${CYAN}Comandi utili:${NC}"
    echo "  systemctl status disk-emergency-cleanup.timer  # Stato timer"
    echo "  journalctl -u disk-emergency-cleanup -f        # Log real-time"
    echo "  tail -f /var/log/disk-emergency-cleanup.log    # Log file"
    echo "  /opt/scripts/disk-emergency-cleanup.sh         # Esecuzione manuale"
    echo ""

    echo -e "${CYAN}Verifica configurazione:${NC}"
    systemctl status disk-emergency-cleanup.timer --no-pager || true

    echo ""
    echo -e "${GREEN}Protezione disco attiva! I volumi Dokploy sono protetti.${NC}"
}

main "$@"
