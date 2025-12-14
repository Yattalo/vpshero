---
name: dns-management
description: Gestione DNS e certificati SSL/TLS. DNS configuration, SSL certificates, domain verification, troubleshooting.
allowed-tools: Bash(dig:*), Bash(nslookup:*), Bash(curl:*), Bash(openssl:*), Bash(certbot:*), Read, Edit
---

# DNS & SSL Management Skill

Questa skill fornisce expertise completa per gestire DNS e certificati SSL su VPS.

## Capabilities

### DNS Management
- Record verification (A, AAAA, CNAME, MX, TXT)
- DNS propagation check
- Reverse DNS
- Troubleshooting resolution

### SSL/TLS Certificates
- Let's Encrypt con Certbot
- Certificate verification
- Renewal automation
- Wildcard certificates

### Domain Configuration
- Subdomain setup
- Email configuration (MX, SPF, DKIM)
- Domain verification

## DNS Quick Reference

### Record Types

| Type | Purpose | Example |
|------|---------|---------|
| A | IPv4 address | `example.com -> 1.2.3.4` |
| AAAA | IPv6 address | `example.com -> 2001:db8::1` |
| CNAME | Alias | `www -> example.com` |
| MX | Mail server | `mail.example.com` |
| TXT | Text/verification | `v=spf1 include:...` |
| NS | Name server | `ns1.provider.com` |
| CAA | Certificate authority | `letsencrypt.org` |

### DNS Commands

```bash
# Basic lookup
dig example.com
dig +short example.com

# Specific record type
dig A example.com
dig AAAA example.com
dig MX example.com
dig TXT example.com
dig NS example.com
dig CAA example.com

# All records
dig ANY example.com

# Specific DNS server
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com

# Trace resolution path
dig +trace example.com

# Reverse DNS
dig -x 1.2.3.4

# Short output
dig +short A example.com

# Verbose output
dig +noall +answer example.com
```

### Alternative Tools

```bash
# nslookup
nslookup example.com
nslookup -type=MX example.com

# host
host example.com
host -t MX example.com

# Check propagation (multiple locations)
for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
  echo "=== $dns ==="
  dig @$dns +short example.com
done
```

## SSL/TLS Management

### Certbot Commands

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate (Nginx)
sudo certbot --nginx -d example.com -d www.example.com

# Obtain certificate (standalone)
sudo certbot certonly --standalone -d example.com

# Obtain certificate (webroot)
sudo certbot certonly --webroot -w /var/www/html -d example.com

# Wildcard certificate (requires DNS challenge)
sudo certbot certonly --manual --preferred-challenges dns \
  -d example.com -d "*.example.com"

# List certificates
sudo certbot certificates

# Renew all
sudo certbot renew

# Renew specific
sudo certbot renew --cert-name example.com

# Test renewal
sudo certbot renew --dry-run

# Delete certificate
sudo certbot delete --cert-name example.com
```

### Certificate Verification

```bash
# Check certificate details
openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | \
  openssl x509 -noout -text

# Check expiry date
openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | \
  openssl x509 -noout -dates

# Check certificate chain
openssl s_client -connect example.com:443 -servername example.com -showcerts

# Check specific fields
openssl s_client -connect example.com:443 2>/dev/null | \
  openssl x509 -noout -subject -issuer -dates

# Verify certificate file
openssl x509 -in /etc/letsencrypt/live/example.com/fullchain.pem -noout -text

# Check if certificate matches key
openssl x509 -noout -modulus -in cert.pem | openssl md5
openssl rsa -noout -modulus -in key.pem | openssl md5
# Should match!
```

### SSL Testing

```bash
# Test SSL configuration
curl -vI https://example.com 2>&1 | grep -E "SSL|subject|issuer|expire"

# Check SSL grade (via API)
curl -s "https://api.ssllabs.com/api/v3/analyze?host=example.com&startNew=on"

# Test specific TLS version
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3
```

## Common Configurations

### Nginx SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

### Traefik SSL (Dokploy default)

```yaml
# traefik.yml
certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

# docker-compose.yml label
labels:
  - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
```

## DNS for Email

### SPF Record
```
v=spf1 include:_spf.google.com ~all
v=spf1 mx a ip4:1.2.3.4 -all
```

### DKIM Record
```
default._domainkey.example.com TXT "v=DKIM1; k=rsa; p=MIGfMA0..."
```

### DMARC Record
```
_dmarc.example.com TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
```

### Verification

```bash
# Check SPF
dig TXT example.com | grep spf

# Check DKIM
dig TXT default._domainkey.example.com

# Check DMARC
dig TXT _dmarc.example.com

# Full email check
dig MX example.com
dig TXT example.com
```

## Troubleshooting

### DNS Not Resolving

```bash
# 1. Check if registered
whois example.com

# 2. Check nameservers
dig NS example.com

# 3. Query nameserver directly
dig @ns1.provider.com example.com

# 4. Check propagation
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com

# 5. Clear local cache
sudo systemd-resolve --flush-caches  # systemd
sudo dscacheutil -flushcache         # macOS
```

### SSL Certificate Issues

```bash
# Certificate expired?
openssl s_client -connect example.com:443 2>/dev/null | \
  openssl x509 -noout -checkend 0

# Wrong domain?
openssl s_client -connect example.com:443 2>/dev/null | \
  openssl x509 -noout -subject

# Chain incomplete?
openssl s_client -connect example.com:443 -showcerts

# Port blocked?
nc -zv example.com 443

# Certbot error?
sudo certbot certificates
cat /var/log/letsencrypt/letsencrypt.log
```

### Domain Pointing Elsewhere

```bash
# Current IP
dig +short example.com

# Expected IP
curl -s ifconfig.me

# If different, update DNS at registrar
```

## Automation

### Certbot Auto-Renewal (Cron)
```bash
# Already configured by certbot, but verify:
sudo systemctl status certbot.timer

# Manual cron if needed
0 0 * * * certbot renew --quiet --post-hook "systemctl reload nginx"
```

### Certificate Expiry Monitoring
```bash
#!/bin/bash
# /scripts/check-ssl.sh

DOMAINS="example.com www.example.com"
WARN_DAYS=30

for domain in $DOMAINS; do
  expiry=$(openssl s_client -connect $domain:443 -servername $domain 2>/dev/null | \
    openssl x509 -noout -enddate | cut -d= -f2)
  expiry_epoch=$(date -d "$expiry" +%s)
  now_epoch=$(date +%s)
  days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

  if [ $days_left -lt $WARN_DAYS ]; then
    echo "WARNING: $domain expires in $days_left days"
  fi
done
```

## Checklist

### New Domain Setup
- [ ] DNS A record pointing to server IP
- [ ] DNS propagation complete (check multiple locations)
- [ ] SSL certificate obtained
- [ ] HTTP to HTTPS redirect configured
- [ ] HSTS header enabled
- [ ] SSL grade A+ (test with ssllabs.com)

### Email Setup
- [ ] MX record configured
- [ ] SPF record added
- [ ] DKIM configured
- [ ] DMARC policy set
- [ ] Test with mail-tester.com
