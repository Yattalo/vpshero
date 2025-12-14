---
description: Rollback applicazione a versione precedente
argument-hint: <app-name> [version-tag]
allowed-tools: Bash(docker:*), Read
model: haiku
---

# Rollback $1

## Current State

**App**: $1
**Requested Version**: ${2:-previous}
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

### Current Container
```
!`docker ps --filter name=$1 --format "Name: {{.Names}}\nImage: {{.Image}}\nStatus: {{.Status}}\nCreated: {{.RunningFor}}" 2>/dev/null || echo "Container not running"`
```

### Available Images
```
!`docker images "*$1*" --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}" 2>/dev/null | head -10 || echo "No images found"`
```

### Backup Image (if available)
```
!`cat /tmp/$1-backup-image.txt 2>/dev/null || echo "No backup found"`
```

## Rollback Procedure

1. **Stop current container**
   ```bash
   docker stop $1
   ```

2. **Remove current container**
   ```bash
   docker rm $1
   ```

3. **Start previous version**
   - Se version specificata: usa quella
   - Altrimenti: usa backup o tag :previous

4. **Verify health**
   - Attendi startup
   - Verifica risposta

## Quick Rollback Commands

```bash
# Rollback to specific tag
docker compose -f /apps/$1/docker-compose.yml down
docker compose -f /apps/$1/docker-compose.yml up -d --pull never

# Rollback using backup
BACKUP_IMAGE=$(cat /tmp/$1-backup-image.txt)
docker run -d --name $1 $BACKUP_IMAGE
```

## Post-Rollback

- [ ] Verifica funzionamento
- [ ] Notifica team
- [ ] Investiga causa del problema
- [ ] Documenta incidente

Procedi con il rollback di $1?
