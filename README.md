# VPSHero

**Ecosistema VPS DevOps Avanzato con Claude Code come Cervello Centrale**

Un toolkit completo per trasformare una VPS Ubuntu in un terminale iper-avanzato per deployment rapido, sicuro e automatizzato. Progettato sia come **strumento operativo** che come **risorsa di apprendimento** per DevOps.

---

## ✨ Caratteristiche

| Area | Componenti |
|------|------------|
| 🤖 **Claude Code** | 4 agenti, 11 commands, 4 skills, 4 hooks |
| 🚀 **Dokploy** | Self-hosted PaaS per deployment containerizzati |
| 🔒 **Sicurezza** | UFW, Fail2ban, audit logging, protezione file critici |
| 💻 **Shell Avanzata** | Zsh + Oh My Zsh + Starship + CLI tools moderni |
| 📊 **Monitoring** | Disk safeguards automatici, health checks, alerting |
| 📚 **Documentazione** | Indice completo, percorso apprendimento, reference |

---

## 🚀 Quick Start

### 1. Prepara la VPS

```bash
# Connettiti alla VPS
ssh root@<IP>

# Crea utente non-root
adduser devops
usermod -aG sudo devops

# Riconnettiti come devops
exit
ssh devops@<IP>
```

### 2. Clona e Setup

```bash
# Clone repository
git clone https://github.com/Yattalo/vpshero.git
cd vpshero

# Setup completo (seleziona opzione 1)
chmod +x setup-vps.sh
./setup-vps.sh
```

### 3. Configura Claude Code

```bash
# Copia configurazioni (nota: .claude, non claude)
cp -r .claude/* ~/.claude/

# Rendi eseguibili gli script
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/statusline-vps.sh

# Autentica
gh auth login
claude
```

### 4. (Opzionale) Installa Disk Safeguards

```bash
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh
```

---

## 📁 Struttura del Progetto

```
vpshero/
├── 📄 README.md                      # Questo file
├── 📄 CLAUDE.md                      # Istruzioni per Claude Code
├── 📜 setup-vps.sh                   # Script setup principale
│
├── 📁 .claude/                       # ← Configurazione Claude Code
│   ├── settings.json                 # Permessi VPS
│   ├── settings.local.json           # Permessi sviluppo locale
│   ├── statusline-vps.sh             # Status bar DevOps
│   │
│   ├── agents/                       # 🤖 4 Agenti specializzati
│   │   ├── devops-engineer.md        #    → Deploy, scaling
│   │   ├── security-auditor.md       #    → Audit, vulnerabilità
│   │   ├── incident-responder.md     #    → Troubleshooting rapido
│   │   └── release-manager.md        #    → Versioning, release
│   │
│   ├── commands/                     # ⚡ 11 Slash commands
│   │   ├── deploy.md                 #    → /deploy
│   │   ├── rollback.md               #    → /rollback
│   │   ├── health.md                 #    → /health
│   │   ├── logs.md                   #    → /logs
│   │   ├── dns.md                    #    → /dns
│   │   ├── pr.md                     #    → /pr
│   │   ├── workflow.md               #    → /workflow
│   │   ├── backup.md                 #    → /backup
│   │   ├── dokploy.md                #    → /dokploy
│   │   ├── github-setup.md           #    → /github-setup ✨NEW
│   │   └── disk-check.md             #    → /disk-check ✨NEW
│   │
│   ├── skills/                       # 📚 4 Skills complesse
│   │   ├── docker-ops/               #    → Container management
│   │   ├── cicd-pipeline/            #    → GitHub Actions, Dokploy
│   │   ├── dns-management/           #    → DNS, SSL/TLS
│   │   └── disk-safeguards/          #    → Prevenzione crash ✨NEW
│   │
│   └── hooks/                        # 🔒 4 Hooks automazione
│       ├── session-init.sh           #    → Setup sessione
│       ├── audit-log.sh              #    → Log operazioni
│       ├── pre-deploy.sh             #    → Validazione pre-op
│       └── protect-critical.sh       #    → Protezione file
│
├── 📁 scripts/                       # 📜 Script eseguibili ✨NEW
│   ├── disk-emergency-cleanup.sh     #    → Cleanup automatico
│   ├── docker-weekly-cleanup.sh      #    → Pulizia settimanale
│   ├── setup-disk-safeguards.sh      #    → Installer safeguards
│   └── verify-disk-safeguards.sh     #    → Verifica installazione
│
├── 📁 configs/                       # ⚙️ Configurazioni
│   ├── starship.toml                 #    → Prompt Starship
│   └── systemd/                      #    ✨NEW
│       ├── disk-emergency-cleanup.service
│       └── disk-emergency-cleanup.timer
│
└── 📁 docs/                          # 📖 Documentazione ✨NEW
    ├── TOOLKIT-INDEX.md              #    → 📖 INDICE MASTER
    ├── QUICK-REFERENCE.md
    ├── DEPLOYMENT-WORKFLOW.md
    ├── DISK-SAFEGUARDS.md
    ├── DISK-SAFEGUARDS-QUICK-REFERENCE.md
    ├── STRATEGIA-PREVENZIONE-CRASH.md
    └── PROJECTS.md
```

