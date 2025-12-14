---
description: Gestione DNS e certificati SSL
argument-hint: <action: check|verify|ssl-status|ssl-renew> <domain>
allowed-tools: Bash(dig:*), Bash(nslookup:*), Bash(curl:*), Bash(openssl:*), Bash(certbot:*), Read
model: sonnet
---

# DNS Management: $1 $2

**Action**: $1
**Domain**: $2
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

---

## DNS Resolution

### A Records
```
!`dig +short A $2 2>/dev/null || nslookup $2 | grep "Address" | tail -1`
```

### AAAA Records (IPv6)
```
!`dig +short AAAA $2 2>/dev/null || echo "No IPv6 record"`
```

### CNAME Records
```
!`dig +short CNAME $2 2>/dev/null || echo "No CNAME"`
```

### MX Records
```
!`dig +short MX $2 2>/dev/null || echo "No MX records"`
```

### TXT Records
```
!`dig +short TXT $2 2>/dev/null || echo "No TXT records"`
```

### NS Records
```
!`dig +short NS $2 2>/dev/null || echo "Could not resolve"`
```

---

## SSL/TLS Status

### Certificate Info
```
!`echo | openssl s_client -connect $2:443 -servername $2 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null || echo "Could not retrieve certificate"`
```

### Certificate Expiry
```
!`echo | openssl s_client -connect $2:443 -servername $2 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null || echo "N/A"`
```

### Days Until Expiry
```
!`echo | openssl s_client -connect $2:443 -servername $2 2>/dev/null | openssl x509 -noout -checkend 2592000 2>/dev/null && echo "Valid for >30 days" || echo "Expires within 30 days or invalid"`
```

---

## Connectivity Test

### HTTP Response
```
!`curl -sI -o /dev/null -w "HTTP Status: %{http_code}\nTime: %{time_total}s\nRedirect: %{redirect_url}" https://$2 2>/dev/null || echo "Could not connect"`
```

### HTTPS Certificate Chain
```
!`curl -sI -v https://$2 2>&1 | grep -E "SSL|subject|issuer|expire" | head -10 || echo "N/A"`
```

---

## Actions Available

### check
Verifica DNS resolution e mostra tutti i record

### verify
Verifica che il dominio punti a questo server
```bash
MY_IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(dig +short A $2)
[ "$MY_IP" = "$DOMAIN_IP" ] && echo "OK: Domain points to this server" || echo "WARNING: Domain points to $DOMAIN_IP, server is $MY_IP"
```

### ssl-status
Mostra stato certificato SSL/TLS

### ssl-renew
Rinnova certificato con Certbot
```bash
sudo certbot renew --cert-name $2
# oppure
sudo certbot certonly --nginx -d $2
```

---

## Common DNS Commands

```bash
# Full DNS lookup
dig $2 ANY

# Trace DNS resolution
dig +trace $2

# Reverse DNS
dig -x <IP>

# Check propagation (external)
dig @8.8.8.8 $2
dig @1.1.1.1 $2

# Clear DNS cache (local)
sudo systemd-resolve --flush-caches
```

## SSL Commands

```bash
# List certificates
sudo certbot certificates

# Renew all
sudo certbot renew

# Renew specific
sudo certbot renew --cert-name $2

# New certificate
sudo certbot certonly --nginx -d $2 -d www.$2

# Test renewal
sudo certbot renew --dry-run
```

---

## Summary

Basandoti sull'azione richiesta ($1), esegui le verifiche appropriate e fornisci:

1. **Status**: OK / WARNING / ERROR
2. **Details**: Informazioni rilevanti
3. **Actions**: Comandi da eseguire se necessario
