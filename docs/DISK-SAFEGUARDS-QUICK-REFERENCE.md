# Disk Safeguards - Quick Reference Card

**Stampa o salva questa pagina - contiene tutti i comandi essenziali.**

---

## 🚨 EMERGENZA - Disco Pieno ADESSO (95%+)

```bash
# 1. SSH nel VPS (potrebbe essere lento)
ssh luckyluke@<VPS_IP>

# 2. Cleanup IMMEDIATO (più aggressivo possibile)
docker system prune -a -f --volumes

# 3. Rimuovi log vecchi
sudo journalctl --vacuum-time=3d
sudo find /var/log -type f -name "*.log" -mtime +3 -delete

# 4. Verifica spazio recuperato
df -h /

# 5. Se ancora critico → Riavvia servizi
docker restart $(docker ps -q)
```

**Se SSH non risponde**: Console VPS via pannello ETS → Login root → Esegui comandi sopra

---

## 📊 Monitoraggio Quotidiano

### Controllo Rapido (30 secondi)

```bash
diskcheck
```

Output esempio:
```
=== Disk Usage ===
/       30G  23G  5.8G  78%  /
         ↑ Se > 85% → ALERT

=== Docker Usage ===
Images      15        10        12.5GB    5.2GB (41%)
                                   ↑ Reclaimable space

=== Last Cleanup ===
[2025-01-15 03:00:00] Weekly cleanup. Recuperato: 3%
```

### Soglie Operative

| % Disco | Colore | Azione |
|---------|--------|--------|
| 0-70% | 🟢 Verde | OK, nessuna azione |
| 70-79% | 🟡 Giallo | Monitora, nessuna urgenza |
| 80-84% | 🟠 Arancione | Cleanup automatico attivo |
| 85-89% | 🔴 Rosso | Alert Telegram + cleanup aggressivo |
| 90%+ | 🚨 Emergenza | **Intervento manuale SUBITO** |

---

## 🔧 Comandi Essenziali

### Stato Sistema

```bash
# Disk usage
df -h /

# Docker disk usage dettagliato
docker system df -v

# Stato timer automatico
systemctl status disk-emergency-cleanup.timer

# Prossima esecuzione timer
systemctl list-timers disk-emergency-cleanup.timer

# Log ultimi eventi
tail -20 /var/log/disk-emergency-cleanup.log

# Log real-time (Ctrl+C per uscire)
journalctl -u disk-emergency-cleanup -f
```

### Cleanup Manuale

```bash
# Test script (esecuzione immediata)
sudo /opt/scripts/disk-emergency-cleanup.sh

# Cleanup Docker conservativo (safe)
docker system prune -f

# Cleanup Docker aggressivo (rimuove TUTTO non usato)
docker system prune -a -f --volumes

# Cleanup log sistema (7 giorni)
sudo journalctl --vacuum-time=7d
```

### Gestione Timer

```bash
# Verifica timer attivo
systemctl is-active disk-emergency-cleanup.timer

# Avvia timer
sudo systemctl start disk-emergency-cleanup.timer

# Ferma timer
sudo systemctl stop disk-emergency-cleanup.timer

# Riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer

# Abilita all'avvio
sudo systemctl enable disk-emergency-cleanup.timer

# Ricarica configurazione (dopo modifiche)
sudo systemctl daemon-reload
```

---

## 📱 Telegram Notifiche

### Configurazione (One-Time Setup)

```bash
# 1. Telegram → @BotFather → /newbot
# 2. Copia TOKEN

# 3. Manda messaggio al bot (scrivi "ciao")
# 4. Browser: https://api.telegram.org/bot<TOKEN>/getUpdates
# 5. Copia CHAT_ID (numero in "chat":{"id":123456789)

# 6. Sul VPS:
sudo nano /etc/environment

# Aggiungi (tutto su UNA riga):
DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='

# Salva: Ctrl+O, Invio, Ctrl+X

# 7. Riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer
```

### Test Notifica

```bash
# Verifica variabile configurata
echo $DISK_ALERT_WEBHOOK

# Test manuale
curl -X POST "${DISK_ALERT_WEBHOOK}Test notifica VPS"

# Forza esecuzione script (se disk > 80%, ricevi notifica)
sudo /opt/scripts/disk-emergency-cleanup.sh
```

### Formato Notifiche

```
🚨 VPS Disk Alert: Disk usage CRITICO: 87% (soglia: 85%)
→ Cleanup automatico in corso...

✅ VPS Disk Alert: Cleanup completato. Disk usage: 79%
→ Situazione risolta.
```

---

## 🛠️ Troubleshooting

### Timer Non Si Avvia

```bash
# Verifica errori
journalctl -u disk-emergency-cleanup.timer -n 50

# Ricarica systemd
sudo systemctl daemon-reload

# Riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer

# Verifica sintassi file
sudo systemd-analyze verify /etc/systemd/system/disk-emergency-cleanup.timer
```

### Script Fallisce

