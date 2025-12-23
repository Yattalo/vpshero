# CLAUDE.md

> Istruzioni per Claude Code quando lavora con questo repository.

## Project Overview

**VPSHero** è un ecosistema DevOps che trasforma una VPS Ubuntu in un terminale avanzato con Claude Code come "cervello centrale". Fornisce:

- 🤖 **Claude Code configurato** con agenti, commands, skills e hooks specializzati
- 🚀 **Dokploy** (self-hosted PaaS) per deployment containerizzati
- 🔒 **Security hardening** (UFW, Fail2ban, SSH, audit logging)
- 💻 **Shell moderna** (Zsh + Oh My Zsh + Starship + CLI tools)
- 📊 **Monitoring automatico** (disk safeguards, health checks)

---

## Quick Reference

### Comandi Disponibili

| Comando | Descrizione | Model |
|---------|-------------|-------|
| `/deploy <app> <env>` | Deploy con zero-downtime | sonnet |
| `/rollback <app>` | Rollback versione precedente | haiku |
| `/health` | Health check sistema | haiku |
| `/logs <service>` | Visualizza/analizza logs | haiku |
| `/dns <action> <domain>` | Gestione DNS e SSL | sonnet |
| `/pr <action>` | Gestione Pull Request | sonnet |
| `/workflow <action>` | Gestione GitHub Actions | haiku |
| `/backup <action> <target>` | Gestione backup | sonnet |
| `/dokploy <action>` | Gestione Dokploy | haiku |
| `/github-setup` | Setup guidato GitHub → Dokploy | sonnet |
| `/disk-check` | Analisi spazio disco | haiku |

### Agenti Disponibili

| Agente | Specializzazione | Model |
|--------|------------------|-------|
| `@devops-engineer` | Deployment, scaling, infrastruttura | sonnet |
| `@security-auditor` | Vulnerabilità, hardening, compliance | opus |
| `@incident-responder` | Triage, logs, ripristino rapido | haiku |
| `@release-manager` | Versioning, changelog, CI/CD | sonnet |

### Skills Attive

| Skill | Area |
|-------|------|
| `docker-ops` | Container management, networking, volumes |
| `cicd-pipeline` | GitHub Actions, auto-deploy Dokploy |
| `dns-management` | DNS records, SSL/TLS, Let's Encrypt |
| `disk-safeguards` | Prevenzione crash disco, cleanup automatico |

---

## Architecture

### Struttura Directory

```
vpshero/
├── .claude/                    # ← Configurazione Claude Code
│   ├── settings.json           # Permessi e hooks
│   ├── agents/                 # 4 agenti specializzati
│   ├── commands/               # 11 slash commands
│   ├── skills/                 # 4 skills con documentazione
│   └── hooks/                  # 4 hooks automazione
│
├── scripts/                    # ← Script eseguibili
│   ├── disk-emergency-cleanup.sh
│   ├── docker-weekly-cleanup.sh
│   ├── setup-disk-safeguards.sh
│   └── verify-disk-safeguards.sh
│
├── configs/                    # ← Configurazioni
│   ├── starship.toml
│   └── systemd/                # Timer e service units
│
├── docs/                       # ← Documentazione completa
│   └── TOOLKIT-INDEX.md        # 📖 Indice master (leggi questo!)
│
└── setup-vps.sh                # Setup iniziale VPS
```

### Model Selection Strategy

Il progetto usa una **strategia di ottimizzazione costi** tra modelli:

| Model | Uso | Costo |
|-------|-----|-------|
| **Haiku** | Operazioni routine (health, logs, status) | 💰 Basso |
| **Sonnet** | Task complessi (deploy, review, troubleshooting) | 💰💰 Medio |
| **Opus** | Decisioni critiche (security audit, planning) | 💰💰💰 Alto |

I modelli sono specificati nel frontmatter di agents/commands via `model: haiku|sonnet|opus`.

### Hook System (Defense in Depth)

Gli hooks eseguono in momenti specifici del lifecycle:

| Hook | Evento | Scopo |
|------|--------|-------|
| `session-init.sh` | SessionStart | Log sessione, setup ambiente |
| `audit-log.sh` | PostToolUse | Log compliance di tutte le operazioni |
| `pre-deploy.sh` | PreToolUse | Validazione prima di docker/git/systemctl |
| `protect-critical.sh` | PreToolUse | Blocca modifica file sensibili |

### Permission Model

Il `settings.json` definisce tre livelli di permessi:

