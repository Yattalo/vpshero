# Progetti Gestiti su Dokploy

Questo documento traccia i progetti deployati tramite VPSHero/Dokploy con le relative configurazioni.

---

## Pattern di Naming

| Ambiente | Pattern | Esempio |
|----------|---------|---------|
| **Staging** | `<codice>.yattalo.com` | `ees.yattalo.com` |
| **Production** | Dominio cliente | `eesystem-garda.it` |

> **Nota**: I sottodomini `yattalo.com` sono SEMPRE staging/preview. Il dominio di produzione è quello del cliente.

---

## Progetti Attivi

### EES (EESystem Garda)

| Campo | Valore |
|-------|--------|
| **Staging URL** | `ees.yattalo.com` |
| **Production URL** | `eesystem-garda.it` (TBD) |
| **Stack** | Next.js 15, TypeScript |
| **Hosting** | Dokploy |
| **Email Provider** | Siteground SMTP |
| **Email Domain** | `eesystem-garda.it` |

#### Configurazione Email (Siteground SMTP)

```bash
SMTP_HOST=mail.eesystem-garda.it
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=form@eesystem-garda.it
SMTP_PASS=<password_casella>
SMTP_FROM=form@eesystem-garda.it
SMTP_TO=info@eesystem-garda.it
```

**Caselle email:**
- `info@eesystem-garda.it` - Casella principale, destinatario form contatti
- `form@eesystem-garda.it` - Casella dedicata per invio automatico (da creare)

#### Note
- Form contatti usa Nodemailer con SMTP Siteground
- `Reply-To` impostato sull'email dell'utente per risposta diretta
- Dominio email già attivo su Siteground, sito in staging su yattalo.com

---

## Template per Nuovi Progetti

```markdown
### [Nome Progetto]

| Campo | Valore |
|-------|--------|
| **Staging URL** | `xxx.yattalo.com` |
| **Production URL** | `dominio-cliente.it` |
| **Stack** | ... |
| **Hosting** | Dokploy |
| **Email Provider** | ... |
| **Email Domain** | ... |

#### Configurazione Specifica
...

#### Note
...
```

---

## Checklist Go-Live (Staging → Production)

- [ ] Dominio cliente configurato DNS (A record verso VPS)
- [ ] SSL certificato generato (Let's Encrypt via Dokploy)
- [ ] Variabili d'ambiente production verificate
- [ ] Email transazionali testate
- [ ] Performance check completato
- [ ] Backup configurato
- [ ] Monitoring attivo
- [ ] Cliente ha approvato staging
