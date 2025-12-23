# VPSHero Toolkit - Indice Completo

> **Ecosistema DevOps completo per VPS con Claude Code come cervello centrale**

Questo documento è l'**indice master** di tutti gli strumenti, comandi, agenti e script disponibili nel toolkit VPSHero. Usalo come riferimento rapido e punto di partenza per l'apprendimento.

---

## 📊 Panoramica Componenti

| Categoria | Quantità | Scopo |
|-----------|----------|-------|
| 🤖 **Agenti** | 4 | AI personas specializzate per task complessi |
| ⚡ **Commands** | 11 | Slash commands per operazioni rapide |
| 📚 **Skills** | 4 | Capabilities multi-step con documentazione |
| 🔒 **Hooks** | 4 | Automazione e sicurezza lifecycle |
| 📜 **Scripts** | 5 | Script bash eseguibili |
| ⚙️ **Configs** | 4 | Configurazioni systemd, shell, ecc. |

---

## 🤖 AGENTI (Agents)

Gli agenti sono **AI personas specializzate** che Claude può assumere per task complessi. Ogni agente ha competenze, tools e model specifici.

### Tabella Riassuntiva

| Agente | Model | Specializzazione | Quando Usarlo |
|--------|-------|------------------|---------------|
| [devops-engineer](#devops-engineer) | sonnet | Deployment, scaling, infrastruttura | Deploy complessi, troubleshooting infra |
| [security-auditor](#security-auditor) | opus | Vulnerabilità, hardening, compliance | Audit sicurezza, review codice critico |
| [incident-responder](#incident-responder) | haiku | Triage, logs, ripristino rapido | Outage, emergenze, troubleshooting veloce |
| [release-manager](#release-manager) | sonnet | Versioning, changelog, CI/CD | Preparazione release, gestione tag |

### Dettagli Agenti

#### devops-engineer
**File**: `.claude/agents/devops-engineer.md`
**Model**: sonnet (bilanciato)
**Tools**: Read, Bash, Glob, Grep, Edit

**Capabilities**:
- Deployment con health checks e rollback automatico
- Scaling e resource management
- Infrastructure as Code
- Troubleshooting sistemistico

**Esempio d'uso**:
```
@devops-engineer deploya l'app su production con zero-downtime
@devops-engineer analizza perché il container sta crashando
```

---

#### security-auditor
**File**: `.claude/agents/security-auditor.md`
**Model**: opus (più capace, per decisioni critiche)
**Tools**: Read, Grep, Glob, Bash

**Capabilities**:
- Audit vulnerabilità codice e infrastruttura
- Container security scanning
- Compliance checking (CWE/CVE)
- Report con severity e remediation

**Esempio d'uso**:
```
@security-auditor fai audit di sicurezza del Dockerfile
@security-auditor verifica se ci sono secrets esposti nel repo
```

---

#### incident-responder
**File**: `.claude/agents/incident-responder.md`
**Model**: haiku (veloce, per emergenze)
**Tools**: Read, Bash, Grep

**Capabilities**:
- Triage rapido (assess → mitigate → restore)
- Log analysis e pattern recognition
- Comandi quick-fix per situazioni comuni
- Escalation criteria

**Esempio d'uso**:
```
@incident-responder il sito è down, cosa faccio?
@incident-responder analizza i log degli ultimi 30 minuti
```

---

#### release-manager
**File**: `.claude/agents/release-manager.md`
**Model**: sonnet
**Tools**: Read, Bash, Glob, Grep, Edit

**Capabilities**:
- Semantic versioning (major.minor.patch)
- Changelog generation
- GitHub releases e tag
- Pre-release checklist e rollback plan

**Esempio d'uso**:
```
@release-manager prepara la release v2.0.0
@release-manager genera il changelog dall'ultimo tag
```

---

## ⚡ COMMANDS (Slash Commands)

I commands sono **operazioni rapide** invocabili con `/comando`. Ogni command ha un model ottimizzato per il suo caso d'uso.

### Tabella Riassuntiva

| Comando | Model | Argomenti | Descrizione |
|---------|-------|-----------|-------------|
| [/deploy](#deploy) | sonnet | `<app> <env>` | Deploy applicazione con zero-downtime |
| [/rollback](#rollback) | haiku | `<app> [version]` | Rollback a versione precedente |
| [/health](#health) | haiku | - | Health check completo sistema |
| [/logs](#logs) | haiku | `<service> [lines] [filter]` | Visualizza e analizza logs |
| [/dns](#dns) | sonnet | `<action> <domain>` | Gestione DNS e SSL |
| [/pr](#pr) | sonnet | `<action> [args]` | Gestione Pull Request |
| [/workflow](#workflow) | haiku | `<action> [workflow]` | Gestione GitHub Actions |
| [/backup](#backup) | sonnet | `<action> <target>` | Gestione backup |
| [/dokploy](#dokploy) | haiku | `<action> [args]` | Gestione Dokploy |
| [/github-setup](#github-setup) | sonnet | - | Setup guidato GitHub → Dokploy |
| [/disk-check](#disk-check) | haiku | - | Analisi spazio disco e Docker |

### Dettagli Commands

#### /deploy
**File**: `.claude/commands/deploy.md`
**Uso**: `/deploy <app-name> <staging|production>`

Esegue deployment completo con:
- Pre-flight check (risorse, stato container)
- Backup automatico pre-deploy
- Health check post-deploy
- Rollback automatico se fallisce

---

#### /rollback
**File**: `.claude/commands/rollback.md`
**Uso**: `/rollback <app-name> [version-tag]`

Ripristina versione precedente usando:
- Backup esistente, oppure
- Tag/versione specificata

---

#### /health
**File**: `.claude/commands/health.md`
**Uso**: `/health`

Analizza:
- CPU, memoria, disco
- Container Docker attivi
- Servizi systemd
- Connessioni di rete

Output: assessment con status (🟢🟡🔴) e raccomandazioni.

---

#### /logs
**File**: `.claude/commands/logs.md`
**Uso**: `/logs <service-name> [lines:50] [filter]`

Supporta:
- Container Docker
- Servizi systemd
- File di log custom

Include analisi pattern e suggerimenti.

---

#### /dns
**File**: `.claude/commands/dns.md`
**Uso**: `/dns <check|verify|ssl-status|ssl-renew> <domain>`

Actions:
- `check`: Verifica record DNS
- `verify`: Test risoluzione
- `ssl-status`: Info certificato
- `ssl-renew`: Rinnovo Let's Encrypt

---

#### /pr
**File**: `.claude/commands/pr.md`
**Uso**: `/pr <list|create|view|merge|review> [args]`

Gestione completa PR con GitHub CLI:
- Lista PR aperte
- Crea nuova PR
- Review e merge

---

#### /workflow
**File**: `.claude/commands/workflow.md`
**Uso**: `/workflow <list|run|view|logs> [workflow] [args]`

Gestione GitHub Actions:
- Lista workflow disponibili
- Trigger manuale
- Visualizza logs di run

---

#### /backup
**File**: `.claude/commands/backup.md`
**Uso**: `/backup <create|list|restore> <target>`

Backup di:
- Volumi Docker
- Database (PostgreSQL, MySQL)
- Configurazioni container

---

#### /dokploy
**File**: `.claude/commands/dokploy.md`
**Uso**: `/dokploy <status|apps|logs|restart|backup|webhook> [args]`

Gestione Dokploy:
- Status sistema e Traefik
- Lista app deployate
- Restart servizi
- Troubleshooting

---

#### /github-setup
**File**: `.claude/commands/github-setup.md`
**Uso**: `/github-setup`

Setup guidato interattivo:
1. Verifica prerequisiti
2. Configura SSH keys
3. Test connessione GitHub
4. Crea prima app
5. Attiva webhook CI/CD

---

#### /disk-check
**File**: `.claude/commands/disk-check.md`
**Uso**: `/disk-check`

Analisi rapida:
- Utilizzo disco globale
- Spazio Docker dettagliato
- Risk level (🟢🟡🟠🔴)
- Azioni suggerite

---

## 📚 SKILLS

Le skills sono **capabilities complesse** con documentazione integrata. Si attivano automaticamente in base al contesto o possono essere invocate esplicitamente.

### Tabella Riassuntiva

| Skill | Area | Complessità | Documentazione |
|-------|------|-------------|----------------|
| [docker-ops](#docker-ops) | Container Management | Alta | Best practices Docker |
| [cicd-pipeline](#cicd-pipeline) | CI/CD Automation | Alta | GitHub Actions, Dokploy |
| [dns-management](#dns-management) | DNS & SSL/TLS | Media | Let's Encrypt, DNS records |
| [disk-safeguards](#disk-safeguards) | Storage Monitoring | Media | Prevenzione crash disco |

### Dettagli Skills

#### docker-ops
**File**: `.claude/skills/docker-ops/SKILL.md`
**Tools**: Bash(docker:*), Read, Edit, Glob

**Capabilities**:
- Container lifecycle (create, start, stop, remove)
- Image management e multi-stage builds
- Networking e volume management
- Docker Compose orchestration
- Troubleshooting e debugging

---

#### cicd-pipeline
**File**: `.claude/skills/cicd-pipeline/SKILL.md`
**Tools**: Read, Bash, Edit, Glob, Grep, Write

**Capabilities**:
- Setup workflow GitHub Actions
- Pipeline debug e optimization
- Caching strategies (npm, pip, Docker)
- Secrets management
- Auto-deploy to Dokploy

---

#### dns-management
**File**: `.claude/skills/dns-management/SKILL.md`
**Tools**: Bash(dig, openssl, certbot:*), Read, Edit

**Capabilities**:
- DNS record verification (A, CNAME, MX, TXT)
- SSL/TLS certificate management
- Let's Encrypt integration
- Email DNS (SPF, DKIM, DMARC)

---

#### disk-safeguards
**File**: `.claude/skills/disk-safeguards/SKILL.md`
**Tools**: Bash(systemctl, docker:*), Read, Edit, Write

**Capabilities**:
- Emergency cleanup automatico (ogni 30min)
- Weekly cleanup preventivo
- Alert system (Telegram, Discord, Slack)
- Protezione volumi Dokploy

---

## 🔒 HOOKS

Gli hooks sono **script di automazione** che si attivano in momenti specifici del lifecycle di Claude Code.

### Tabella Riassuntiva

| Hook | Evento | File | Scopo |
|------|--------|------|-------|
| session-init | SessionStart | `.claude/hooks/session-init.sh` | Setup ambiente, log inizio |
| audit-log | PostToolUse | `.claude/hooks/audit-log.sh` | Log compliance operazioni |
| pre-deploy | PreToolUse | `.claude/hooks/pre-deploy.sh` | Validazione pre-operazioni critiche |
| protect-critical | PreToolUse | `.claude/hooks/protect-critical.sh` | Blocco modifica file sensibili |

### Dettagli Hooks

#### session-init.sh
**Evento**: SessionStart (all'avvio di ogni sessione Claude)

**Azioni**:
- Log timestamp inizio sessione
- Export variabili ambiente
- Health check rapido sistema
- Setup context

---

#### audit-log.sh
**Evento**: PostToolUse (dopo ogni operazione)

**Azioni**:
- Log JSON strutturato in `/var/log/claude-audit.jsonl`
- Log testuale in `/var/log/claude-audit.log`
- Cattura: tool, parametri, timestamp, user

---

#### pre-deploy.sh
**Evento**: PreToolUse (prima di operazioni docker/git/systemctl)

**Azioni**:
- Verifica risorse disponibili (RAM, disco)
- Safety check per comandi pericolosi
- Warn per force push su main
- Exit code 2 = blocca operazione

---

#### protect-critical.sh
**Evento**: PreToolUse (prima di Edit/Write)

**Azioni**:
- Blocca modifica a:
  - `/etc/passwd`, `/etc/sudoers`, `/etc/ssh/sshd_config`
  - `*.pem`, `*.key`, `*secrets*`, `*credentials*`
  - `/root/.ssh`, `/.ssh`
- Exit code 2 = blocca operazione

---

## 📜 SCRIPTS

Script bash eseguibili per operazioni standalone.

### Tabella Riassuntiva

| Script | Scopo | Esecuzione | Sudo |
|--------|-------|------------|------|
| setup-vps.sh | Setup completo VPS | Manuale (una volta) | Sì |
| disk-emergency-cleanup.sh | Cleanup disco automatico | Systemd timer (30min) | Sì |
| docker-weekly-cleanup.sh | Pulizia settimanale Docker | Cron (domenica 3am) | Sì |
| setup-disk-safeguards.sh | Installa sistema safeguards | Manuale | Sì |
| verify-disk-safeguards.sh | Verifica installazione | Manuale | Sì |
| statusline-vps.sh | Status bar DevOps | Manuale | No |

### Dettagli Scripts

#### setup-vps.sh
**Path**: `./setup-vps.sh`
**Uso**: `chmod +x setup-vps.sh && ./setup-vps.sh`

Setup completo VPS:
1. Aggiornamento sistema
2. Sicurezza (UFW, Fail2ban)
3. Shell (Zsh, Oh My Zsh, Starship)
4. CLI tools moderni
5. GitHub CLI
6. Node.js
7. Dokploy
8. Claude Code

⚠️ **Non idempotente** - eseguire una sola volta.

---

#### disk-emergency-cleanup.sh
**Path**: `./scripts/disk-emergency-cleanup.sh`
**Esecuzione**: Systemd timer ogni 30 minuti

**Soglie**:
- 80-84%: Cleanup preventivo
- 85%+: Cleanup aggressivo + alert

**Protezioni Dokploy**:
- Esclude volumi: dokploy, postgres, redis, traefik, mysql, mongo
- File locking anti-race condition
- Validazione input

---

#### docker-weekly-cleanup.sh
**Path**: `./scripts/docker-weekly-cleanup.sh`
**Esecuzione**: Cron domenica 03:00

Pulizia conservativa:
- Container stopped
- Build cache 7+ giorni
- Immagini non usate 7+ giorni
- Volumi orfani (esclusi critici)

---

#### setup-disk-safeguards.sh
**Path**: `./scripts/setup-disk-safeguards.sh`
**Uso**: `sudo ./setup-disk-safeguards.sh`

Installa:
- Systemd timer per emergency cleanup
- Cron job per weekly cleanup
- Logrotate configuration
- Istruzioni per webhook

---

#### verify-disk-safeguards.sh
**Path**: `./scripts/verify-disk-safeguards.sh`
**Uso**: `sudo ./verify-disk-safeguards.sh`

Verifica:
- File installati correttamente
- Timer systemd attivo
- Cron job configurato
- Test esecuzione script

---

#### statusline-vps.sh
**Path**: `.claude/statusline-vps.sh`
**Uso**: Chiamato automaticamente da Claude Code

Mostra:
- Metriche sistema (CPU, RAM, disco)
- Container Docker attivi
- Costo stimato sessione
- Context usage

---

## ⚙️ CONFIGURAZIONI

### Tabella Riassuntiva

| File | Tipo | Scopo |
|------|------|-------|
| `.claude/settings.json` | JSON | Permessi, hooks, env vars per VPS |
| `.claude/settings.local.json` | JSON | Template per sviluppo locale |
| `configs/starship.toml` | TOML | Prompt Starship |
| `configs/systemd/*.service` | Systemd | Service unit per cleanup |
| `configs/systemd/*.timer` | Systemd | Timer per esecuzione periodica |

---

## 📁 STRUTTURA DIRECTORY COMPLETA

```
vpshero/
├── 📄 README.md                      # Introduzione e quick start
├── 📄 CLAUDE.md                      # Istruzioni per Claude Code
├── 📜 setup-vps.sh                   # Script setup principale
│
├── 📁 .claude/                       # Configurazione Claude Code
│   ├── 📄 settings.json              # Permessi VPS
│   ├── 📄 settings.local.json        # Permessi locali
│   ├── 📜 statusline-vps.sh          # Status bar
│   │
│   ├── 📁 agents/                    # 🤖 Agenti AI
│   │   ├── devops-engineer.md
│   │   ├── security-auditor.md
│   │   ├── incident-responder.md
│   │   └── release-manager.md
│   │
│   ├── 📁 commands/                  # ⚡ Slash commands
│   │   ├── backup.md
│   │   ├── deploy.md
│   │   ├── disk-check.md             # ✨ NUOVO
│   │   ├── dns.md
│   │   ├── dokploy.md
│   │   ├── github-setup.md           # ✨ NUOVO
│   │   ├── health.md
│   │   ├── logs.md
│   │   ├── pr.md
│   │   ├── rollback.md
│   │   └── workflow.md
│   │
│   ├── 📁 skills/                    # 📚 Skills complesse
│   │   ├── cicd-pipeline/
│   │   ├── disk-safeguards/          # ✨ NUOVO
│   │   ├── dns-management/
│   │   └── docker-ops/
│   │
│   └── 📁 hooks/                     # 🔒 Automazione
│       ├── audit-log.sh
│       ├── pre-deploy.sh
│       ├── protect-critical.sh
│       └── session-init.sh
│
├── 📁 scripts/                       # 📜 Script eseguibili
│   ├── disk-emergency-cleanup.sh     # ✨ NUOVO
│   ├── docker-weekly-cleanup.sh      # ✨ NUOVO
│   ├── setup-disk-safeguards.sh      # ✨ NUOVO
│   └── verify-disk-safeguards.sh     # ✨ NUOVO
│
├── 📁 configs/                       # ⚙️ Configurazioni
│   ├── starship.toml
│   └── systemd/                      # ✨ NUOVO
│       ├── disk-emergency-cleanup.service
│       └── disk-emergency-cleanup.timer
│
└── 📁 docs/                          # 📖 Documentazione
    ├── TOOLKIT-INDEX.md              # 👈 Questo file
    ├── PROJECTS.md
    ├── QUICK-REFERENCE.md
    ├── DEPLOYMENT-WORKFLOW.md
    ├── DISK-SAFEGUARDS.md
    ├── DISK-SAFEGUARDS-QUICK-REFERENCE.md
    ├── STRATEGIA-PREVENZIONE-CRASH.md
    └── disk-safeguards/
        └── README.md
```

---

## 🎓 PERCORSO DI APPRENDIMENTO

### Per Principianti

1. **Leggi** `README.md` - Panoramica generale
2. **Esplora** `/health` - Capire lo stato del sistema
3. **Prova** `/logs <service>` - Analizzare logs
4. **Usa** `@incident-responder` - Per troubleshooting guidato

### Per Utenti Intermedi

1. **Setup** `/github-setup` - Collegare GitHub a Dokploy
2. **Deploy** `/deploy <app> staging` - Primo deployment
3. **Monitor** `/disk-check` - Monitoraggio risorse
4. **Automatizza** Setup disk safeguards

### Per Utenti Avanzati

1. **Audit** `@security-auditor` - Security review
2. **Release** `@release-manager` - Gestione versioni
3. **Custom** Crea nuovi commands/agents
4. **Estendi** Aggiungi nuove skills

---

## 🔗 RIFERIMENTI RAPIDI

### Comandi Più Usati

```bash
# Health check rapido
/health

# Logs di un servizio
/logs myapp 100

# Deploy su staging
/deploy myapp staging

# Stato disco
/disk-check

# Gestione Dokploy
/dokploy status
```

### Agenti per Situazione

| Situazione | Agente Consigliato |
|------------|-------------------|
| "Il sito è down!" | `@incident-responder` |
| "Devo deployare in produzione" | `@devops-engineer` |
| "È sicuro questo codice?" | `@security-auditor` |
| "Preparo la release" | `@release-manager` |

### File di Log

| Log | Path | Contenuto |
|-----|------|-----------|
| Audit Claude | `/var/log/claude-audit.log` | Tutte le operazioni |
| Audit JSON | `/var/log/claude-audit.jsonl` | Formato strutturato |
| Deploy | `/var/log/claude-deploy.log` | Operazioni deploy |
| Disk Cleanup | `/var/log/disk-emergency-cleanup.log` | Cleanup automatico |

---

## 📝 NOTE DI MANUTENZIONE

### Aggiornare Questo Indice

Quando aggiungi nuovi componenti:

1. Aggiungi entry nella tabella riassuntiva appropriata
2. Aggiungi sezione dettagli se necessario
3. Aggiorna struttura directory
4. Aggiorna CLAUDE.md se cambia architettura

### Versionamento

- **Agents/Commands/Skills**: Versionati implicitamente con git
- **Scripts**: Includono commento versione in header
- **Docs**: Data ultimo aggiornamento in footer

---

*Ultimo aggiornamento: 2025-12-22*
