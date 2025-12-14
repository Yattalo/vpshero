# VPSHero

**Ecosistema VPS DevOps Avanzato con Claude Code come Cervello Centrale**

Un setup completo per trasformare una VPS Ubuntu in un terminale iper-avanzato per deployment rapido, sicuro e automatizzato.

## Caratteristiche

- **Shell Avanzata**: Zsh + Oh My Zsh + Starship + strumenti CLI moderni
- **Claude Code**: Configurato come cervello centrale con agenti, skills e comandi specializzati
- **Dokploy**: Self-hosted PaaS per deployment containerizzati con zero-config
- **CI/CD**: Integrazione GitHub CLI + webhook automatici
- **Sicurezza**: Hardening SSH, firewall UFW, audit logging, protezione file critici
- **Monitoring**: Status line DevOps, health checks, logging centralizzato

## Quick Start

### 1. Prepara la VPS

```bash
# Connettiti alla VPS
ssh root@<IP>

# Crea utente non-root
adduser devops
usermod -aG sudo devops

# Disconnettiti e riconnettiti come devops
exit
ssh devops@<IP>
```

### 2. Clona il Repository

```bash
git clone https://github.com/tuouser/vpshero.git
cd vpshero
```

### 3. Esegui Setup

```bash
chmod +x setup-vps.sh
./setup-vps.sh
```

Seleziona opzione **1** per setup completo.

### 4. Configura Claude Code

```bash
# Copia configurazioni
cp -r claude/* ~/.claude/

# Rendi eseguibili gli script
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/statusline-vps.sh

# Autentica Claude Code
claude
```

### 5. Configura GitHub CLI

```bash
gh auth login
```

### 6. Accedi a Dokploy

Apri nel browser: `http://<IP-VPS>:3000`

## Struttura del Progetto

```
vpshero/
├── setup-vps.sh              # Script di setup principale
├── configs/
│   ├── .zshrc                # Configurazione Zsh
│   └── starship.toml         # Configurazione Starship prompt
└── claude/
    ├── settings.json         # Settings Claude Code (VPS)
    ├── settings.local.json   # Template settings locali
    ├── statusline-vps.sh     # Status line DevOps
    ├── agents/               # Agenti specializzati
    │   ├── devops-engineer.md
    │   ├── security-auditor.md
    │   ├── incident-responder.md
    │   └── release-manager.md
    ├── commands/             # Slash commands
    │   ├── deploy.md
    │   ├── rollback.md
    │   ├── health.md
    │   ├── logs.md
    │   ├── dns.md
    │   ├── pr.md
    │   ├── workflow.md
    │   ├── backup.md
    │   └── dokploy.md
    ├── skills/               # Skills complesse
    │   ├── cicd-pipeline/
    │   ├── docker-ops/
    │   └── dns-management/
    └── hooks/                # Automazione sicura
        ├── session-init.sh
        ├── audit-log.sh
        ├── pre-deploy.sh
        └── protect-critical.sh
```

## Uso di Claude Code

### Slash Commands Disponibili

| Comando | Descrizione |
|---------|-------------|
| `/deploy <app> <env>` | Deploy applicazione |
| `/rollback <app>` | Rollback a versione precedente |
| `/health` | Health check del sistema |
| `/logs <service>` | Visualizza logs |
| `/dns <action> <domain>` | Gestione DNS e SSL |
| `/pr <action>` | Gestione Pull Request |
| `/workflow <action>` | Gestione GitHub Actions |
| `/backup <action>` | Gestione backup |
| `/dokploy <action>` | Gestione Dokploy |

### Agenti Specializzati

```bash
# DevOps Engineer - deployment e infrastruttura
> Usa @devops-engineer per deployare l'app su production

# Security Auditor - vulnerabilità e compliance
> Usa @security-auditor per fare un security scan

# Incident Responder - troubleshooting rapido
> Usa @incident-responder per analizzare l'outage

# Release Manager - versioning e release
> Usa @release-manager per preparare la release v2.0
```

