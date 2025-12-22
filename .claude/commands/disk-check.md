---
description: Controlla stato disco e Docker, suggerisce azioni
argument-hint: ""
allowed-tools: Bash(df:*), Bash(docker:*), Read
model: haiku
---

# Disk Check - Analisi Spazio Disco VPS

Questo comando analizza lo stato del disco VPS e fornisce suggerimenti operativi.

## Esecuzione

### 1. Utilizzo Disco Complessivo

!`df -h /`

### 2. Utilizzo Docker Dettagliato

!`docker system df -v`

### 3. Log Ultimi Cleanup

!`tail -20 /var/log/disk-emergency-cleanup.log 2>/dev/null || echo "Log non trovato - safeguard non installati?"`

### 4. Stato Timer Systemd

!`systemctl status disk-emergency-cleanup.timer --no-pager 2>/dev/null || echo "Timer non configurato"`

## Analisi e Suggerimenti

Basandoti sui dati sopra, fornisci:

1. **Stato corrente**:
   - Utilizzo disco in % e GB
   - Quanto spazio occupano container/immagini/volumi Docker

2. **Livello di rischio**:
   - 🟢 Verde (0-70%): OK
   - 🟡 Giallo (70-79%): Monitoraggio
   - 🟠 Arancione (80-84%): Attenzione
   - 🔴 Rosso (85-89%): Critico
   - 🚨 Emergenza (90%+): Azione immediata

3. **Azioni suggerite**:
   - Se sopra 80%: Suggerisci cleanup manuale immediato
   - Se safeguard non installati: Suggerisci installazione
   - Se trend crescita rapida: Suggerisci espansione disco

4. **Comandi utili** (copia-incolla ready):
   ```bash
   # Cleanup manuale immediato
   sudo /opt/scripts/disk-emergency-cleanup.sh

   # Cleanup aggressivo Docker
   docker system prune -a -f --volumes

   # Verifica timer
   systemctl list-timers disk-emergency-cleanup.timer
   ```
