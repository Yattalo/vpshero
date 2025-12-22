#!/usr/bin/env bash
#===============================================================================
# VPSHero - Weekly Docker Cleanup (Preventivo, PRODUCTION SAFE)
# Esegue pulizia conservativa ogni settimana per prevenire accumulo
#
# IMPORTANTE: Sicuro per Dokploy - NON elimina volumi critici
#===============================================================================

set -euo pipefail

LOG_FILE="/var/log/docker-weekly-cleanup.log"
LOCK_FILE="/var/run/docker-weekly-cleanup.lock"

# Imposta PATH esplicito per cron (cron ha PATH minimale)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

log() {
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    {
        flock -w 5 200 || return 1
        echo "[$timestamp] $1" >> "$LOG_FILE"
        echo "[$timestamp] $1"
    } 200>>"$LOG_FILE.lock"
}

error() {
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"

    {
        flock -w 5 200 || return 1
        echo "[$timestamp] ERROR: $1" >> "$LOG_FILE"
        echo "[$timestamp] ERROR: $1" >&2
    } 200>>"$LOG_FILE.lock"
}

main() {
    # Lock esclusivo
    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        echo "Altra istanza già in esecuzione, skip"
        exit 0
    fi

    log "=== Weekly Docker Cleanup Start ==="

    # Disk usage prima del cleanup (con validazione)
    local before after saved
    before=$(df -P / 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}')

    if [[ ! "$before" =~ ^[0-9]+$ ]]; then
        error "Impossibile determinare disk usage"
        exit 1
    fi

    log "Disk usage PRIMA: $before%"

    # Cleanup conservativo (solo risorse vecchie)
    log "Rimozione container stopped..."
    docker container prune -f 2>/dev/null || error "Errore container prune"

    log "Rimozione build cache 7+ giorni..."
    docker builder prune -f --filter "until=168h" 2>/dev/null || error "Errore builder prune"

    log "Rimozione immagini non usate 7+ giorni..."
    docker image prune -a -f --filter "until=168h" 2>/dev/null || error "Errore image prune"

    # SICURO: Rimuovi SOLO volumi dangling, escludendo volumi critici
    log "Rimozione volumi orfani (escludendo Dokploy/database)..."
    local dangling_volumes
    dangling_volumes=$(docker volume ls -qf dangling=true 2>/dev/null || echo "")

    if [[ -n "$dangling_volumes" ]]; then
        while IFS= read -r vol; do
            # Skip volumi critici
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

            log "  Rimozione volume: $vol"
            docker volume rm "$vol" 2>/dev/null || log "  Warning: impossibile rimuovere $vol"
        done <<< "$dangling_volumes"
    fi

    log "Rimozione network non usate..."
    docker network prune -f 2>/dev/null || error "Errore network prune"

    # Disk usage dopo il cleanup (con validazione)
    after=$(df -P / 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5}')

    if [[ ! "$after" =~ ^[0-9]+$ ]]; then
        error "Impossibile determinare disk usage post-cleanup"
        after="$before"
    fi

    # Calcola spazio recuperato (con bounds check)
    if [[ "$before" -ge "$after" ]]; then
        saved=$((before - after))
    else
        saved=0
        log "Note: Disk usage aumentato durante cleanup (scritture concorrenti)"
    fi

    log "Disk usage DOPO: $after%"
    log "Spazio recuperato: ${saved}%"

    # Report
    log "Docker disk usage report:"
    docker system df 2>/dev/null | while IFS= read -r line; do
        log "  $line"
    done

    log "=== Weekly Docker Cleanup End ==="
}

main "$@"
