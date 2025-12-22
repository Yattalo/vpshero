# Disk Safeguards - Documentazione Completa

Sistema automatico di prevenzione crash VPS per spazio disco esaurito.

## 📚 Navigazione Veloce

### **Documenti Strategici**

| File | Quando usarlo | Tempo lettura |
|------|---------------|---------------|
| **[STRATEGIA-PREVENZIONE-CRASH.md](../STRATEGIA-PREVENZIONE-CRASH.md)** | **INIZIA QUI** - Leggi PRIMA di tutto | 10 min |
| **[DISK-SAFEGUARDS.md](../DISK-SAFEGUARDS.md)** | Guida tecnica completa, troubleshooting | 15 min |

### **Script di Installazione**

| File | Descrizione | Come usare |
|------|-------------|------------|
| **[setup-disk-safeguards.sh](../../scripts/setup-disk-safeguards.sh)** | Installa tutto automaticamente (MAIN) | `sudo ./setup-disk-safeguards.sh` |
| **[disk-emergency-cleanup.sh](../../scripts/disk-emergency-cleanup.sh)** | Cleanup automatico (eseguito da timer) | Eseguito automaticamente ogni 10min |
| **[docker-weekly-cleanup.sh](../../scripts/docker-weekly-cleanup.sh)** | Pulizia settimanale preventiva | Eseguito automaticamente domenica 3am |

### **Configurazioni Systemd**

| File | Descrizione |
|------|-------------|
| **[disk-emergency-cleanup.service](../../configs/systemd/disk-emergency-cleanup.service)** | Service unit per cleanup automatico |
| **[disk-emergency-cleanup.timer](../../configs/systemd/disk-emergency-cleanup.timer)** | Timer (ogni 10min) |

### **Integrazioni Claude Code**

| File | Descrizione | Come usare |
|------|-------------|------------|
| **[/disk-check](./.claude/commands/disk-check.md)** | Comando per analisi disco rapida | `/disk-check` da Claude Code |
| **[disk-safeguards skill](./.claude/skills/disk-safeguards/)** | Skill completa per setup e gestione | Invocata automaticamente |

---

## 🚀 Quick Start (3 Step)

### **Step 1: Leggi la strategia** (10 minuti)

```bash
# Sul tuo Mac
cat docs/STRATEGIA-PREVENZIONE-CRASH.md
```

Leggi almeno:
- Le tue domande - Risposte dirette
- Piano d'azione immediato

### **Step 2: Installa safeguard sul VPS** (20 minuti)

```bash
# SSH nel VPS
ssh luckyluke@<VPS_IP>

# Clone repo (se non già fatto)
cd ~/projects
git clone https://github.com/yourusername/vpshero.git
cd vpshero

# Installa
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh
```

### **Step 3: Configura notifiche Telegram** (10 minuti)

```bash
# 1. Telegram → @BotFather → /newbot
# 2. Copia TOKEN
# 3. Manda messaggio al bot
# 4. Browser: https://api.telegram.org/bot<TOKEN>/getUpdates
# 5. Copia CHAT_ID

# 6. Sul VPS:
sudo nano /etc/environment

# Aggiungi:
DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='

# Riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer
```

**✅ FATTO! Sei protetto.**

---

## 📊 Architettura del Sistema

```
VPSHero Disk Safeguards
│
├── Layer 1: Automazione
│   ├── systemd timer (ogni 10min)
│   │   └── disk-emergency-cleanup.service
│   │       └── /opt/scripts/disk-emergency-cleanup.sh
│   │
│   └── cron job (domenica 3am)
│       └── /opt/scripts/docker-weekly-cleanup.sh
│
├── Layer 2: Monitoring
│   ├── Log file: /var/log/disk-emergency-cleanup.log
│   ├── Systemd journal: journalctl -u disk-emergency-cleanup
│   └── Claude Code command: /disk-check
│
├── Layer 3: Alerting
│   ├── Telegram Bot
│   ├── Discord Webhook
│   └── Email (opzionale)
│
└── Layer 4: Recovery
    ├── Cleanup automatico (soglie 80%/85%)
    ├── Cleanup manuale (docker system prune)
    └── Espansione disco (provider ETS)
```

---

## 🎯 Workflow Completo