---

## ⚡ Uso di Claude Code

### Slash Commands

| Comando | Descrizione | Model |
|---------|-------------|-------|
| `/deploy <app> <env>` | Deploy applicazione | sonnet |
| `/rollback <app>` | Rollback versione | haiku |
| `/health` | Health check sistema | haiku |
| `/logs <service>` | Visualizza logs | haiku |
| `/dns <action> <domain>` | Gestione DNS/SSL | sonnet |
| `/pr <action>` | Pull Request | sonnet |
| `/workflow <action>` | GitHub Actions | haiku |
| `/backup <action>` | Gestione backup | sonnet |
| `/dokploy <action>` | Gestione Dokploy | haiku |
| `/github-setup` | Setup GitHub→Dokploy | sonnet |
| `/disk-check` | Analisi spazio disco | haiku |

### Agenti Specializzati

```bash
# DevOps Engineer - deployment e infrastruttura
@devops-engineer deploya l'app su production

# Security Auditor - vulnerabilità e compliance
@security-auditor fai un security scan del Dockerfile

# Incident Responder - troubleshooting rapido
@incident-responder il sito è down, cosa faccio?

# Release Manager - versioning e release
@release-manager prepara la release v2.0
```

### Skills

Le skills si attivano automaticamente in base al contesto:

| Skill | Area | Documentazione |
|-------|------|----------------|
| `docker-ops` | Container, networking, volumes | Best practices Docker |
| `cicd-pipeline` | GitHub Actions, auto-deploy | CI/CD patterns |
| `dns-management` | DNS records, SSL/TLS | Let's Encrypt guide |
| `disk-safeguards` | Prevenzione crash disco | Cleanup automatico |

---

## 🎓 Mix di Modelli (Cost Optimization)

| Modello | Uso | Costo |
|---------|-----|-------|
| **Haiku** | Routine: health, logs, status, disk-check | 💰 Basso |
| **Sonnet** | Complesso: deploy, dns, pr, backup | 💰💰 Medio |
| **Opus** | Critico: security audit | 💰💰💰 Alto |

---

## 🔒 Sicurezza

### Hooks Automatici

| Hook | Evento | Scopo |
|------|--------|-------|
| `session-init.sh` | SessionStart | Log sessione, setup |
| `audit-log.sh` | PostToolUse | Log tutte le operazioni |
| `pre-deploy.sh` | PreToolUse | Validazione pre-deploy |
| `protect-critical.sh` | PreToolUse | Blocca modifica file critici |

### File Protetti

- `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`
- `/root/.ssh`, `/.ssh`, `/etc/ssl/private`
- `*.pem`, `*.key`, `*secrets*`, `*credentials*`

### Audit Log

