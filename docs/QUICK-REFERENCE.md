# VPSHero Quick Reference Card

## Accessi

| Servizio | URL | Metodo |
|----------|-----|--------|
| Dokploy Dashboard | https://dokploy.yattalo.com | Browser |
| VPS SSH | `ssh hetzner-root` | Terminal |
| GitHub | https://github.com | Browser/CLI |

## Flusso Deploy in 5 Minuti

```
1. GITHUB REPO         2. DOKPLOY              3. LIVE
   git push       -->     auto-build     -->     https://app.yattalo.com
                          auto-deploy
```

### Step-by-Step

```bash
# 1. Crea app in Dokploy (una volta)
#    Dashboard -> Create Project -> Create Application -> GitHub

# 2. Configura webhook (una volta)
#    Application -> Deployments -> Copy Webhook -> Add to GitHub

# 3. Deploy (automatico dopo setup)
git add . && git commit -m "feature" && git push
# Dokploy builda e deploya automaticamente

# 4. Verifica
curl https://app.yattalo.com/health
```

## Comandi Claude Code

### Deploy & Ops
```bash
/health                    # System health check
/deploy <app> production   # Manual deploy
/rollback <app>            # Rollback to previous
/logs <app> 50             # View last 50 logs
```

### Git & GitHub
```bash
/pr create                 # Create pull request
/pr list                   # List open PRs
/workflow list             # List GitHub Actions
/workflow run <name>       # Trigger workflow
```

### Dokploy
```bash
/dokploy status            # Container status
/dokploy apps              # List applications
/dokploy logs <app>        # App logs
/dokploy restart <app>     # Restart app
```

### DNS & SSL
```bash
/dns check <domain>        # Verify DNS
/dns ssl-status <domain>   # Check SSL cert
/dns ssl-renew <domain>    # Force SSL renewal
```

### Backup
```bash
/backup create <target>    # Create backup
/backup list               # List backups
/backup restore <id>       # Restore backup
```

## Environment Cheatsheet

### Variabili Comuni
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/db
REDIS_URL=redis://localhost:6379
```

### Dokploy Internal Networks
```
dokploy-network    # Main overlay network
traefik            # Reverse proxy
postgres           # Database (if using Dokploy DB)
redis              # Cache (if using Dokploy Redis)
```

## Struttura Tipica Progetto

```
myapp/
├── Dockerfile           # Build instructions
├── docker-compose.yml   # Multi-container setup
├── .env.example         # Environment template
├── package.json         # Dependencies (Node)
├── requirements.txt     # Dependencies (Python)
└── src/                 # Application code
```

### Dockerfile Minimo (Node.js)
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js"]
```

### Dockerfile Minimo (Python)
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0"]
```

## Troubleshooting Rapido

| Problema | Soluzione |
|----------|-----------|
| Build fallisce | Check Dockerfile, logs build |
| Container crash | `docker logs <id>`, check memory |
| SSL non funziona | Verifica DNS propagato, restart traefik |
| Webhook non triggera | Check GitHub webhook deliveries |
| App non risponde | Check port mapping, firewall |

## Numeri Utili

| Risorsa | Valore |
|---------|--------|
| VPS IP | 77.42.34.88 |
| Dokploy Port | 3000 (internal) |
| HTTP | 80 |
| HTTPS | 443 |
| SSH | 22 |

## Link Utili

- [Dokploy Docs](https://docs.dokploy.com)
- [Docker Hub](https://hub.docker.com)
- [Let's Encrypt](https://letsencrypt.org)
- [Traefik Docs](https://doc.traefik.io/traefik/)
