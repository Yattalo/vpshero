#!/usr/bin/env bash
#===============================================================================
# VPSHero - Emergency Disk Cleanup Script (PRODUCTION SAFE)
# Esegue pulizia Docker quando lo spazio disco supera la soglia critica
#
# IMPORTANTE: Questo script è progettato per essere SICURO con Dokploy.
# - NON elimina volumi in uso o con label Dokploy
# - Valida tutti gli input prima delle operazioni
# - Usa file locking per prevenire race conditions
#===============================================================================

set -euo pipefail

# Configurazione
EMERGENCY_THRESHOLD=85  # Soglia critica (%)
WARNING_THRESHOLD=80    # Soglia di warning (%)
LOG_FILE="/var/log/disk-emergency-cleanup.log"
LOCK_FILE="/var/run/disk-emergency-cleanup.lock"

# Webhook configurabile (supporta Telegram, Discord, Slack)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

#===============================================================================
# FUNZIONI DI LOGGING (con file locking)
#===============================================================================
log() {
    local message="$1"
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    # Usa flock per prevenire race conditions nei log
    {
        flock -w 5 200 || return 1
        echo "[$timestamp] $message" >> "$LOG_FILE"
        echo "[$timestamp] $message"
    } 200>>"$LOG_FILE.lock"
}

error() {
    local message="$1"
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    {
        flock -w 5 200 || return 1
        echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
        echo "[$timestamp] ERROR: $message" >&2
    } 200>>"$LOG_FILE.lock"
}

#===============================================================================
# FUNZIONE ALERT (Telegram, Discord, Slack)
#===============================================================================
send_alert() {
    local message="$1"
    local escaped_message

    log "ALERT: $message"

    # Escape caratteri speciali per JSON (previene injection)
    escaped_message=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | sed 's/\\n$//')

    # Telegram (metodo corretto con bot token e chat_id separati)
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        curl -s --max-time 10 -X POST \
            "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\":\"${TELEGRAM_CHAT_ID}\",\"text\":\"🚨 VPS Alert: ${escaped_message}\",\"parse_mode\":\"HTML\"}" \
            >/dev/null 2>&1 || log "Warning: Telegram notification failed"
    fi

    # Discord
    if [[ -n "$DISCORD_WEBHOOK" ]]; then
        curl -s --max-time 10 -X POST "$DISCORD_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"🚨 **VPS Disk Alert**\\n${escaped_message}\"}" \
            >/dev/null 2>&1 || log "Warning: Discord notification failed"
    fi

    # Slack
    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -s --max-time 10 -X POST "$SLACK_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"text\":\"🚨 VPS Disk Alert: ${escaped_message}\"}" \
            >/dev/null 2>&1 || log "Warning: Slack notification failed"
    fi
}

#===============================================================================
# FUNZIONE DISK USAGE (con validazione)
#===============================================================================
get_disk_usage() {
    local usage
    usage=$(df -P / 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}')

    # Validazione: deve essere un numero tra 0 e 100
    if [[ ! "$usage" =~ ^[0-9]+$ ]] || [[ "$usage" -lt 0 ]] || [[ "$usage" -gt 100 ]]; then
        error "Impossibile determinare disk usage (valore: '$usage')"
        echo "-1"
        return 1
    fi

    echo "$usage"
}

#===============================================================================
# CLEANUP DOCKER SICURO (protegge Dokploy)
#===============================================================================
cleanup_docker_safe() {
    log "Inizio cleanup Docker SICURO..."
    local errors=0

    # Step 1: Rimuovi container stopped (sicuro - non tocca container running)
    log "Step 1: Rimozione container stopped..."
    if ! docker container prune -f 2>/dev/null; then
        error "Errore container prune"
        ((errors++)) || true
    fi

    # Step 2: Rimuovi build cache vecchia di 7+ giorni (sicuro)
    log "Step 2: Rimozione build cache 7+ giorni..."
    if ! docker builder prune -f --filter "until=168h" 2>/dev/null; then
        error "Errore builder prune"
        ((errors++)) || true
    fi

    # Step 3: Rimuovi immagini non usate da 7+ giorni (sicuro)
    log "Step 3: Rimozione immagini non usate 7+ giorni..."
    if ! docker image prune -a -f --filter "until=168h" 2>/dev/null; then
        error "Errore image prune"
        ((errors++)) || true
    fi

    # Step 4: Rimuovi SOLO volumi orfani (dangling) ESCLUDENDO volumi Dokploy
    # IMPORTANTE: NON usare "docker volume prune -f" che eliminerebbe anche volumi Dokploy!
    log "Step 4: Rimozione volumi orfani (escludendo Dokploy)..."
    local dangling_volumes
    dangling_volumes=$(docker volume ls -qf dangling=true 2>/dev/null || echo "")

    if [[ -n "$dangling_volumes" ]]; then
        while IFS= read -r vol; do
            # Skip volumi che contengono pattern Dokploy/critici
            if [[ "$vol" == *"dokploy"* ]] || \
               [[ "$vol" == *"postgres"* ]] || \
               [[ "$vol" == *"traefik"* ]] || \
               [[ "$vol" == *"redis"* ]] || \
               [[ "$vol" == *"mysql"* ]] || \
               [[ "$vol" == *"mongo"* ]] || \
               [[ "$vol" == *"_data"* ]]; then
                log "  Skip volume protetto: $vol"
                continue
            fi

            log "  Rimozione volume orfano: $vol"
            docker volume rm "$vol" 2>/dev/null || log "  Warning: impossibile rimuovere $vol"
        done <<< "$dangling_volumes"
    else
        log "  Nessun volume orfano trovato"
    fi

    # Step 5: Rimuovi network non usate (sicuro)
    log "Step 5: Rimozione network non usate..."
    if ! docker network prune -f 2>/dev/null; then
        error "Errore network prune"
        ((errors++)) || true
    fi

    log "Cleanup Docker completato (errori: $errors)"
    return $errors
}