- **allow**: Operazioni read-only (git status, docker ps, monitoring)
- **ask**: Operazioni mutating che richiedono conferma (docker run, systemctl, file writes)
- **deny**: Operazioni distruttive/sensibili (rm -rf /, accesso credentials)

---

## Setup Commands

### Prima Installazione VPS

```bash
# 1. Setup completo VPS (run as non-root user with sudo)
chmod +x setup-vps.sh
./setup-vps.sh  # Seleziona opzione 1

# 2. Copia configurazioni Claude nella home
cp -r .claude/* ~/.claude/
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/statusline-vps.sh

# 3. Autenticazioni
gh auth login
claude
```

### Installazione Disk Safeguards (Opzionale ma Consigliato)

```bash
cd scripts
chmod +x setup-disk-safeguards.sh
sudo ./setup-disk-safeguards.sh

# Verifica installazione
sudo ./verify-disk-safeguards.sh
```

---

## Creating Extensions

### Nuovo Slash Command

Crea `.claude/commands/<name>.md`:

```yaml
---
description: Descrizione breve
argument-hint: <required> [optional]
allowed-tools: Bash(docker:*), Read, Glob
model: haiku
---

# Command: $1

Istruzioni per Claude...

Esegui: !`comando $1`
```

### Nuovo Agent

Crea `.claude/agents/<name>.md`:

```yaml
---
name: agent-name
description: Quando usare questo agente
tools: Read, Bash, Glob, Grep, Edit
model: sonnet
---

# Agent Name

Istruzioni dettagliate per l'agente...
```

### Nuova Skill

Crea `.claude/skills/<name>/SKILL.md`:

```yaml
---
name: skill-name
description: Descrizione capability
allowed-tools: Bash(specific:*), Read
---

# Skill Name

Documentazione completa e materiale di riferimento...
```

---

## Critical Files - Handle With Care

| File | Rischio | Note |
|------|---------|------|
| `.claude/settings.json` | 🔴 Alto | Modifica permessi = cambia security boundaries |
| `.claude/hooks/protect-critical.sh` | 🔴 Alto | Definisce file protetti del sistema |
| `setup-vps.sh` | 🟡 Medio | Non idempotente, eseguire una sola volta |
| `scripts/disk-emergency-cleanup.sh` | 🟡 Medio | Può eliminare risorse Docker (ma protegge Dokploy) |

---

## Progetti Deployati

Vedi `docs/PROJECTS.md` per l'elenco dei progetti gestiti con relative configurazioni.

### Pattern di Staging

I sottodomini `*.yattalo.com` sono **sempre staging/preview**. Il dominio di produzione è quello del cliente.

| Staging | Production | Progetto |
|---------|------------|----------|
| `ees.yattalo.com` | `eesystem-garda.it` | EESystem Garda |

---

## Documentazione Completa

📖 **Indice master**: [`docs/TOOLKIT-INDEX.md`](docs/TOOLKIT-INDEX.md)

Contiene:
- Inventario completo di tutti i componenti
- Dettagli per ogni agent, command, skill, hook
- Percorso di apprendimento consigliato
- Riferimenti rapidi

---

## Workflow Comuni

### Deploy Applicazione

```bash
# 1. Verifica stato sistema
/health

# 2. Deploy su staging
/deploy myapp staging

# 3. Se OK, deploy production
/deploy myapp production

# 4. Se problemi, rollback
/rollback myapp
```

### Troubleshooting

```bash
# 1. Assessment rapido
/health

# 2. Logs del servizio
/logs myapp 100

# 3. Analisi con agente
@incident-responder analizza l'outage di myapp

# 4. Se necessario, rollback
/rollback myapp
```

### Manutenzione Disco

```bash
# 1. Check stato
/disk-check

# 2. Se necessario, cleanup manuale
docker system prune -a -f

# 3. Per automatizzare (una volta sola)
cd scripts && sudo ./setup-disk-safeguards.sh
```

---

## Known Limitations

- Path `/root/.dokploy` è hardcoded in alcuni punti (dovrebbe usare `$HOME`)
- GitHub CLI authentication richiede device flow manuale
- `setup-vps.sh` non è idempotente (non rieseguire)
- Disk safeguards richiedono installazione manuale separata

---

## Risorse

| Risorsa | Link |
|---------|------|
| Indice Toolkit | `docs/TOOLKIT-INDEX.md` |
| Quick Reference | `docs/QUICK-REFERENCE.md` |
| Disk Safeguards | `docs/DISK-SAFEGUARDS.md` |
| Workflow Deployment | `docs/DEPLOYMENT-WORKFLOW.md` |
| Progetti Deployati | `docs/PROJECTS.md` |
