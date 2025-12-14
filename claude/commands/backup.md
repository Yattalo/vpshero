---
description: Gestione backup di container, volumi e configurazioni
argument-hint: <action: create|list|restore> <target>
allowed-tools: Bash(docker:*), Bash(tar:*), Bash(cp:*), Bash(ls:*), Read
model: sonnet
---

# Backup Management: $1 $2

**Action**: $1
**Target**: $2
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`
**Backup Dir**: /backups

---

## Current Backup Status

### Existing Backups
```
!`ls -lh /backups/ 2>/dev/null | tail -20 || echo "Backup directory not found. Create with: mkdir -p /backups"`
```

### Disk Space
```
!`df -h /backups 2>/dev/null || df -h /`
```

---

## Backup Actions

### create - Crea nuovo backup

#### Docker Volume Backup
```bash
# Backup di un volume Docker
docker run --rm \
  -v $2:/source:ro \
  -v /backups:/backup \
  alpine tar czf /backup/$2-$(date +%Y%m%d_%H%M%S).tar.gz -C /source .
```

#### Container Config Backup
```bash
# Esporta configurazione container
docker inspect $2 > /backups/$2-config-$(date +%Y%m%d_%H%M%S).json

# Esporta immagine
docker save $2 | gzip > /backups/$2-image-$(date +%Y%m%d_%H%M%S).tar.gz
```

#### Database Backup (PostgreSQL)
```bash
docker exec $2 pg_dump -U postgres dbname | gzip > /backups/$2-db-$(date +%Y%m%d_%H%M%S).sql.gz
```

#### Database Backup (MySQL)
```bash
docker exec $2 mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases | gzip > /backups/$2-db-$(date +%Y%m%d_%H%M%S).sql.gz
```

#### Full App Backup
```bash
# Backup completo di un'app (config + volumes)
mkdir -p /backups/$2-$(date +%Y%m%d)
docker inspect $2 > /backups/$2-$(date +%Y%m%d)/config.json
cp -r /apps/$2/docker-compose.yml /backups/$2-$(date +%Y%m%d)/
cp -r /apps/$2/.env /backups/$2-$(date +%Y%m%d)/ 2>/dev/null || true
```

### list - Lista backup disponibili
```bash
# Per target specifico
ls -lh /backups/$2* 2>/dev/null || echo "No backups for $2"

# Tutti i backup
ls -lh /backups/
```

### restore - Ripristina da backup

#### Restore Volume
```bash
docker run --rm \
  -v $2:/target \
  -v /backups:/backup:ro \
  alpine sh -c "cd /target && tar xzf /backup/<backup-file>.tar.gz"
```

#### Restore Database
```bash
# PostgreSQL
gunzip -c /backups/<backup-file>.sql.gz | docker exec -i $2 psql -U postgres

# MySQL
gunzip -c /backups/<backup-file>.sql.gz | docker exec -i $2 mysql -u root -p$MYSQL_ROOT_PASSWORD
```

#### Restore Image
```bash
docker load < /backups/<image-backup>.tar.gz
```

---

## Automated Backup Script

Crea `/scripts/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Backup all running containers
for container in $(docker ps --format "{{.Names}}"); do
    echo "Backing up $container..."
    docker inspect $container > "$BACKUP_DIR/${container}-config-${DATE}.json"
done

# Backup specific volumes
for vol in pgdata redis-data; do
    if docker volume inspect $vol &>/dev/null; then
        echo "Backing up volume $vol..."
        docker run --rm -v $vol:/source:ro -v $BACKUP_DIR:/backup alpine \
            tar czf "/backup/${vol}-${DATE}.tar.gz" -C /source .
    fi
done

# Cleanup old backups
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete

echo "Backup completed at $DATE"
```

---

## Cron Schedule

```bash
# Backup giornaliero alle 3:00
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# Backup settimanale (domenica) con retention estesa
0 4 * * 0 /scripts/backup-weekly.sh >> /var/log/backup.log 2>&1
```

---

## Verifica Backup

```bash
# Verifica integrità tar
tar tzf /backups/<file>.tar.gz > /dev/null && echo "OK" || echo "CORRUPTED"

# Verifica dimensione
ls -lh /backups/<file>

# Test restore (in container temporaneo)
docker run --rm -v /backups:/backup:ro alpine tar tzf /backup/<file>.tar.gz | head
```

---

## Esegui Azione

Basandoti su $1 e $2, esegui l'operazione di backup appropriata.

**IMPORTANTE**: Prima di restore, verifica sempre che il backup sia integro e recente.
