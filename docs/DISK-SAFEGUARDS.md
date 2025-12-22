# Disk Safeguards - Strategia Multi-Livello

Prevenzione completa del crash VPS per spazio disco esaurito.

## 🎯 Obiettivo

**MAI più siti offline di notte per spazio disco pieno.**

## 📊 Situazione Attuale

- **Disco totale**: 30GB
- **Utilizzo corrente**: ~78% (23.4GB usati)
- **Problema principale**: Cache Docker che cresce indefinitamente
- **Rischio**: Sopra 95% il sistema diventa instabile

---

## 🛡️ Strategia Multi-Livello

### **Livello 1: Provider (ETS) - Buffer Fisico**

**Cosa fare:**
1. Contatta ETS e chiedi preventivo per espandere disco:
   - Da 30GB → 50GB (ideale)
   - Da 30GB → 40GB (minimo accettabile)

2. Verifica se ETS offre:
   - Monitoring infrastruttura con alert
   - Snapshot automatici giornalieri

**Quando espandere:**
- Se hai crescita organica dei progetti (più app, più dati reali)
- Se il costo mensile è accettabile (di solito €3-5/mese per 20GB extra)

**⚠️ IMPORTANTE:** Espandere il disco NON risolve il problema se Docker accumula cache. È solo un buffer temporale più grande.

---

### **Livello 2: Sistema VPS - Automazione Difensiva**

Implementiamo **3 meccanismi automatici**:

#### **A) Emergency Cleanup Service** (ogni 10 minuti)

Monitora continuamente e pulisce PRIMA che sia troppo tardi.

**Soglie:**
- 85%+ → Cleanup aggressivo immediato
- 80-84% → Cleanup preventivo
- <80% → Nessuna azione

**Cosa pulisce:**
- Container stopped
- Build cache Docker 7+ giorni
- Immagini non usate 7+ giorni
- Volumi orfani

**File:**
- Script: `/opt/scripts/disk-emergency-cleanup.sh`
- Service: `/etc/systemd/system/disk-emergency-cleanup.service`
- Timer: `/etc/systemd/system/disk-emergency-cleanup.timer`

#### **B) Weekly Cleanup** (domenica 3am)

Pulizia conservativa settimanale per prevenire accumulo graduale.

**File:**
- Script: `/opt/scripts/docker-weekly-cleanup.sh`
- Cron: `0 3 * * 0 /opt/scripts/docker-weekly-cleanup.sh`

#### **C) Alert System** (notifiche real-time)

Quando il cleanup automatico si attiva, invia notifica istantanea.

**Canali supportati:**
- Webhook generico (Telegram, Discord, Slack)
- Email (via `mail` command)
- Log centralizzato `/var/log/disk-emergency-cleanup.log`

---

### **Livello 3: Monitoring Proattivo**

#### **Dashboard Grafana + Prometheus** (Opzionale ma consigliato)

Dokploy include monitoring integrato. Configuralo per visualizzare:
- Disk usage trend (ultimo 7gg)
- Docker cache growth rate
- Alert automatici prima della soglia critica

#### **Uptime Monitoring Esterno**

Servizi gratuiti come **UptimeRobot** o **BetterStack** possono:
- Pingare i tuoi siti ogni 5 minuti
- Mandarti alert se vanno offline
- NON prevengono il problema, ma ti avvisano SUBITO se accade

---

## 🚀 Installazione Rapida

### **1. Clona repository (sul VPS)**

```bash
cd ~/projects
git clone https://github.com/yourusername/vpshero.git
cd vpshero
```

### **2. Esegui setup automatico**

```bash
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh
```

### **3. Configura notifiche (Telegram consigliato)**

#### **Opzione A: Telegram Bot (raccomandato)**

