#!/usr/bin/env bash
#===============================================================================
# VPSHero - Verify Disk Safeguards Installation
# Verifica che tutti i componenti siano installati correttamente
#===============================================================================

set -euo pipefail

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

OK="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"

# Contatori
PASSED=0
FAILED=0
WARNINGS=0

check() {
    local description="$1"
    local command="$2"

    printf "%-60s" "$description"

    if eval "$command" &> /dev/null; then
        echo -e "$OK"
        ((PASSED++))
        return 0
    else
        echo -e "$FAIL"
        ((FAILED++))
        return 1
    fi
}

check_warn() {
    local description="$1"
    local command="$2"

    printf "%-60s" "$description"

    if eval "$command" &> /dev/null; then
        echo -e "$OK"
        ((PASSED++))
        return 0
    else
        echo -e "$WARN (opzionale)"
        ((WARNINGS++))
        return 1
    fi
}

header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

main() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     VPSHero - Disk Safeguards Verification               ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # 1. File Check
    header "1. Verifica File"

    check "Script emergency cleanup presente" \
          "[ -f /opt/scripts/disk-emergency-cleanup.sh ]"

    check "Script emergency cleanup eseguibile" \
          "[ -x /opt/scripts/disk-emergency-cleanup.sh ]"

    check "Script weekly cleanup presente" \
          "[ -f /opt/scripts/docker-weekly-cleanup.sh ]"

    check "Script weekly cleanup eseguibile" \
          "[ -x /opt/scripts/docker-weekly-cleanup.sh ]"

    check "File log creato" \
          "[ -f /var/log/disk-emergency-cleanup.log ]"

    # 2. Systemd Check
    header "2. Verifica Systemd"

    check "Service file presente" \
          "[ -f /etc/systemd/system/disk-emergency-cleanup.service ]"

    check "Timer file presente" \
          "[ -f /etc/systemd/system/disk-emergency-cleanup.timer ]"

    check "Timer abilitato (enabled)" \
          "systemctl is-enabled disk-emergency-cleanup.timer"

    check "Timer attivo (running)" \
          "systemctl is-active disk-emergency-cleanup.timer"

    # 3. Cron Check
    header "3. Verifica Cron Job"

    check "Cron weekly cleanup configurato" \
          "crontab -l 2>/dev/null | grep -q docker-weekly-cleanup.sh"

    # 4. Webhook Check (opzionale)
    header "4. Verifica Notifiche"

    check_warn "Webhook configurato" \
               "[ ! -z \"\$DISK_ALERT_WEBHOOK\" ]"

    # 5. Docker Check
    header "5. Verifica Docker"

    check "Docker installato" \
          "command -v docker"

    check "Docker daemon attivo" \
          "docker ps"

    # 6. Execution Test
    header "6. Test Esecuzione"

    echo "Esecuzione test script..."
    if sudo /opt/scripts/disk-emergency-cleanup.sh &> /tmp/verify-test.log; then
        echo -e "${OK} Script eseguito con successo"
        ((PASSED++))
    else
        echo -e "${FAIL} Script fallito - controllare /tmp/verify-test.log"
        ((FAILED++))
    fi

    # 7. Timer Schedule Check
    header "7. Verifica Schedule"

    echo "Prossime esecuzioni timer:"
    systemctl list-timers disk-emergency-cleanup.timer --no-pager | grep -v "^$"

    # 8. Log Check
    header "8. Ultimi Log"

    echo "Ultimi 5 eventi (da log file):"
    tail -5 /var/log/disk-emergency-cleanup.log 2>/dev/null || echo "Nessun log ancora"

    # Summary
    header "RIEPILOGO"

    TOTAL=$((PASSED + FAILED))

    echo -e "${GREEN}✓ Passed:${NC}    $PASSED"
    echo -e "${RED}✗ Failed:${NC}    $FAILED"
    echo -e "${YELLOW}⚠ Warnings:${NC}  $WARNINGS"
    echo ""

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║         ✓ INSTALLAZIONE COMPLETATA CON SUCCESSO!         ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Il sistema di safeguard è attivo e funzionante.${NC}"

        if [ $WARNINGS -gt 0 ]; then
            echo ""
            echo -e "${YELLOW}Nota:${NC} Alcune features opzionali non sono configurate (webhook)."
            echo "Puoi configurarle in seguito seguendo la guida in docs/STRATEGIA-PREVENZIONE-CRASH.md"
        fi

        echo ""
        echo -e "${CYAN}Comandi utili:${NC}"
        echo "  systemctl status disk-emergency-cleanup.timer  # Stato timer"
        echo "  journalctl -u disk-emergency-cleanup -f        # Log real-time"
        echo "  tail -f /var/log/disk-emergency-cleanup.log    # Log file"
        echo "  sudo /opt/scripts/disk-emergency-cleanup.sh    # Esecuzione manuale"
        echo ""

        exit 0
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║           ✗ INSTALLAZIONE INCOMPLETA O FALLITA           ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Azioni suggerite:${NC}"
        echo "  1. Riesegui: sudo ./setup-disk-safeguards.sh"
        echo "  2. Controlla errori sopra"
        echo "  3. Verifica log: tail -50 /var/log/disk-emergency-cleanup.log"
        echo "  4. Consulta troubleshooting: docs/DISK-SAFEGUARDS.md"
        echo ""

        exit 1
    fi
}

main "$@"
