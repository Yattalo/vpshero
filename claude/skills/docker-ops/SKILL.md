---
name: docker-ops
description: Operazioni Docker avanzate. Container management, networking, volumes, compose orchestration, troubleshooting.
allowed-tools: Bash(docker:*), Read, Edit, Glob
---

# Docker Operations Skill

Questa skill fornisce expertise completa per operazioni Docker su VPS.

## Capabilities

### Container Management
- Lifecycle: create, start, stop, restart, remove
- Logs e debugging
- Resource limits
- Health checks

### Image Management
- Build ottimizzati
- Multi-stage builds
- Registry push/pull
- Image cleanup

### Networking
- Network creation
- Container communication
- Port mapping
- DNS configuration

### Volume Management
- Named volumes
- Bind mounts
- Volume backup/restore
- Data migration

### Docker Compose
- Multi-container apps
- Service orchestration
- Environment management
- Scaling

## Quick Reference

### Container Commands
```bash
# Lista container
docker ps                    # Running
docker ps -a                 # All
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Lifecycle
docker start <name>
docker stop <name>
docker restart <name>
docker rm <name>
docker rm -f <name>          # Force

# Logs
docker logs <name>
docker logs -f <name>        # Follow
docker logs --tail 100 <name>
docker logs --since 1h <name>

# Exec
docker exec -it <name> /bin/bash
docker exec -it <name> /bin/sh
docker exec <name> command

# Inspect
docker inspect <name>
docker inspect --format '{{.State.Status}}' <name>
docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <name>

# Stats
docker stats
docker stats --no-stream
docker top <name>
```

### Image Commands
```bash
# Lista
docker images
docker images -a

# Build
docker build -t myapp:latest .
docker build -t myapp:v1.0 -f Dockerfile.prod .
docker build --no-cache -t myapp:latest .

# Tag
docker tag myapp:latest registry/myapp:v1.0

# Push/Pull
docker push registry/myapp:v1.0
docker pull registry/myapp:v1.0

# Cleanup
docker image prune -f          # Dangling
docker image prune -af         # All unused
docker rmi <image>
```

### Network Commands
```bash
# Lista
docker network ls

# Create
docker network create mynet
docker network create --driver bridge mynet

# Connect/Disconnect
docker network connect mynet <container>
docker network disconnect mynet <container>

# Inspect
docker network inspect mynet
```

### Volume Commands
```bash
# Lista
docker volume ls

# Create
docker volume create mydata

# Inspect
docker volume inspect mydata

# Remove
docker volume rm mydata
docker volume prune -f         # All unused

# Backup volume
docker run --rm -v mydata:/source:ro -v $(pwd):/backup alpine \
  tar czf /backup/mydata-backup.tar.gz -C /source .

# Restore volume
docker run --rm -v mydata:/target -v $(pwd):/backup alpine \
  tar xzf /backup/mydata-backup.tar.gz -C /target
```

### Docker Compose
```bash
# Start
docker compose up -d
docker compose up -d --build   # Rebuild
docker compose up -d --force-recreate

# Stop
docker compose down
docker compose down -v         # Remove volumes too

# Logs
docker compose logs
docker compose logs -f <service>

# Scale
docker compose up -d --scale web=3

# Exec
docker compose exec <service> /bin/bash

# Status
docker compose ps
docker compose top
```

## Dockerfile Best Practices

### Multi-stage Build (Node.js)
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
CMD ["node", "server.js"]
```

### Multi-stage Build (Python)
```dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim
WORKDIR /app
RUN useradd --create-home appuser
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

## Docker Compose Templates

### Web App + Database
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=mydb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

### With Traefik Reverse Proxy
```yaml
version: '3.8'

services:
  app:
    build: .
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
    networks:
      - traefik

networks:
  traefik:
    external: true
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker logs <name>

# Check events
docker events --filter container=<name>

# Check config
docker inspect <name>

# Try interactive
docker run -it <image> /bin/sh
```

### Out of Disk Space
```bash
# Check usage
docker system df

# Cleanup
docker system prune -af --volumes

# Remove old images
docker images | grep "weeks ago" | awk '{print $3}' | xargs docker rmi
```

### Network Issues
```bash
# Check container network
docker inspect <name> | grep -A 20 NetworkSettings

# Test connectivity
docker exec <name> ping other-container
docker exec <name> nslookup other-container

# Check DNS
docker exec <name> cat /etc/resolv.conf
```

### High Memory Usage
```bash
# Check stats
docker stats --no-stream

# Add memory limit
docker update --memory 512m <name>

# In compose
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
```

## Security Checklist

- [ ] Non eseguire come root (USER directive)
- [ ] Usare immagini ufficiali/verificate
- [ ] Specificare versioni (no :latest in prod)
- [ ] Scansionare vulnerabilità (docker scout)
- [ ] Limitare risorse (memory, CPU)
- [ ] Usare read-only filesystem dove possibile
- [ ] Non esporre socket Docker
- [ ] Usare secrets per credenziali
