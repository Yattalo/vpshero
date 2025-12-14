---
description: Deploy applicazione su ambiente target con zero-downtime
argument-hint: <app-name> <environment: staging|production>
allowed-tools: Bash(git:*), Bash(docker:*), Bash(curl:*), Read, Glob
model: sonnet
---

# Deploy $1 to $2

## Pre-Deploy Check

**App**: $1
**Environment**: $2
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`
**Operator**: !`whoami`

### Current Status
```
Container Status: !`docker ps --filter name=$1 --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Container not found"`

Git Branch: !`cd /apps/$1 2>/dev/null && git branch --show-current || echo "N/A"`
Last Commit: !`cd /apps/$1 2>/dev/null && git log -1 --oneline || echo "N/A"`
```

### System Resources
```
Memory: !`free -h | grep Mem | awk '{print $3 "/" $2}'`
Disk: !`df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}'`
Load: !`cat /proc/loadavg | awk '{print $1, $2, $3}'`
```

## Deploy Procedure

Esegui il deployment seguendo questi step:

1. **Pull latest code** (se git-based)
   - `cd /apps/$1 && git fetch && git pull`

2. **Backup current state**
   - Salva tag corrente dell'immagine
   - `docker inspect $1 --format '{{.Config.Image}}' > /tmp/$1-backup-image.txt`

3. **Build new image** (se necessario)
   - `docker compose -f /apps/$1/docker-compose.yml build`

4. **Health check pre-deploy**
   - Verifica che il servizio attuale risponda

5. **Rolling update**
   - `docker compose -f /apps/$1/docker-compose.yml up -d --wait`

6. **Health check post-deploy**
   - Attendi 30 secondi
   - Verifica che il nuovo container risponda
   - Se fallisce, esegui rollback automatico

7. **Cleanup**
   - `docker image prune -f`

## Rollback Command
Se qualcosa va storto:
```bash
docker compose -f /apps/$1/docker-compose.yml down
docker run -d --name $1 $(cat /tmp/$1-backup-image.txt)
```

## Conferma

Prima di procedere, verifica:
- [ ] Ambiente corretto ($2)
- [ ] Backup disponibile
- [ ] Team notificato (se production)

Procedi con il deployment di $1 su $2?
