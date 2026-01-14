---
name: ssl-setup
description: Setup SSL certificates using Let's Encrypt Certbot. Use for enabling HTTPS on deployed applications.
---

# SSL Certificate Setup

Configure SSL using Let's Encrypt Certbot.

## Prerequisites

1. Domain DNS points to server IP
2. Nginx is installed and configured
3. Port 80 is accessible from internet

## Installation
```bash
apt install -y certbot python3-certbot-nginx
```

## Obtain Certificate

### For single domain
```bash
certbot --nginx -d domain.com --non-interactive --agree-tos --email admin@domain.com
```

### For domain with www
```bash
certbot --nginx -d domain.com -d www.domain.com --non-interactive --agree-tos --email admin@domain.com
```

### Staging (testing)
```bash
certbot --nginx -d domain.com --staging --non-interactive --agree-tos --email admin@domain.com
```

## Check DNS First
```bash
dig +short domain.com A
# Should return your server IP
```

## Verify Certificate
```bash
# Check certificate info
certbot certificates

# Test HTTPS
curl -I https://domain.com

# Check certificate details
echo | openssl s_client -connect domain.com:443 -servername domain.com 2>/dev/null | openssl x509 -noout -dates
```

## Auto-Renewal

Certbot sets up automatic renewal via systemd timer:
```bash
systemctl status certbot.timer
certbot renew --dry-run
```

## Manual Renewal
```bash
certbot renew
```

## Troubleshooting

### DNS not propagated
Wait 15-30 minutes, or use:
```bash
nslookup domain.com 8.8.8.8
```

### Port 80 blocked
Check firewall:
```bash
ufw allow 80
ufw allow 443
```

### Rate limits
Use staging for testing to avoid rate limits.
