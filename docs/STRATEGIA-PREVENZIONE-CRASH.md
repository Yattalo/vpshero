# Strategia Completa: Prevenzione Crash Notturni da Spazio Disco

**Obiettivo**: MAI più siti offline di notte per spazio disco esaurito.

---

## 🤔 Le Tue Domande - Risposte Dirette

### **Q1: Cosa posso fare da ETS (il provider)?**

**Risposta breve**: **Espandere il disco** è l'unica cosa che ETS può fare direttamente.

**Dettagli**:

| Azione ETS | Cosa significa | Pro | Contro | Quando farlo |
|------------|----------------|-----|--------|--------------|
| **Espandi disco** | Da 30GB → 50GB o 60GB | - Risolve problema immediato<br>- Zero configurazione<br>- Buffer più grande | - Costo mensile (+€3-5)<br>- Non risolve causa (cache Docker)<br>- Temporaneo | **ORA**, se sei già a 78% e hai crescita organica |
| **Snapshot automatici** | Backup giornaliero automatico | - Recovery rapido se crash<br>- Protezione dati | - Costo storage<br>- NON previene il crash | Come **rete di sicurezza**, non soluzione |
| **Monitoring provider** | Alert via dashboard ETS | - Nessuna configurazione<br>- Incluso nel piano | - Spesso troppo lento (alert a 90%)<br>- Limiti configurazione soglie | Come **layer aggiuntivo**, non unico |

**🎯 Raccomandazione per ETS:**

Contatta ETS **OGGI** e chiedi:

```
Salve,
Vorrei un preventivo per:
1. Espandere disco da 30GB → 50GB (preferito) o 40GB (minimo)
2. Conferma se avete monitoring automatico disco con alert personalizzabili
3. Costo snapshot automatici giornalieri

Grazie
```

**⚠️ CRITICO da capire**: Espandere il disco NON risolve il problema di fondo. Se Docker accumula 30GB di cache, accumulerà anche 50GB. Ti dà solo più tempo prima del prossimo crash.

---

### **Q2: Cosa devo configurare SUL VPS (safeguard interni)?**

**Risposta breve**: **Devi configurare 3 livelli di automazione** sul VPS stesso.

**Dettagli**:

ETS NON può configurare questi safeguard per te. Sono script/servizi che DEVI installare tu sul VPS.

#### **Livello 1: Emergency Cleanup Automatico (CRITICO)**

**Cosa fa**: Controlla lo spazio disco **ogni 10 minuti**. Se supera 85%, pulisce automaticamente Docker.

**Come installare**:

```bash
# 1. SSH nel VPS
ssh luckyluke@<VPS_IP>

# 2. Clone repository VPSHero (se non già fatto)
cd ~/projects
git clone https://github.com/yourusername/vpshero.git
cd vpshero

# 3. Esegui setup automatico
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh

# 4. Verifica installazione
systemctl status disk-emergency-cleanup.timer
```

**Risultato**:
- ✅ Script eseguito ogni 10 minuti automaticamente
- ✅ Pulisce PRIMA che il VPS crashe (soglia 85%)
- ✅ Log in `/var/log/disk-emergency-cleanup.log`

#### **Livello 2: Cleanup Settimanale Preventivo**

**Cosa fa**: Ogni domenica alle 3am pulisce preventivamente cache Docker (risorse 7+ giorni).

**Come installare**: Incluso nello script `setup-disk-safeguards.sh` sopra.

**Risultato**:
- ✅ Previene accumulo graduale di cache
- ✅ Eseguito durante la notte (zero impatto utenti)

#### **Livello 3: Notifiche Real-Time (FORTEMENTE CONSIGLIATO)**

**Cosa fa**: Quando il cleanup automatico si attiva, ti manda una notifica istantanea su Telegram/Discord.

**Come configurare (Telegram - 5 minuti)**:

```bash
# 1. Crea bot Telegram
# - Apri Telegram → cerca @BotFather
# - Invia: /newbot
# - Segui wizard, copia il TOKEN

# 2. Ottieni Chat ID
# - Manda un messaggio al bot (qualsiasi cosa)
# - Apri browser: https://api.telegram.org/bot<TOKEN>/getUpdates
# - Copia il numero in "chat":{"id":123456789}

# 3. Configura webhook sul VPS
ssh luckyluke@<VPS_IP>
sudo nano /etc/environment

# Aggiungi questa riga (sostituisci <TOKEN> e <CHAT_ID>):
DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='

# Salva (Ctrl+O, Ctrl+X)

# 4. Riavvia servizio (perché legga la nuova variabile)
sudo systemctl restart disk-emergency-cleanup.timer

# 5. Test notifica
sudo /opt/scripts/disk-emergency-cleanup.sh
# Se disk > 80%, riceverai messaggio Telegram
```

