---
description: Setup or renew SSL certificate using Let's Encrypt
allowed-tools: Read, Bash
argument-hint: [--renew] [--staging]
---

# SSL Certificate Management

Setup or renew SSL certificates using Let's Encrypt Certbot.

## Options

- `--renew`: Force certificate renewal
- `--staging`: Use Let's Encrypt staging (for testing)

## Prerequisites

- Domain DNS must point to server IP
- Nginx must be installed and configured
- Port 80 must be accessible

## Process

### 1. Check DNS
```bash
dig +short domain.com A
```

### 2. Verify Nginx Config
Ensure domain is configured in Nginx.

### 3. Obtain Certificate
```bash
certbot --nginx -d domain.com -d www.domain.com \
  --non-interactive --agree-tos \
  --email admin@domain.com
```

### 4. Verify SSL
```bash
curl -I https://domain.com
openssl s_client -connect domain.com:443 -servername domain.com
```

### 5. Setup Auto-Renewal
Certbot automatically sets up renewal via systemd timer.

## Troubleshooting

If certificate fails:
1. Check DNS propagation
2. Verify firewall allows port 80
3. Check Nginx error logs
4. Try staging first with `--staging`
