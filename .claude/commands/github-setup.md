---
description: Guida interattiva per collegare GitHub a Dokploy
allowed-tools: Bash(ssh:*), Bash(gh:*), Bash(curl:*), Read, WebFetch
model: sonnet
---

# GitHub + Dokploy Setup Guide

## Stato Attuale

**GitHub CLI**: !`gh auth status 2>&1 | head -3`
**Dokploy URL**: https://dokploy.yattalo.com

## Step 1: Verifica Prerequisiti

### GitHub CLI Autenticato?
```
!`gh auth status >/dev/null 2>&1 && echo "OK - GitHub CLI autenticato" || echo "WARN - Esegui: gh auth login"`
```

### Dokploy Raggiungibile?
```
!`curl -s -o /dev/null -w "%{http_code}" https://dokploy.yattalo.com 2>/dev/null | grep -q 200 && echo "OK - Dokploy raggiungibile" || echo "WARN - Dokploy non raggiungibile"`
```

## Step 2: Configura SSH Key

### Opzione A: SSH Key in Dokploy (Raccomandato)

1. **Accedi a Dokploy**: https://dokploy.yattalo.com
2. **Settings** (icona ingranaggio) -> **SSH Keys**
3. **Generate SSH Key** -> Nome: `github-deploy`
4. **Copia la chiave pubblica**
5. **Aggiungi a GitHub**: https://github.com/settings/keys
   - New SSH key -> Title: `Dokploy VPS`
   - Incolla chiave -> Add SSH key

### Opzione B: Usa SSH Key esistente della VPS

```bash
# Mostra chiave pubblica esistente
ssh hetzner-root "cat ~/.ssh/id_rsa.pub 2>/dev/null || cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo 'Nessuna chiave trovata - genera con: ssh-keygen -t ed25519'"
```

## Step 3: Test Connessione

```bash
ssh hetzner-root "ssh -T git@github.com 2>&1 | head -1"
```

Output atteso: `Hi <username>! You've successfully authenticated...`

## Step 4: Crea Prima App

1. **Dokploy Dashboard** -> **+ Create Project**
2. Nome: `my-first-app`
3. **+ Create Service** -> **Application**
4. **Source**: GitHub
5. **Repository**: `owner/repo-name` (formato SSH: git@github.com:owner/repo.git)
6. **Branch**: main
7. **Build Type**: Nixpacks (auto-detect) o Dockerfile
8. **Deploy**

## Step 5: Configura Dominio

1. Application -> **Domains**
2. **+ Add Domain**: `app.yattalo.com`
3. HTTPS: Enabled
4. Salva

## Step 6: Attiva CI/CD Webhook

1. Application -> **Deployments** -> Copia Webhook URL
2. GitHub Repo -> Settings -> Webhooks -> Add
3. Payload URL: incolla
4. Events: Push
5. Attiva

## Troubleshooting

### "Permission denied (publickey)"
- Verifica che la SSH key sia aggiunta a GitHub
- Verifica che Dokploy usi la chiave corretta

### "Repository not found"
- Verifica che il repo sia accessibile
- Se privato, verifica permessi SSH key

### Build fallisce
- Controlla Dockerfile/package.json
- Verifica variabili d'ambiente

## Prossimi Passi

Dopo aver completato il setup:
- `/deploy <app> production` - Deploy manuale
- `/logs <app>` - Controlla logs
- `/health` - Health check sistema