**Risultato**:
- ✅ Ricevi alert **PRIMA** che sia troppo tardi
- ✅ Anche di notte alle 3am, sai cosa sta succedendo
- ✅ Puoi intervenire manualmente se serve

---

## 📊 Riepilogo Strategia Multi-Livello

```
┌────────────────────────────────────────────────────────────┐
│  LAYER 1: Provider (ETS) - BUFFER FISICO                   │
│  ───────────────────────────────────────────────────────   │
│  ✓ Espandi disco 30GB → 50GB                               │
│  ✓ Snapshot automatici (backup)                            │
│  ✓ Monitoring provider (alert dashboard)                   │
│                                                             │
│  🎯 AZIONE: Contatta ETS oggi per preventivo               │
└────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 2: VPS - AUTOMAZIONE DIFENSIVA (CRITICO!)           │
│  ───────────────────────────────────────────────────────   │
│  ✓ Emergency cleanup ogni 10min (soglia 85%)               │
│  ✓ Weekly cleanup domenica 3am                             │
│  ✓ Log centralizzato /var/log/disk-emergency-cleanup.log   │
│                                                             │
│  🎯 AZIONE: Installa setup-disk-safeguards.sh ORA          │
└────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 3: ALERTING - NOTIFICHE REAL-TIME                   │
│  ───────────────────────────────────────────────────────   │
│  ✓ Telegram bot (consigliato)                              │
│  ✓ Discord webhook (alternativa)                           │
│  ✓ Alert quando cleanup si attiva                          │
│                                                             │
│  🎯 AZIONE: Configura bot Telegram (5 minuti)              │
└────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 4: MONITORING - CONTROLLO QUOTIDIANO                │
│  ───────────────────────────────────────────────────────   │
│  ✓ Claude Code command: /disk-check                        │
│  ✓ Alias shell: diskcheck                                  │
│  ✓ Verifica log: tail /var/log/disk-emergency-cleanup.log  │
│                                                             │
│  🎯 AZIONE: Esegui diskcheck una volta a settimana         │
└────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 5: RECOVERY - AZIONI EMERGENZA MANUALE              │
│  ───────────────────────────────────────────────────────   │
│  ✓ docker system prune -a -f --volumes                     │
│  ✓ journalctl --vacuum-time=7d                             │
│  ✓ Riavvio servizi Docker                                  │
│                                                             │
│  🎯 AZIONE: Solo se tutti i layer automatici falliscono    │
└────────────────────────────────────────────────────────────┘
```

---

## ✅ Piano d'Azione Immediato (Oggi)

### **Fase 1: Provider (ETS) - 15 minuti**

1. [ ] Apri ticket supporto ETS per preventivo espansione disco
2. [ ] Chiedi info su monitoring/snapshot automatici inclusi
3. [ ] (Opzionale) Chiedi quanto costa avere backup giornalieri

**Tempo**: 15 minuti
**Quando ricevi preventivo**: Se <€5/mese, approva immediatamente espansione a 50GB

---

### **Fase 2: VPS Safeguards - 20 minuti**

```bash
# 1. SSH nel VPS
ssh luckyluke@<VPS_IP>

# 2. Vai alla directory VPSHero (o clona se non hai ancora fatto)
cd ~/projects/vpshero
# Se non esiste:
# cd ~/projects
# git clone https://github.com/yourusername/vpshero.git
# cd vpshero

# 3. Installa safeguard automatici
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh

# 4. Verifica installazione corretta
systemctl status disk-emergency-cleanup.timer
# Output atteso: "active (waiting)"

# 5. Test esecuzione manuale
sudo /opt/scripts/disk-emergency-cleanup.sh
tail -20 /var/log/disk-emergency-cleanup.log

# 6. Verifica cron weekly
crontab -l | grep docker-weekly-cleanup
# Output atteso: "0 3 * * 0 /opt/scripts/docker-weekly-cleanup.sh"
```

**Tempo**: 20 minuti
**Checkpoint**: Se vedi "active (waiting)" → ✅ Successo!