### Skills

Le skills si attivano automaticamente in base al contesto:

- **cicd-pipeline**: Gestione pipeline CI/CD
- **docker-ops**: Operazioni Docker avanzate
- **dns-management**: Gestione DNS e SSL

## Mix di Modelli

La configurazione usa un mix intelligente di modelli per ottimizzare costi e performance:

| Modello | Uso | Costo Relativo |
|---------|-----|----------------|
| **Haiku** | DevOps routine, health checks, logs | Basso |
| **Sonnet** | Deploy, code review, troubleshooting | Medio |
| **Opus** | Security audit, planning critico | Alto |

I modelli sono configurati automaticamente per ogni agente e comando.

## Sicurezza

### Hooks Automatici

- **session-init.sh**: Log inizio sessione, setup ambiente
- **audit-log.sh**: Logging di tutte le operazioni
- **pre-deploy.sh**: Validazione prima di deploy
- **protect-critical.sh**: Protezione file critici

### File Protetti

I seguenti path sono automaticamente protetti:
- `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`
- `/root/.ssh`, `/.ssh`
- File con pattern: `*.pem`, `*.key`, `*secrets*`

### Audit Log

Tutte le operazioni sono loggate in:
- `/var/log/claude-audit.log` - Log testuale
- `/var/log/claude-audit.jsonl` - Log JSON strutturato

## Workflow Tipico

### Deploy di una Nuova App

```bash
# 1. Crea app in Dokploy
# Dashboard > Create Application > GitHub

# 2. Configura webhook (automatico con GitHub)

# 3. Deploy via Claude
/deploy myapp production

# 4. Verifica
/health
```

### Gestione Incidente

```bash
# 1. Quick assessment
/health

# 2. Logs del servizio
/logs myapp

# 3. Se necessario rollback
/rollback myapp

# 4. Analisi con agente
> @incident-responder analizza l'outage di myapp
```

### Release

```bash
# 1. Prepara release
> @release-manager prepara release v1.2.0

# 2. Crea PR
/pr create "Release v1.2.0"

# 3. Dopo merge, deploy automatico via webhook
```

## Personalizzazione

### Aggiungere un Nuovo Comando

Crea `~/.claude/commands/miocomando.md`:

```yaml
---
description: Descrizione del comando
argument-hint: <arg1> [arg2]
allowed-tools: Bash(comando:*), Read
model: haiku
---

# Mio Comando: $1

Esegui: !`comando $1`

Istruzioni per Claude...
```

### Aggiungere un Nuovo Agente

Crea `~/.claude/agents/mioagente.md`:

```yaml
---
name: mio-agente
description: Descrizione dell'agente
tools: Read, Bash, Glob
model: sonnet
---

# Mio Agente

Istruzioni per l'agente...
```

## Troubleshooting

### Claude Code non si connette

```bash
# Verifica autenticazione
claude --version
claude  # Dovrebbe aprire browser per auth
```

### Dokploy non raggiungibile

```bash
# Verifica container
docker ps | grep dokploy

# Restart se necessario
cd /root/.dokploy && docker compose restart

# Check logs
docker logs dokploy-dokploy-1
```

### Hook non funziona

```bash
# Verifica permessi
ls -la ~/.claude/hooks/

# Rendi eseguibile
chmod +x ~/.claude/hooks/*.sh

# Test manuale
echo '{"tool_name": "Bash"}' | ~/.claude/hooks/audit-log.sh
```

## Costi Stimati

| Componente | Costo Mensile |
|------------|---------------|
| Hetzner VPS 8GB | ~15 EUR |
| Claude API (mix) | ~20-50 USD |
| **Totale** | **~35-65 EUR/mese** |

## Licenza

MIT

## Contributing

PR benvenute! Per modifiche significative, apri prima una issue.
