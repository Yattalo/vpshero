# Flusso Completo: Da GitHub Repository ad App Deployata

## Overview

Questo documento descrive il flusso completo per deployare un'applicazione dalla A alla Z usando VPSHero + Dokploy.

```
+-------------+     +----------+     +------------+     +----------+     +------------------+
|   GitHub    | --> |  Webhook | --> |  Dokploy   | --> |  Docker  | --> | App Live + SSL   |
|   Push      |     |  Trigger |     |  Build     |     |  Deploy  |     | dominio.com      |
+-------------+     +----------+     +------------+     +----------+     +------------------+
```

## Prerequisiti

| Componente | Stato | Verifica |
|------------|-------|----------|
| VPS Ubuntu | Configurata | `ssh hetzner-root` |
| Dokploy | Running | https://dokploy.yattalo.com |
| GitHub Account | Autenticato | `gh auth status` |
| Dominio | Configurato DNS | `dig dominio.com` |
| Claude Code | Installato | `claude --version` |

---

## FASE 1: Connessione GitHub a Dokploy

### Metodo A: SSH Keys (Raccomandato)

**Step 1.1: Genera SSH Key in Dokploy**
1. Accedi a https://dokploy.yattalo.com
2. Vai su **Settings** (ingranaggio in basso a sinistra)
3. Clicca su **SSH Keys**
4. Clicca **"Generate SSH Key"**
5. Dai un nome descrittivo (es: "github-deploy")
6. Copia la **chiave pubblica** mostrata

**Step 1.2: Aggiungi a GitHub**
1. Vai su https://github.com/settings/keys
2. Clicca **"New SSH key"**
3. Title: `Dokploy VPS`
4. Key type: `Authentication Key`
5. Incolla la chiave pubblica
6. Clicca **"Add SSH key"**

**Step 1.3: Verifica Connessione**
```bash
# Da VPS
ssh -T git@github.com
# Output atteso: "Hi username! You've successfully authenticated..."
```

### Metodo B: GitHub App (per organizzazioni)

**Step 1.1: Crea GitHub App**
1. Vai su https://github.com/settings/apps
2. Clicca **"New GitHub App"**
3. Compila:
   - Nome: `Dokploy-VPSHero`
   - Homepage: `https://dokploy.yattalo.com`
   - Callback URL: `https://dokploy.yattalo.com/api/auth/callback/github`
4. Permessi:
   - Repository: Read & Write
   - Webhooks: Read & Write
5. Crea e salva Client ID + Client Secret

**Step 1.2: Configura in Dokploy**
1. Settings -> Git Providers -> Add Provider
2. Seleziona GitHub
3. Inserisci Client ID e Secret

---

## FASE 2: Creazione Progetto in Dokploy

### Step 2.1: Crea Nuovo Progetto
1. Dashboard Dokploy -> **"+ Create Project"**
2. Nome progetto: es. `myapp-production`
3. Descrizione: `Production deployment for MyApp`

### Step 2.2: Crea Applicazione
1. Dentro il progetto -> **"+ Create Service"** -> **"Application"**
2. Seleziona tipo:
   - **Docker Compose** (se hai docker-compose.yml)
   - **Dockerfile** (se hai Dockerfile)
   - **Nixpacks** (build automatico per Node, Python, Go, etc.)

### Step 2.3: Configura Sorgente Git
1. Source: **GitHub**
2. Repository: `username/repo-name`
3. Branch: `main` (o `production`)
4. Build Path: `/` (o path del Dockerfile)

### Step 2.4: Configura Build
Per **Dockerfile**:
```
Build Context: .
Dockerfile Path: Dockerfile
```

Per **Docker Compose**:
```
Compose Path: docker-compose.yml
```

Per **Nixpacks** (auto-detect):
```
# Nessuna configurazione necessaria
# Rileva automaticamente il framework
```

---

## FASE 3: Configurazione Dominio e SSL

### Step 3.1: Aggiungi Record DNS

**Via Claude Code:**
```bash
/dns check mydomain.com
```

**Via Netlify CLI (o altro provider):**
```bash
# Crea record A
netlify api createDnsRecord --data '{
  "zone_id": "<zone-id>",
  "body": {"type": "A", "hostname": "app", "value": "<VPS-IP>", "ttl": 300}
}'
```

**Via UI Provider DNS:**
| Record | Type | Value | TTL |
|--------|------|-------|-----|
| app.mydomain.com | A | 77.42.34.88 | 300 |