1. Crea bot Telegram:
   - Vai su [@BotFather](https://t.me/botfather)
   - `/newbot` → Segui wizard
   - Copia il **Bot Token**

2. Ottieni Chat ID:
   - Manda un messaggio al bot
   - Vai su `https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Copia il `chat_id`

3. Aggiungi variabile ambiente:
   ```bash
   sudo nano /etc/environment
   ```
   Aggiungi:
   ```bash
   DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='
   ```

4. Modifica script per Telegram:
   ```bash
   sudo nano /opt/scripts/disk-emergency-cleanup.sh
   ```
   Cerca la funzione `send_alert()` e sostituisci con:
   ```bash
   send_alert() {
       local message="$1"
       log "ALERT: $message"

       if [ -n "$DISK_ALERT_WEBHOOK" ]; then
           # Telegram format
           curl -s -X POST "${DISK_ALERT_WEBHOOK}${message}" || true
       fi
   }
   ```

#### **Opzione B: Discord Webhook**

1. Vai nel tuo server Discord → Impostazioni canale → Integrazioni → Webhooks
2. Crea nuovo webhook, copia URL
3. Aggiungi in `/etc/environment`:
   ```bash
   DISK_ALERT_WEBHOOK='https://discord.com/api/webhooks/YOUR_WEBHOOK'
   ```

4. Modifica `send_alert()`:
   ```bash
   send_alert() {
       local message="$1"
       log "ALERT: $message"

       if [ -n "$DISK_ALERT_WEBHOOK" ]; then
           curl -s -X POST "$DISK_ALERT_WEBHOOK" \
               -H "Content-Type: application/json" \
               -d "{\"content\":\"🚨 **VPS Disk Alert**\n$message\"}" || true
       fi
   }
   ```

---

## 📋 Verifica Funzionamento

### **1. Test manuale script**

```bash
# Esegui cleanup manualmente
sudo /opt/scripts/disk-emergency-cleanup.sh

# Verifica log
tail -f /var/log/disk-emergency-cleanup.log
```

### **2. Verifica timer systemd**

```bash
# Stato timer
systemctl status disk-emergency-cleanup.timer

# Lista prossime esecuzioni
systemctl list-timers disk-emergency-cleanup.timer

# Log real-time
journalctl -u disk-emergency-cleanup -f
```

### **3. Verifica cron weekly**

```bash
# Mostra cron jobs attivi
crontab -l

# Test esecuzione weekly cleanup
sudo /opt/scripts/docker-weekly-cleanup.sh
```

### **4. Simula alert**

```bash
# Forza invio notifica (per testare webhook)
# Modifica temporaneamente lo script per forzare alert, poi ripristina
```

---

## 🔍 Monitoring Quotidiano

### **Comandi rapidi**

```bash
# Utilizzo disco complessivo
df -h /

# Spazio Docker dettagliato
docker system df -v

# Quanto occupano le immagini
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Log cleanup automatico (ultimi 50 eventi)
tail -50 /var/log/disk-emergency-cleanup.log

# Verifica prossima esecuzione timer
systemctl list-timers
```

### **Script di controllo rapido**

Aggiungi nel tuo `.zshrc`:

```bash
# Disk status rapido
alias diskcheck='echo "=== Disk Usage ===" && df -h / && echo "\n=== Docker Usage ===" && docker system df && echo "\n=== Last Cleanup ===" && tail -5 /var/log/disk-emergency-cleanup.log'
```

Poi:
```bash
diskcheck
```

---

## 🎯 Soglie Operative

| Utilizzo | Stato | Azione Automatica | Azione Manuale |
|----------|-------|-------------------|----------------|
| 0-70% | 🟢 **Verde** | Nessuna | Nessuna |
| 70-79% | 🟡 **Giallo** | Nessuna | Monitoraggio attivo |
| 80-84% | 🟠 **Arancione** | Cleanup preventivo | Verifica cause crescita |
| 85-89% | 🔴 **Rosso** | Cleanup aggressivo + Alert | Intervento immediato |
| 90-94% | 🚨 **Critico** | Cleanup full + Alert | Espandi disco SUBITO |
| 95-100% | ⛔ **Emergenza** | Cleanup disperato | Riavvio servizi / Emergency SSH |

---

## ⚡ Azioni di Emergenza (se tutto fallisce)

### **Se arrivi al 95%+ e i servizi crashano:**

```bash
# 1. SSH nel VPS (potrebbe essere lento)
ssh user@vps

# 2. Cleanup IMMEDIATO (più aggressivo possibile)
docker system prune -a -f --volumes

# 3. Rimuovi log vecchi
sudo journalctl --vacuum-time=7d
sudo find /var/log -type f -name "*.log" -mtime +7 -delete

# 4. Rimuovi file temporanei
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# 5. Verifica spazio recuperato
df -h /

# 6. Riavvia servizi Dokploy (se necessario)
docker restart $(docker ps -q)
```

### **Se SSH non risponde (VPS quasi morto):**

1. Accedi alla console VPS via pannello ETS
2. Login come root
3. Esegui cleanup manuale (comandi sopra)
4. Considera espansione disco URGENTE

---

## 🧠 Filosofia di Difesa

```
Layer 1 (Provider)      → Buffer fisico (più spazio)
         ↓
Layer 2 (Automatico)    → Cleanup continuo (ogni 10min)
         ↓
Layer 3 (Preventivo)    → Pulizia settimanale
         ↓
Layer 4 (Alerting)      → Notifiche real-time
         ↓
Layer 5 (Recovery)      → Azioni emergenza manuale
```

**Nessun single point of failure.** Se un layer fallisce, il successivo interviene.

---

## 📈 Ottimizzazioni Avanzate

### **1. Limita cache Docker di Dokploy**

Dokploy accumula cache durante i build. Configura limite:

```bash
# Imposta limite cache Docker a 10GB
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
  }
}
```

Riavvia Docker:
```bash
sudo systemctl restart docker
```

### **2. Log Rotation Aggressivo**

Docker container logs possono crescere indefinitamente:

```bash
sudo nano /etc/docker/daemon.json
```

Aggiungi (se non presente):
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Ogni container avrà max 30MB di log (10MB x 3 file).

### **3. Bind Mount invece di Volumi (per dati grandi)**

Se hai progetti con molti dati statici (media, uploads), usa bind mount su directory separata invece di Docker volumes:

```yaml
# docker-compose.yml
volumes:
  - /opt/data/uploads:/app/uploads  # Bind mount