```
┌─────────────────────────────────────────────────────────────┐
│  PREVENZIONE (Continua, 24/7)                               │
├─────────────────────────────────────────────────────────────┤
│  Timer systemd (ogni 10min)                                 │
│    └─> Controlla disco                                      │
│         ├─> <80%: Nessuna azione                            │
│         ├─> 80-84%: Cleanup preventivo                      │
│         └─> 85%+: Cleanup aggressivo + Alert Telegram       │
│                                                              │
│  Cron job (domenica 3am)                                    │
│    └─> Cleanup conservativo (cache 7+ giorni)               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  MONITORAGGIO (Settimanale, manuale)                        │
├─────────────────────────────────────────────────────────────┤
│  Lunedì mattina (2 minuti)                                  │
│    └─> diskcheck                                            │
│         └─> Verifica trend crescita                         │
│                                                              │
│  Primo del mese (5 minuti)                                  │
│    └─> Analisi log ultimo mese                              │
│         └─> Se cleanup > 5 volte → Espandi disco            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  RECOVERY (Solo se necessario)                              │
├─────────────────────────────────────────────────────────────┤
│  Se Telegram: "CRITICO: Azione manuale richiesta"           │
│    └─> SSH nel VPS                                          │
│         └─> docker system prune -a -f --volumes             │
│              └─> journalctl --vacuum-time=7d                │
│                   └─> Se ancora critico → Espandi disco     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Comandi Utili (Cheat Sheet)

### **Monitoraggio**

```bash
# Stato generale
diskcheck

# Disk usage dettagliato
df -h /
docker system df -v

# Log cleanup automatico
tail -f /var/log/disk-emergency-cleanup.log

# Stato timer
systemctl status disk-emergency-cleanup.timer

# Prossime esecuzioni
systemctl list-timers disk-emergency-cleanup.timer
```

### **Gestione Timer**

```bash
# Avvia timer
sudo systemctl start disk-emergency-cleanup.timer

# Ferma timer
sudo systemctl stop disk-emergency-cleanup.timer

# Riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer

# Log real-time
journalctl -u disk-emergency-cleanup -f
```

### **Cleanup Manuale**

```bash
# Test script (esecuzione immediata)
sudo /opt/scripts/disk-emergency-cleanup.sh

# Cleanup Docker aggressivo
docker system prune -a -f --volumes

# Cleanup log sistema
sudo journalctl --vacuum-time=7d

# Cleanup file temporanei
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
```

### **Troubleshooting**

```bash
# Verifica permessi script
ls -la /opt/scripts/disk-emergency-cleanup.sh

# Verifica variabile webhook
echo $DISK_ALERT_WEBHOOK

# Test webhook manuale
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text=Test"

# Ricarica systemd
sudo systemctl daemon-reload
sudo systemctl restart disk-emergency-cleanup.timer

# Log errori
journalctl -u disk-emergency-cleanup --since "1 hour ago"
```

---

## 📖 Risorse Aggiuntive

- **Documentazione Docker**: https://docs.docker.com/config/pruning/
- **Systemd Timers**: https://www.freedesktop.org/software/systemd/man/systemd.timer.html
- **Telegram Bot API**: https://core.telegram.org/bots/api

---

## 🆘 Supporto

**Problemi comuni risolti in**: `docs/DISK-SAFEGUARDS.md` → Sezione "Troubleshooting"

**Issue tracker**: https://github.com/yourusername/vpshero/issues

**Domande frequenti**:

| Domanda | Risposta |
|---------|----------|
| Timer non si avvia | `sudo systemctl daemon-reload && sudo systemctl restart disk-emergency-cleanup.timer` |
| Telegram non funziona | Verifica `DISK_ALERT_WEBHOOK` in `/etc/environment` e testa con curl |
| Script fallisce | Controlla log: `tail -50 /var/log/disk-emergency-cleanup.log` |
| Disco sempre pieno | Espandi disco da ETS + verifica Dokploy cache limit |

---

**✅ Se hai seguito tutti gli step**: Sei protetto contro crash notturni da spazio disco.

**⚠️ Se hai dubbi**: Leggi `STRATEGIA-PREVENZIONE-CRASH.md` PRIMA di procedere.
