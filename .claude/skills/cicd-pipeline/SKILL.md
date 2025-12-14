---
name: cicd-pipeline
description: Gestisce pipeline CI/CD complete con GitHub Actions e Dokploy. Usa per setup pipeline, debug workflow, ottimizzazione build, gestione secrets.
allowed-tools: Read, Bash, Edit, Glob, Grep, Write
---

# CI/CD Pipeline Management Skill

Questa skill fornisce expertise completa per gestire pipeline CI/CD con GitHub Actions e integrazione Dokploy.

## Capabilities

### Pipeline Setup
- Creare workflow GitHub Actions da zero
- Configurare build multi-stage
- Setup test automation
- Configurare deployment automatici

### Pipeline Debug
- Analizzare workflow falliti
- Identificare bottleneck
- Risolvere problemi di caching
- Debug dependency issues

### Pipeline Optimization
- Ottimizzare tempi di build
- Configurare caching efficace
- Parallelizzare jobs
- Ridurre costi di CI

### Secrets Management
- Configurare GitHub Secrets
- Gestire environment variables
- Rotazione secrets sicura

## File Patterns

Questa skill lavora principalmente con:
- `.github/workflows/*.yml`
- `Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- `package.json` / `pyproject.toml`
- `.env.example`

## Workflow Templates

### Node.js CI/CD
```yaml
name: Node.js CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Dokploy
        run: |
          curl -X POST "${{ secrets.DOKPLOY_WEBHOOK_URL }}"
```

### Python CI/CD
```yaml
name: Python CI/CD

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Lint with ruff
        run: ruff check .

      - name: Type check with mypy
        run: mypy .

      - name: Test with pytest
        run: pytest --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
```

### Docker Build & Push
```yaml
name: Docker Build

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Dokploy Integration

### Webhook Setup
1. Nel Dokploy dashboard: Application > Settings > Webhooks
2. Copia webhook URL
3. Aggiungi come GitHub Secret: `DOKPLOY_WEBHOOK_URL`

### Auto-Deploy Trigger
```yaml
- name: Trigger Dokploy Deployment
  run: |
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${{ secrets.DOKPLOY_WEBHOOK_URL }}")
    if [ "$response" != "200" ]; then
      echo "Deployment trigger failed with status $response"
      exit 1
    fi
```

## Caching Strategies

### Node.js
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
```

### Python
```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'
```

### Docker Layer Caching
```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Best Practices

1. **Fast Feedback**: Metti lint/format prima dei test
2. **Fail Fast**: Usa `continue-on-error: false`
3. **Parallelizza**: Usa matrix per test multi-versione
4. **Cache Everything**: npm, pip, docker layers
5. **Secrets Sicuri**: Mai hardcode, usa GitHub Secrets
6. **Branch Protection**: Richiedi CI pass per merge

## Troubleshooting

### Build Lento
- Verifica caching attivo
- Considera self-hosted runners
- Parallelizza job indipendenti

### Test Flaky
- Aggiungi retry
- Isola test problematici
- Verifica race conditions

### Deployment Fallito
- Check webhook URL
- Verifica secrets
- Check logs Dokploy