```bash
# Log testuale
tail -f /var/log/claude-audit.log

# Log JSON strutturato
tail -f /var/log/claude-audit.jsonl
```

---

## 📊 Disk Safeguards (Protezione Disco)

Sistema automatico multi-livello per prevenire crash VPS da spazio disco esaurito.

### Caratteristiche

- ✅ **Emergency cleanup** ogni 30 minuti (soglia 85%)
- ✅ **Weekly cleanup** conservativo (domenica 3am)
- ✅ **Protezione Dokploy** - NON elimina volumi database
- ✅ **Alerting** via Telegram, Discord, Slack

### Quick Setup

```bash
cd scripts
sudo ./setup-disk-safeguards.sh

# Configura notifiche (opzionale)
sudo nano /etc/environment
# TELEGRAM_BOT_TOKEN='your-token'
# TELEGRAM_CHAT_ID='your-chat-id'
```

📖 Dettagli: [`docs/DISK-SAFEGUARDS.md`](docs/DISK-SAFEGUARDS.md)

---

## 📖 Documentazione

| Documento | Descrizione |
|-----------|-------------|
| **[TOOLKIT-INDEX.md](docs/TOOLKIT-INDEX.md)** | 📖 **Indice master** - Inizia qui! |
| [QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) | Comandi rapidi |
| [DEPLOYMENT-WORKFLOW.md](docs/DEPLOYMENT-WORKFLOW.md) | Workflow deployment |
| [DISK-SAFEGUARDS.md](docs/DISK-SAFEGUARDS.md) | Protezione disco |
| [PROJECTS.md](docs/PROJECTS.md) | Progetti deployati |

---

## 🎯 Workflow Tipici

### Deploy di una Nuova App

```bash
# 1. Setup GitHub (prima volta)
/github-setup

# 2. Verifica sistema
/health

# 3. Deploy su staging
/deploy myapp staging

# 4. Se OK, production
/deploy myapp production
```

### Gestione Incidente

```bash
# 1. Assessment rapido
/health

# 2. Logs del servizio
/logs myapp 100

# 3. Analisi con agente
@incident-responder analizza l'outage di myapp

# 4. Se necessario
/rollback myapp
```

### Manutenzione Disco

```bash
# 1. Check stato
/disk-check

# 2. Cleanup manuale se necessario
docker system prune -a -f

# 3. Automatizza (una volta)
cd scripts && sudo ./setup-disk-safeguards.sh
```

---

## 💰 Costi Stimati

| Componente | Costo Mensile |
|------------|---------------|
| Hetzner VPS 8GB | ~15 EUR |
| Claude API (mix modelli) | ~20-50 USD |
| **Totale** | **~35-65 EUR/mese** |

---

## 🛠️ Personalizzazione

### Aggiungere un Comando

```yaml
# .claude/commands/miocomando.md
---
description: Descrizione
argument-hint: <arg1>
allowed-tools: Bash(docker:*), Read
model: haiku
---

# Mio Comando: $1

Istruzioni...
```

### Aggiungere un Agente

```yaml
# .claude/agents/mioagente.md
---
name: mio-agente
description: Descrizione
tools: Read, Bash, Glob
model: sonnet
---

# Mio Agente

Istruzioni...
```

---

## 🐛 Troubleshooting

### Claude Code non si connette

```bash
claude --version
claude  # Riauthentication
```

### Dokploy non raggiungibile

```bash
docker ps | grep dokploy
docker logs dokploy-dokploy-1
cd /root/.dokploy && docker compose restart
```

### Hooks non funzionano

```bash
ls -la ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

### Disco pieno

```bash
/disk-check
docker system prune -a -f --volumes
```

---

## 📄 Licenza

MIT

---

## 🤝 Contributing

PR benvenute! Per modifiche significative, apri prima una issue.

---

## 📚 Risorse Correlate

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Dokploy Documentation](https://docs.dokploy.com)
- [GitHub Actions Documentation](https://docs.github.com/actions)
