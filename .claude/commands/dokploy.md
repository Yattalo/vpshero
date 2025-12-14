---
description: Gestione Dokploy - deployment, applicazioni, database, monitoring
argument-hint: <action: status|apps|logs|restart|backup|webhook> [args]
allowed-tools: Bash(docker:*), Bash(curl:*), Read
model: haiku
---

# Dokploy Management: $1

**Action**: $1
**Args**: $2 $3
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

---

## Dokploy Status

### Dashboard Access
```
URL: http://!`curl -s ifconfig.me`:3000
```

### Core Services
```
!`docker ps --filter "name=dokploy" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Dokploy containers not found"`
```

### Traefik (Reverse Proxy)
```
!`docker ps --filter "name=traefik" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Traefik not found"`
```

---

## Available Actions

### status - Stato generale Dokploy
```bash
# Core status
docker ps --filter "label=com.docker.compose.project=dokploy" --format "table {{.Names}}\t{{.Status}}"

# Check Dokploy health
curl -s http://localhost:3000/api/health || echo "API not responding"
```

### apps - Lista applicazioni deployate
```bash
# Via Docker labels (applicazioni Dokploy)
docker ps --filter "label=dokploy.enabled=true" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# All running services
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

### logs - Visualizza logs di un'app
```bash
# Dokploy core logs
docker logs --tail 50 dokploy-dokploy-1

# Traefik logs
docker logs --tail 50 dokploy-traefik-1

# App specific logs
docker logs --tail 100 $2
```

### restart - Riavvia un servizio
```bash
# Riavvia Dokploy
docker compose -f /root/.dokploy/docker-compose.yml restart

# Riavvia specifica app
docker restart $2

# Riavvia con recreate
docker compose -f /apps/$2/docker-compose.yml up -d --force-recreate
```

### backup - Backup configurazioni Dokploy
```bash
# Backup Dokploy data
mkdir -p /backups/dokploy
cp -r /root/.dokploy /backups/dokploy/dokploy-$(date +%Y%m%d)

# Backup database
docker exec dokploy-postgres-1 pg_dump -U dokploy dokploy > /backups/dokploy/db-$(date +%Y%m%d).sql
```

### webhook - Gestione webhook per CI/CD
```bash
# I webhook sono configurati nel dashboard Dokploy
# Per ogni applicazione: Settings > Webhooks

# Test webhook manualmente
curl -X POST "$DOKPLOY_WEBHOOK_URL"

# Lista webhook configurati
# Vai a: http://<IP>:3000 > Application > Settings > Webhooks
```

---

## Quick Commands

```bash
# Accedi al container Dokploy
docker exec -it dokploy-dokploy-1 /bin/sh

# Verifica connettività database
docker exec dokploy-postgres-1 psql -U dokploy -c "SELECT 1"

# Restart completo Dokploy
cd /root/.dokploy && docker compose down && docker compose up -d

# Aggiorna Dokploy
cd /root/.dokploy && docker compose pull && docker compose up -d

# Visualizza configurazione
cat /root/.dokploy/docker-compose.yml

# Logs live di Traefik (routing)
docker logs -f dokploy-traefik-1

# Check SSL certificates
docker exec dokploy-traefik-1 cat /letsencrypt/acme.json | jq '.letsencrypt.Certificates[].domain'
```

---

## Dokploy Architecture

```
                    Internet
                        │
                        ▼
┌───────────────────────────────────────┐
│              Traefik                   │
│         (Reverse Proxy + SSL)          │
│              Port 80/443               │
└───────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────┐   ┌───────────┐   ┌───────────┐
│  App 1    │   │  App 2    │   │  App 3    │
│ Container │   │ Container │   │ Container │
└───────────┘   └───────────┘   └───────────┘
                        │
                        ▼
┌───────────────────────────────────────┐
│           Dokploy Dashboard            │
│              Port 3000                 │
│       (Management + Postgres DB)       │
└───────────────────────────────────────┘
```

---

## Deployment via Dokploy

### 1. Da GitHub (Raccomandato)
1. Dashboard > Create Application
2. Seleziona "GitHub"
3. Autorizza e seleziona repo
4. Configura branch e build settings
5. Abilita Auto-Deploy per webhook automatico

### 2. Da Docker Image
1. Dashboard > Create Application
2. Seleziona "Docker"
3. Inserisci image name (es. `ghcr.io/user/app:latest`)
4. Configura environment variables
5. Deploy

### 3. Da Docker Compose
1. Dashboard > Create Compose
2. Upload docker-compose.yml
3. Configura variabili
4. Deploy

---

## Troubleshooting

### App non raggiungibile
```bash
# 1. Verifica container running
docker ps | grep <app-name>

# 2. Verifica Traefik routing
docker logs dokploy-traefik-1 | grep <domain>

# 3. Verifica DNS
dig +short <domain>

# 4. Verifica SSL
curl -vI https://<domain>
```

### Deploy fallito
```bash
# Verifica logs dell'app
docker logs <app-container>

# Verifica build logs (nel dashboard)
# Application > Deployments > View Logs

# Verifica risorse
docker stats --no-stream
df -h
free -h
```

### Dokploy non risponde
```bash
# Restart Dokploy
cd /root/.dokploy && docker compose restart

# Se persiste, full restart
cd /root/.dokploy && docker compose down && docker compose up -d

# Check logs
docker logs dokploy-dokploy-1
```

---

## Esegui Azione

Basandoti sull'azione richiesta ($1), esegui i comandi appropriati.

Per operazioni critiche (restart, backup), chiedi conferma prima di procedere.