```

Poi monta `/opt` su partizione separata (se ETS lo supporta).

---

## 🎓 Lezioni Apprese

### **Errori Comuni da Evitare**

1. ❌ **"Espando il disco e basta"** → Docker riempie anche 100GB se non pulisci
2. ❌ **"Pulisco manualmente quando serve"** → Di notte sei offline, non te ne accorgi
3. ❌ **"Uso solo cron"** → Se VPS è offline durante l'esecuzione schedulata, salta il job
4. ❌ **"Confido nel monitoring di ETS"** → Spesso sono troppo lenti (alert quando già al 95%)

### **Approccio Corretto**

1. ✅ **Automazione multi-livello** (emergency + weekly)
2. ✅ **Notifiche istantanee** (Telegram/Discord)
3. ✅ **Monitoring continuo** (ogni 10min, non una volta al giorno)
4. ✅ **Soglie conservative** (alert a 80%, non a 90%)
5. ✅ **Buffer fisico ragionevole** (espandi disco se economicamente sensato)

---

## 📞 Supporto

- **Log**: `/var/log/disk-emergency-cleanup.log`
- **Systemd logs**: `journalctl -u disk-emergency-cleanup`
- **Docker logs**: `docker logs <container-id>`
- **Issue tracker**: [GitHub Issues](https://github.com/yourusername/vpshero/issues)

---

**Remember:** La migliore difesa è **multi-layered**. Nessun singolo meccanismo è infallibile, ma combinati insieme prevengono il 99.9% dei crash.