---

### **Fase 3: Notifiche Telegram - 10 minuti**

```bash
# 1. Apri Telegram → @BotFather
# 2. Invia: /newbot
# 3. Nome bot: "VPS Disk Alert" (o quello che vuoi)
# 4. Username: "vps_disk_alert_bot" (deve finire con _bot)
# 5. Copia TOKEN

# 6. Manda messaggio al bot (scrivi "ciao")
# 7. Browser: https://api.telegram.org/bot<TOKEN>/getUpdates
# 8. Copia il numero dopo "chat":{"id":

# 9. SSH nel VPS
ssh luckyluke@<VPS_IP>

# 10. Aggiungi webhook
sudo nano /etc/environment

# Aggiungi (TUTTO su UNA RIGA, sostituisci <TOKEN> e <CHAT_ID>):
DISK_ALERT_WEBHOOK='https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text='

# Salva: Ctrl+O, Invio, Ctrl+X

# 11. Riavvia timer (per leggere nuova variabile)
sudo systemctl restart disk-emergency-cleanup.timer

# 12. Test notifica (forza esecuzione)
sudo /opt/scripts/disk-emergency-cleanup.sh
# Se disco > 80%, ricevi messaggio Telegram
```

**Tempo**: 10 minuti
**Checkpoint**: Ricevi messaggio su Telegram → ✅ Successo!

---

### **Fase 4: Monitoring Setup - 5 minuti**

```bash
# 1. Aggiungi alias comodo
nano ~/.zshrc

# Aggiungi in fondo:
alias diskcheck='echo "=== Disk Usage ===" && df -h / && echo "\n=== Docker Usage ===" && docker system df && echo "\n=== Last Cleanup ===" && tail -5 /var/log/disk-emergency-cleanup.log'

# Salva: Ctrl+O, Invio, Ctrl+X

# 2. Ricarica config
source ~/.zshrc

# 3. Test comando
diskcheck
```

**Tempo**: 5 minuti
**Uso futuro**: Esegui `diskcheck` una volta a settimana (lunedì mattina)

---

## 🎯 Dopo l'Installazione - Cosa Aspettarti

### **Scenario 1: Tutto OK (disk < 80%)**

```
┌─ Ogni 10 minuti ────────────────────────────────────┐
│  Script controlla disco → 75% → Nessuna azione      │
│  Log: "Disk usage OK: 75% (sotto soglia 80%)"       │
└─────────────────────────────────────────────────────┘

┌─ Domenica 3am ──────────────────────────────────────┐
│  Weekly cleanup conservativo                         │
│  Rimuove: cache 7+ giorni, container stopped         │
│  Log: "Spazio recuperato: 2%"                        │
└─────────────────────────────────────────────────────┘
```

**Tu**: NON ricevi notifiche (tutto OK)

---

### **Scenario 2: Warning (disk 80-84%)**

```
┌─ Timer esecuzione ──────────────────────────────────┐
│  Script controlla disco → 82% → Cleanup preventivo  │
│  Rimuove: container stopped, cache 7+ giorni         │
│  Log: "Warning: Disk usage 82%, cleanup eseguito"   │
└─────────────────────────────────────────────────────┘

┌─ Dopo cleanup ──────────────────────────────────────┐
│  Disco → 76% → OK                                    │
└─────────────────────────────────────────────────────┘
```

**Tu**: NON ricevi notifiche (gestito automaticamente)

---

### **Scenario 3: Critico (disk 85%+)**

```
┌─ Timer esecuzione ──────────────────────────────────┐
│  Script controlla disco → 87% → ALERT + Cleanup     │
│  🚨 Telegram: "Disk usage CRITICO: 87%"             │
│  Cleanup aggressivo: TUTTE immagini non usate        │
└─────────────────────────────────────────────────────┘

┌─ Dopo cleanup ──────────────────────────────────────┐
│  Disco → 79% → OK                                    │
│  🚨 Telegram: "Cleanup completato: 79%"             │
└─────────────────────────────────────────────────────┘
```

**Tu**: Ricevi notifica Telegram → Sai che c'è stato un problema → Puoi investigare al mattino

---

### **Scenario 4: Emergenza (disk 90%+, cleanup non basta)**