```bash
# Verifica permessi
ls -la /opt/scripts/disk-emergency-cleanup.sh
# Output atteso: -rwxr-xr-x (eseguibile)

# Se non eseguibile:
sudo chmod +x /opt/scripts/disk-emergency-cleanup.sh

# Verifica Docker funzionante
docker ps
# Se fallisce: sudo systemctl restart docker

# Log errori script
tail -50 /var/log/disk-emergency-cleanup.log

# Esecuzione manuale con debug
sudo bash -x /opt/scripts/disk-emergency-cleanup.sh
```

### Telegram Non Funziona

```bash
# 1. Verifica variabile esistente
echo $DISK_ALERT_WEBHOOK
# Se vuoto → non configurato, rivedi setup

# 2. Test webhook manuale (sostituisci TOKEN e CHAT_ID)
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text=Test"
# Se fallisce → token/chat_id sbagliati

# 3. Verifica variabile in /etc/environment
cat /etc/environment | grep DISK_ALERT_WEBHOOK

# 4. Dopo modifiche, riavvia timer
sudo systemctl restart disk-emergency-cleanup.timer
```

### Disco Sempre Pieno

```bash
# 1. Identifica cosa occupa spazio
docker system df -v
du -sh /var/lib/docker/*

# 2. Limita cache Docker globalmente
sudo nano /etc/docker/daemon.json

# Aggiungi:
{
  "builder": {
    "gc": {
      "enabled": true,
      "defaultKeepStorage": "10GB"
    }
  }
}

# Riavvia Docker
sudo systemctl restart docker

# 3. Se ancora pieno → Espandi disco da ETS
```

---

## 📅 Manutenzione Programmata

### Settimanale (lunedì mattina, 2 minuti)

```bash
diskcheck

# Se disk > 85% per 2+ settimane consecutive:
# → Contatta ETS per espandere disco
```

### Mensile (primo del mese, 5 minuti)

```bash
# Analisi log ultimo mese
tail -100 /var/log/disk-emergency-cleanup.log

# Conta cleanup critici (85%+)
grep "CRITICO" /var/log/disk-emergency-cleanup.log | wc -l

# Se > 5 volte al mese:
# → Espandi disco SUBITO (problema cronico)
```

### Semestrale (ogni 6 mesi)

```bash
# Verifica installazione ancora funzionante
cd ~/projects/vpshero/scripts
chmod +x verify-disk-safeguards.sh
sudo ./verify-disk-safeguards.sh
```

---

## 🎯 Checklist Post-Installazione

Esegui dopo aver installato i safeguard:

```bash
# 1. Verifica installazione
cd ~/projects/vpshero/scripts
chmod +x verify-disk-safeguards.sh
sudo ./verify-disk-safeguards.sh

# 2. Verifica timer attivo
systemctl status disk-emergency-cleanup.timer
# Output atteso: "active (waiting)"

# 3. Verifica cron weekly
crontab -l | grep docker-weekly-cleanup
# Output atteso: "0 3 * * 0 /opt/scripts/docker-weekly-cleanup.sh"

# 4. Test esecuzione manuale
sudo /opt/scripts/disk-emergency-cleanup.sh
# Deve completare senza errori

# 5. Verifica log creato
tail -10 /var/log/disk-emergency-cleanup.log
# Deve mostrare log recenti

# 6. Test notifica Telegram (se configurato)
# Verifica di aver ricevuto notifica su Telegram
```

**✅ Se tutti i check passano**: Sistema safeguard attivo e funzionante!

---

## 📞 Contatti Emergenza

### Supporto Tecnico

- **Log file**: `/var/log/disk-emergency-cleanup.log`
- **Systemd log**: `journalctl -u disk-emergency-cleanup`
- **Documentazione completa**: `~/projects/vpshero/docs/DISK-SAFEGUARDS.md`

### Provider (ETS)

Quando contattare per espansione disco:
- Disk > 85% per 2+ settimane consecutive
- Cleanup automatico si attiva > 5 volte al mese
- Crescita organica progetti (più app deployate)

**Template email**:
```
Oggetto: Richiesta preventivo espansione disco VPS

Salve,
Ho un VPS con disco 30GB attualmente al 78% utilizzo.
Vorrei un preventivo per espandere a 50GB (o 40GB minimo).

Inoltre, confermate se il servizio include:
- Monitoring disco con alert configurabili
- Snapshot automatici giornalieri

Grazie
```

---

## 💾 Backup di Questa Reference

Salva questa pagina localmente:

```bash
# Sul tuo Mac
cat ~/Desktop/01_Active_Projects/vpshero/docs/DISK-SAFEGUARDS-QUICK-REFERENCE.md

# Oppure copia sul VPS per accesso rapido
scp ~/Desktop/01_Active_Projects/vpshero/docs/DISK-SAFEGUARDS-QUICK-REFERENCE.md \
    luckyluke@<VPS_IP>:~/disk-safeguards-ref.md
```

Poi sul VPS, quando serve:
```bash
less ~/disk-safeguards-ref.md
```

---

**📌 Ricorda**: Questo sistema è **multi-layered defense**. Nessun singolo meccanismo è infallibile, ma combinati insieme prevengono il 99.9% dei crash.

**✅ Sistema attivo → Dormi tranquillo.** I safeguard lavorano 24/7 anche quando tu dormi.