#===============================================================================
# CLEANUP AGGRESSIVO (solo se emergency cleanup non basta)
#===============================================================================
cleanup_aggressive() {
    log "ATTENZIONE: Inizio cleanup AGGRESSIVO..."
    send_alert "Cleanup aggressivo attivato! Disk usage critico."

    # Rimuovi TUTTE le immagini non usate (anche recenti) - PRESERVA container running
    log "Rimozione TUTTE le immagini non usate (preserva running)..."
    docker image prune -a -f 2>/dev/null || error "Errore aggressive image prune"

    # Rimuovi TUTTA la build cache
    log "Rimozione TUTTA la build cache..."
    docker builder prune -a -f 2>/dev/null || error "Errore aggressive builder prune"

    # Cleanup log compressi vecchi (NON log attivi, NO symlink traversal)
    log "Rimozione log compressi vecchi di 14+ giorni..."
    find /var/log -P -type f \( -name "*.gz" -o -name "*.xz" -o -name "*.[0-9]" \) -mtime +14 -delete 2>/dev/null || true

    # Cleanup journal systemd (sicuro)
    log "Vacuum journal systemd (max 500M)..."
    journalctl --vacuum-size=500M 2>/dev/null || true
}

#===============================================================================
# MAIN LOGIC (con file locking per prevenire esecuzioni concorrenti)
#===============================================================================
main() {
    # Acquisici lock esclusivo (previene esecuzioni concorrenti)
    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        echo "Altra istanza già in esecuzione, skip"
        exit 0
    fi

    log "=== Disk Emergency Cleanup Service Start ==="

    # Ottieni utilizzo corrente (con validazione)
    local current_usage
    current_usage=$(get_disk_usage)

    if [[ "$current_usage" -eq -1 ]]; then
        error "Impossibile determinare disk usage, abort"
        exit 1
    fi

    log "Utilizzo disco corrente: $current_usage%"

    # Verifica soglie
    if [[ "$current_usage" -ge "$EMERGENCY_THRESHOLD" ]]; then
        send_alert "Disk usage CRITICO: ${current_usage}% (soglia: ${EMERGENCY_THRESHOLD}%)"

        # Esegui cleanup standard
        cleanup_docker_safe || true

        # Verifica se basta
        current_usage=$(get_disk_usage)
        if [[ "$current_usage" -eq -1 ]]; then
            error "Impossibile verificare disk usage post-cleanup"
            exit 1
        fi

        log "Disk usage dopo cleanup: $current_usage%"

        # Se ancora sopra soglia, cleanup aggressivo
        if [[ "$current_usage" -ge "$EMERGENCY_THRESHOLD" ]]; then
            cleanup_aggressive

            # Ultimo check
            current_usage=$(get_disk_usage)
            if [[ "$current_usage" -eq -1 ]]; then
                error "Impossibile verificare disk usage finale"
                exit 1
            fi

            log "Disk usage finale: $current_usage%"

            if [[ "$current_usage" -ge "$EMERGENCY_THRESHOLD" ]]; then
                send_alert "CRITICO: Cleanup aggressivo NON sufficiente. Disk: ${current_usage}%. AZIONE MANUALE RICHIESTA!"
                exit 1
            else
                send_alert "Cleanup completato. Disk usage: ${current_usage}%"
            fi
        else
            send_alert "Cleanup completato. Disk usage: ${current_usage}%"
        fi

    elif [[ "$current_usage" -ge "$WARNING_THRESHOLD" ]]; then
        log "Warning: Disk usage a ${current_usage}% (soglia warning: ${WARNING_THRESHOLD}%)"
        log "Eseguo cleanup preventivo..."
        cleanup_docker_safe || true

        current_usage=$(get_disk_usage)
        log "Disk usage dopo cleanup preventivo: $current_usage%"

    else
        log "Disk usage OK: ${current_usage}% (sotto soglia warning ${WARNING_THRESHOLD}%)"
    fi

    log "=== Disk Emergency Cleanup Service End ==="
}

# Esecuzione
main "$@"
