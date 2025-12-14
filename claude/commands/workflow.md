---
description: Gestione GitHub Actions workflows
argument-hint: <action: list|run|view|logs> [workflow] [args]
allowed-tools: Bash(gh:*), Read
model: haiku
---

# GitHub Workflow: $1

**Action**: $1
**Workflow**: $2
**Args**: $3 $4
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

---

## Repository Info

```
!`gh repo view --json name,url,defaultBranchRef --jq '"\(.name) - \(.url)\nDefault branch: \(.defaultBranchRef.name)"' 2>/dev/null || echo "Not in a GitHub repo"`
```

---

## Workflow Actions

### list - Lista workflows
```
!`gh workflow list 2>/dev/null || echo "No workflows found or not authenticated"`
```

### run - Esegui workflow
```bash
# Run workflow
gh workflow run "$2" --ref ${3:-main}

# Run with inputs
gh workflow run "$2" --ref main -f param1=value1 -f param2=value2
```

### view - Visualizza workflow runs
```
!`gh run list --workflow="$2" --limit 10 2>/dev/null || gh run list --limit 10`
```

### logs - Vedi logs di un run
```bash
# Logs dell'ultimo run
gh run view --log

# Logs di un run specifico
gh run view $2 --log

# Solo errori
gh run view $2 --log-failed
```

---

## Recent Runs

### Latest Runs (all workflows)
```
!`gh run list --limit 10 2>/dev/null || echo "Could not fetch runs"`
```

### Failed Runs
```
!`gh run list --status failure --limit 5 2>/dev/null || echo "No failed runs"`
```

### In Progress
```
!`gh run list --status in_progress 2>/dev/null || echo "No runs in progress"`
```

---

## Quick Commands

```bash
# Lista tutti i workflow
gh workflow list

# Abilita/disabilita workflow
gh workflow enable <workflow>
gh workflow disable <workflow>

# Vedi workflow file
gh workflow view <workflow>

# Esegui workflow manualmente
gh workflow run <workflow>

# Esegui con branch specifico
gh workflow run <workflow> --ref feature-branch

# Vedi run specifico
gh run view <run-id>

# Watch run in real-time
gh run watch <run-id>

# Re-run failed jobs
gh run rerun <run-id> --failed

# Cancel run
gh run cancel <run-id>

# Download artifacts
gh run download <run-id>
```

---

## Workflow Status Icons

- `completed` - Run completato con successo
- `failure` - Run fallito
- `in_progress` - Run in corso
- `queued` - Run in coda
- `cancelled` - Run cancellato

---

## Debugging Failed Runs

```bash
# 1. Trova run fallito
gh run list --status failure --limit 1

# 2. Vedi dettagli
gh run view <run-id>

# 3. Vedi logs degli step falliti
gh run view <run-id> --log-failed

# 4. Re-run se transient failure
gh run rerun <run-id>
```

---

## Common Workflow Triggers

```yaml
# Push to main
on:
  push:
    branches: [main]

# Pull request
on:
  pull_request:
    branches: [main]

# Manual trigger
on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [staging, production]

# Schedule
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

# Release
on:
  release:
    types: [published]
```

---

## Esegui Azione

Basandoti su $1, esegui l'azione appropriata sul workflow $2.
