---
description: Configure DNS records for your domain via Timeweb
allowed-tools: Read, Bash
argument-hint: <domain> [--server-id ID]
---

# DNS Setup

Configure DNS A records to point your domain to the Timeweb server.

## Prerequisites

- Domain must be registered in Timeweb or DNS managed by Timeweb
- Server must exist (get IP from `.deploy.yml` or specify `--server-id`)

## Process

### 1. Get Server IP

```bash
# From .deploy.yml
SERVER_IP=$(grep "^server:" .deploy.yml | awk '{print $2}')

# Or from Timeweb API if --server-id specified
# mcp__timeweb__timeweb_get_server
```

### 2. Check Domain in Timeweb

```
mcp__timeweb__timeweb_get_domain
  fqdn: example.com
```

If domain not in Timeweb, show instructions for manual DNS configuration.

### 3. Check Current DNS Records

```
mcp__timeweb__timeweb_list_dns_records
  fqdn: example.com
```

### 4. Create/Update A Records

**Root domain:**
```
mcp__timeweb__timeweb_create_dns_record
  fqdn: example.com
  type: A
  value: SERVER_IP
  ttl: 3600
```

**WWW subdomain:**
```
mcp__timeweb__timeweb_create_dns_record
  fqdn: example.com
  subdomain: www
  type: A
  value: SERVER_IP
  ttl: 3600
```

### 5. Wait for Propagation

```bash
echo "Waiting for DNS propagation..."
MAX_WAIT=300  # 5 minutes
INTERVAL=15

for i in $(seq 1 $((MAX_WAIT / INTERVAL))); do
  RESOLVED=$(dig +short $DOMAIN @8.8.8.8 A | head -1)
  if [ "$RESOLVED" = "$SERVER_IP" ]; then
    echo "DNS propagated!"
    break
  fi
  echo "Waiting... ($((i * INTERVAL))s)"
  sleep $INTERVAL
done
```

### 6. Verify

```bash
echo "DNS Configuration:"
echo "  $DOMAIN -> $(dig +short $DOMAIN A | head -1)"
echo "  www.$DOMAIN -> $(dig +short www.$DOMAIN A | head -1)"
```

## Output Format

```
═══════════════════════════════════════════════════
  DNS Setup for example.com
═══════════════════════════════════════════════════

Server IP: 77.232.136.239

Creating DNS Records:
  ✓ A record: example.com -> 77.232.136.239
  ✓ A record: www.example.com -> 77.232.136.239

Propagation:
  Checking... 15s
  Checking... 30s
  ✓ DNS propagated!

Verification:
  example.com      -> 77.232.136.239 ✓
  www.example.com  -> 77.232.136.239 ✓

═══════════════════════════════════════════════════
  DNS configured! You can now setup SSL:
  /tw-deploy:ssl
═══════════════════════════════════════════════════
```

## Manual Configuration

If domain is not managed by Timeweb, show instructions:

```
═══════════════════════════════════════════════════
  Manual DNS Configuration Required
═══════════════════════════════════════════════════

Domain example.com is not managed by Timeweb.
Please configure DNS at your domain registrar:

Add these A records:
  Type: A    Host: @     Value: 77.232.136.239
  Type: A    Host: www   Value: 77.232.136.239

After configuration, verify with:
  dig +short example.com A

Then run SSL setup:
  /tw-deploy:ssl
═══════════════════════════════════════════════════
```

## Notes

- DNS propagation typically takes 5-30 minutes
- Some registrars may take up to 48 hours
- SSL certificates can only be obtained after DNS is configured
- Use `dig +trace` for troubleshooting propagation issues
