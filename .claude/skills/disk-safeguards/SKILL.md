---
name: disk-safeguards
description: Installa e configura sistema automatico di prevenzione crash da spazio disco
allowed-tools: Bash(systemctl:*), Bash(crontab:*), Bash(docker:*), Read, Edit, Write
---

# Disk Safeguards - Sistema Automatico Anti-Crash

Questa skill installa un sistema completo di difesa multi-livello contro i crash VPS per spazio disco esaurito.

## Quando usare questa skill

- Prima che il VPS raggiunga livelli critici di spazio disco (80%+)
- Dopo aver installato Dokploy (Docker accumula cache rapidamente)
- Come best practice preventiva su tutti i VPS di produzione

## Cosa installa

### 1. Emergency Cleanup Service (systemd timer)
- **Frequenza**: Ogni 10 minuti
- **Soglie**:
  - 85%+ → Cleanup aggressivo
  - 80-84% → Cleanup preventivo
- **Log**: `/var/log/disk-emergency-cleanup.log`

### 2. Weekly Cleanup (cron job)
- **Frequenza**: Domenica 3am
- **Azione**: Pulizia conservativa Docker (risorse 7+ giorni)

### 3. Alert System
- **Canali**: Telegram, Discord, Slack (webhook configurabile)
- **Trigger**: Quando cleanup automatico si attiva

## Pre-requisiti

- Docker installato
- Permessi sudo/root
- (Opzionale) Webhook per notifiche

## Procedura di Installazione

### Step 1: Verifica stato attuale

```bash
# Utilizzo disco
df -h /

# Spazio Docker
docker system df
```

### Step 2: Installa script e configurazioni

```bash
cd ~/projects/vpshero/scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh
```

### Step 3: Configura notifiche (opzionale ma consigliato)

#### Opzione A: Telegram Bot

1. Crea bot via @BotFather
2. Ottieni token e chat_id
3. Aggiungi in `/etc/environment`:
   ```bash
   DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='
   ```

#### Opzione B: Discord Webhook

1. Crea webhook nel server Discord
2. Aggiungi in `/etc/environment`:
   ```bash
   DISK_ALERT_WEBHOOK='https://discord.com/api/webhooks/YOUR_WEBHOOK'
   ```

### Step 4: Test funzionamento

```bash
# Test esecuzione manuale
sudo /opt/scripts/disk-emergency-cleanup.sh

# Verifica timer attivo
systemctl status disk-emergency-cleanup.timer

# Prossime esecuzioni
systemctl list-timers
```

## Verifica Installazione Corretta

✅ Checklist:
- [ ] File `/opt/scripts/disk-emergency-cleanup.sh` presente ed eseguibile
- [ ] File `/opt/scripts/docker-weekly-cleanup.sh` presente ed eseguibile
- [ ] Service `disk-emergency-cleanup.timer` attivo e enabled
- [ ] Cron job weekly cleanup presente (`crontab -l`)
- [ ] Test esecuzione manuale completato senza errori
- [ ] Webhook configurato (opzionale)

## Comandi di Gestione

```bash
# Stato timer
systemctl status disk-emergency-cleanup.timer

# Avvia/ferma timer
sudo systemctl start disk-emergency-cleanup.timer
sudo systemctl stop disk-emergency-cleanup.timer

# Log real-time
journalctl -u disk-emergency-cleanup -f

# Log file
tail -f /var/log/disk-emergency-cleanup.log

# Esecuzione manuale forzata
sudo /opt/scripts/disk-emergency-cleanup.sh

# Cleanup aggressivo immediato
docker system prune -a -f --volumes
```

## Troubleshooting

### Timer non si avvia

```bash
# Verifica errori
journalctl -u disk-emergency-cleanup.timer

# Ricarica systemd
sudo systemctl daemon-reload
sudo systemctl restart disk-emergency-cleanup.timer
```

### Script fallisce

```bash
# Verifica permessi
ls -la /opt/scripts/disk-emergency-cleanup.sh

# Verifica Docker funzionante
docker ps

# Log dettagliato
sudo /opt/scripts/disk-emergency-cleanup.sh
tail -50 /var/log/disk-emergency-cleanup.log
```

### Notifiche non arrivano

```bash
# Verifica variabile ambiente
echo $DISK_ALERT_WEBHOOK

# Test webhook manuale
curl -X POST "$DISK_ALERT_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d '{"text":"Test notifica"}'
```

## Monitoraggio Quotidiano

### Comando rapido (aggiungi in .zshrc)

```bash
alias diskcheck='echo "=== Disk Usage ===" && df -h / && echo "\n=== Docker Usage ===" && docker system df && echo "\n=== Last Cleanup ===" && tail -5 /var/log/disk-emergency-cleanup.log'
```

Poi esegui semplicemente:
```bash
diskcheck
```

## Ottimizzazioni Avanzate

### Limita cache Docker globalmente

```bash
sudo nano /etc/docker/daemon.json
```

Aggiungi:
```json
{
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "10GB"
    }
  },
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Riavvia Docker:
```bash
sudo systemctl restart docker
```

## Riferimenti

- **Documentazione completa**: `docs/DISK-SAFEGUARDS.md`
- **Script sorgente**: `scripts/disk-emergency-cleanup.sh`
- **Configurazioni systemd**: `configs/systemd/disk-emergency-cleanup.*`

## Best Practices

1. **Installa SEMPRE dopo Dokploy** - Docker accumula cache rapidamente
2. **Configura webhook** - Notifiche real-time salvano il VPS di notte
3. **Monitora settimanalmente** - Esegui `diskcheck` una volta a settimana
4. **Testa manualmente** - Almeno una volta dopo l'installazione
5. **Considera espansione disco** - Se superi 80% regolarmente, espandi il disco fisico

## Filosofia di Difesa

```
Layer 1 (Provider)      → Buffer fisico (espansione disco)
         ↓
Layer 2 (Automatico)    → Cleanup ogni 10min (questo skill)
         ↓
Layer 3 (Preventivo)    → Pulizia settimanale (questo skill)
         ↓
Layer 4 (Alerting)      → Notifiche real-time (questo skill)
         ↓
Layer 5 (Recovery)      → Azioni emergenza manuale
```

Nessun single point of failure. Multi-layered defense.