### Step 3.2: Configura Dominio in Dokploy
1. Application -> **Domains** tab
2. Clicca **"+ Add Domain"**
3. Inserisci: `app.mydomain.com`
4. HTTPS: **Enabled** (Let's Encrypt automatico)
5. Salva

### Step 3.3: Verifica SSL
```bash
# Attendi 1-2 minuti per certificato Let's Encrypt
curl -I https://app.mydomain.com
# Output atteso: HTTP/2 200
```

---

## FASE 4: Deploy Automatico (CI/CD)

### Step 4.1: Configura Webhook
1. Application -> **Deployments** tab
2. Copia il **Webhook URL** mostrato
3. Vai su GitHub -> Repository -> Settings -> Webhooks
4. **"Add webhook"**
5. Payload URL: incolla URL copiato
6. Content type: `application/json`
7. Events: `Just the push event`
8. Attiva webhook

### Step 4.2: Test Deploy Automatico
```bash
# Fai una modifica al codice
git add .
git commit -m "Test deploy automatico"
git push origin main

# Monitora in Dokploy
# Dashboard -> Application -> Deployments
```

### Step 4.3: Verifica
```bash
# Via Claude Code
/logs myapp

# Via curl
curl https://app.mydomain.com/health
```

---

## FASE 5: Variabili d'Ambiente

### Step 5.1: Configura Environment Variables
1. Application -> **Environment** tab
2. Aggiungi variabili:
```
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@host:5432/db
API_KEY=xxx
```
3. Clicca **"Save"**

### Step 5.2: Secrets Sicuri
Per variabili sensibili, usa la crittografia di Dokploy:
- Le variabili sono criptate at-rest
- Mai committare secrets in git

---

## FASE 6: Monitoraggio e Logs

### Via Claude Code
```bash
# Health check sistema
/health

# Logs applicazione
/logs myapp

# Status Dokploy
/dokploy status
```

### Via Dokploy Dashboard
- **Deployments**: storico deploy
- **Logs**: stdout/stderr container
- **Metrics**: CPU, memoria, network

### Alerting
Configura notifiche in Settings -> Notifications:
- Slack
- Discord
- Email

---

## FASE 7: Rollback

### Rollback Rapido via Claude
```bash
/rollback myapp
```

### Rollback Manuale via Dokploy
1. Application -> Deployments
2. Trova deploy precedente funzionante
3. Clicca **"Redeploy"**

### Rollback Git
```bash
git revert HEAD
git push origin main
# Webhook triggera nuovo deploy
```

---

## Flusso Completo Visualizzato

```
                                    DEVELOPER WORKFLOW
                                    ==================

    LOCAL                          GITHUB                         VPS
    -----                          ------                         ---

+------------+                 +-------------+               +-------------+
|   Code     |    git push     |   GitHub    |   webhook     |   Dokploy   |
|   Editor   | --------------> |   Repo      | ------------> |   Server    |
+------------+                 +-------------+               +-------------+
                                     |                             |
                                     |                             v
                                     |                       +-------------+
                                     |                       |   Docker    |
                                     |                       |   Build     |
                                     |                       +-------------+
                                     |                             |
                                     |                             v
                                     |                       +-------------+
                                     |                       |   Traefik   |
                                     |                       |   Reverse   |
                                     |                       |   Proxy     |
                                     |                       +-------------+
                                     |                             |
                                     |                             v
                                     |                       +-------------+
                                     +---------------------->|   HTTPS     |
                                        PR review/merge      |   app.com   |
                                                             +-------------+


                                    ENVIRONMENTS
                                    ============

    +------------------+     +------------------+     +------------------+
    |     feature/*    |     |      main        |     |   production     |
    |                  |     |                  |     |                  |
    |   Development    | --> |     Staging      | --> |    Production    |
    |   Local/Preview  |     |   Auto-deploy    |     |   Manual/Auto    |
    +------------------+     +------------------+     +------------------+
```

---

## Checklist Deploy Completo

### Pre-Deploy
- [ ] Repository configurato su GitHub
- [ ] SSH Key Dokploy aggiunta a GitHub
- [ ] Dockerfile/docker-compose.yml presente
- [ ] Record DNS creato e propagato
- [ ] Environment variables configurate

### Deploy
- [ ] Applicazione creata in Dokploy
- [ ] Sorgente Git configurata
- [ ] Build riuscito
- [ ] Container running
- [ ] Dominio configurato
- [ ] SSL attivo

### Post-Deploy
- [ ] Health check passato
- [ ] Logs senza errori
- [ ] Performance accettabili
- [ ] Monitoring attivo
- [ ] Webhook configurato per CI/CD

---

## Troubleshooting Comune

### Build Fallisce
```bash
# Controlla logs build
docker logs $(docker ps -aq --filter name=dokploy-build)

# Verifica Dockerfile
docker build -t test .
```

### SSL Non Funziona
```bash
# Verifica DNS propagato
dig app.mydomain.com +short

# Verifica porta 80/443 aperta
sudo ufw status

# Restart Traefik
docker restart traefik
```

### Container Crash
```bash
# Logs container
docker logs <container-id>

# Memory issues
docker stats

# Restart
docker restart <container-name>
```

### Webhook Non Triggera
1. GitHub -> Repo -> Settings -> Webhooks
2. Verifica "Recent Deliveries"
3. Check response code (200 = OK)
4. Verifica URL corretto

---

## Comandi Rapidi VPSHero

| Azione | Comando |
|--------|---------|
| Health check | `/health` |
| Logs app | `/logs <app>` |
| Deploy | `/deploy <app> <env>` |
| Rollback | `/rollback <app>` |
| DNS check | `/dns check <domain>` |
| Dokploy status | `/dokploy status` |
| PR create | `/pr create` |
| Workflow | `/workflow list` |

---

## Riferimenti

- Dokploy Docs: https://docs.dokploy.com
- Traefik Docs: https://doc.traefik.io/traefik/
- Docker Compose: https://docs.docker.com/compose/
- Let's Encrypt: https://letsencrypt.org/docs/