```
┌─ Timer esecuzione ──────────────────────────────────┐
│  Script controlla disco → 92% → Cleanup aggressivo  │
│  Cleanup → Disco ancora 91% → FAIL                  │
│  🚨 Telegram: "CRITICO: Cleanup NON sufficiente"    │
│  🚨 Telegram: "AZIONE MANUALE RICHIESTA!"           │
└─────────────────────────────────────────────────────┘
```

**Tu**: Ricevi notifica CRITICA → Intervieni SUBITO:

```bash
# SSH nel VPS
ssh luckyluke@<VPS_IP>

# Cleanup DISPERATO
docker system prune -a -f --volumes
sudo journalctl --vacuum-time=7d
sudo find /var/log -type f -name "*.log" -mtime +7 -delete

# Riavvia servizi se necessario
docker restart $(docker ps -q)

# Verifica
df -h /
# Se ancora critico → Contatta ETS per espansione URGENTE
```

---

## 📈 Monitoraggio Continuo (Dopo Setup)

### **Settimanale (lunedì mattina, 2 minuti)**

```bash
ssh luckyluke@<VPS_IP>
diskcheck
```

Output atteso:
```
=== Disk Usage ===
/       30G  23G  5.8G  80%  /

=== Docker Usage ===
TYPE        TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images      15        10        12.5GB    5.2GB (41%)
Containers  10        10        2.1GB     0B (0%)
Volumes     5         5         1.8GB     0B (0%)

=== Last Cleanup ===
[2025-01-15 03:00:00] Weekly cleanup completato. Spazio recuperato: 3%
```

**Se disk > 85%**: Contatta ETS per espansione.

### **Mensile (primo del mese, 5 minuti)**

```bash
# 1. Verifica log ultimo mese
tail -100 /var/log/disk-emergency-cleanup.log

# 2. Conta quante volte cleanup è stato attivato
grep "CRITICO" /var/log/disk-emergency-cleanup.log | wc -l

# 3. Se > 5 volte al mese → Espandi disco SUBITO
```

---

## 💡 Insights Finali

```
★ Insight ─────────────────────────────────────
Perché questo approccio funziona:

1. **Defense in Depth**: 5 layer di difesa. Se uno fallisce, gli altri intervengono.

2. **Proattivo vs Reattivo**: Non aspettiamo il crash, preveniamo PRIMA.

3. **Automazione 24/7**: Funziona anche quando dormi. Timer systemd + notifiche.

4. **Escalation Graduale**:
   - Sotto 80%: Nessuna azione (efficienza)
   - 80-84%: Cleanup conservativo (prevenzione)
   - 85-89%: Cleanup aggressivo + alert (reazione)
   - 90%+: Alert CRITICO + azione manuale (emergenza)

5. **Costo Zero**: Tutto open source, nessun servizio esterno a pagamento (Telegram è gratis).
─────────────────────────────────────────────────
```

---

## 🚀 Checklist Finale - Sei Protetto Quando...

- [ ] ETS preventivo richiesto per espansione disco
- [ ] Script `setup-disk-safeguards.sh` eseguito con successo
- [ ] Timer systemd `disk-emergency-cleanup.timer` attivo
- [ ] Cron weekly cleanup configurato
- [ ] Bot Telegram configurato e testato
- [ ] Alias `diskcheck` funzionante
- [ ] Test esecuzione manuale completato
- [ ] Prima notifica Telegram ricevuta (test)

**Se hai tutti ✅**: **Sei protetto al 99% contro crash notturni.**

---

## 📞 Se Qualcosa Va Storto

### **Script fallisce**
```bash
tail -50 /var/log/disk-emergency-cleanup.log
journalctl -u disk-emergency-cleanup -n 50
```

### **Timer non parte**
```bash
sudo systemctl status disk-emergency-cleanup.timer
sudo systemctl restart disk-emergency-cleanup.timer
```

### **Telegram non funziona**
```bash
echo $DISK_ALERT_WEBHOOK  # Verifica variabile
# Test manuale:
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage?chat_id=<CHAT_ID>&text=Test"
```

### **Disco pieno ADESSO (emergenza)**
```bash
docker system prune -a -f --volumes
sudo journalctl --vacuum-time=3d
df -h /
```

---

**Remember**: Questa è una strategia **multi-layered**. Nessun singolo meccanismo è infallibile, ma combinati insieme prevengono il 99.9% dei crash.

**Prossimo Step**: Esegui "Fase 1" (contatta ETS) e "Fase 2" (installa safeguard) **oggi**. Il resto può essere fatto nei prossimi giorni.
