# Troubleshooting Guide

Common issues and solutions when deploying with tw-deploy.

---

## SSH Issues

### 1. Permission denied (publickey)

**Symptoms:**
```
Permission denied (publickey,password)
```

**Cause:** SSH key is not configured or not added to the server.

**Solutions:**

1. **Run SSH setup:**
   ```bash
   /tw-deploy:ssh-setup SERVER_IP
   ```

2. **Check if SSH key exists locally:**
   ```bash
   ls -la ~/.ssh/id_ed25519 ~/.ssh/id_rsa
   ```

3. **Generate SSH key if missing:**
   ```bash
   /tw-deploy:ssh-setup SERVER_IP --generate
   ```

4. **Verify key is added to Timeweb:**
   - Check in Timeweb panel: https://timeweb.cloud/my/ssh-keys
   - Or via API: `mcp__timeweb__timeweb_list_ssh_keys`

### 2. Host key verification failed

**Symptoms:**
```
Host key verification failed.
```

**Cause:** Server not in `~/.ssh/known_hosts`.

**Solution:**
```bash
ssh-keyscan -H SERVER_IP >> ~/.ssh/known_hosts
```

Or run `/tw-deploy:ssh-setup SERVER_IP` which adds the server automatically.

### 3. Connection timed out

**Symptoms:**
```
ssh: connect to host ... port 22: Connection timed out
```

**Cause:** Server is down, firewall blocking, or wrong IP.

**Solutions:**

1. **Check server is running:**
   ```bash
   /tw-deploy:status
   ```

2. **Verify server IP:**
   ```bash
   cat .deploy.yml | grep server
   ```

3. **Check firewall on server:**
   ```bash
   # On server
   ufw status
   ufw allow 22
   ```

---

## Environment Variables

### 1. TIMEWEB_CLOUD_TOKEN not set

**Symptoms:**
```
ERROR: TIMEWEB_CLOUD_TOKEN not set
```

**Solution:**

1. **Get API token:** https://timeweb.cloud/my/api-keys

2. **Add to shell profile (~/.zshrc or ~/.bashrc):**
   ```bash
   export TIMEWEB_CLOUD_TOKEN="your-token-here"
   ```

3. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

### 2. Missing application env vars

**Symptoms:**
Application fails to start due to missing DATABASE_URL, etc.

**Solution:**

1. **Check `.deploy.yml` env section:**
   ```yaml
   env:
     - DATABASE_URL
     - NODE_ENV=production
   ```

2. **Set env vars on server:**
   ```bash
   # Via SSH
   ssh root@SERVER_IP "echo 'export DATABASE_URL=...' >> /etc/environment"
   ```

3. **Or add to PM2 ecosystem.config.js:**
   ```javascript
   env: {
     DATABASE_URL: process.env.DATABASE_URL
   }
   ```

---

## SSL Certificate Issues

### 1. Challenge failed for domain

**Symptoms:**
```
Challenge failed for domain.com
```

**Cause:** DNS not pointing to server, or port 80 blocked.

**Solutions:**

1. **Check DNS resolution:**
   ```bash
   dig +short domain.com A
   # Should return your server IP
   ```

2. **Setup DNS if not configured:**
   ```bash
   /tw-deploy:dns-setup domain.com
   ```

3. **Check port 80 is open:**
   ```bash
   ssh root@SERVER_IP "ufw allow 80"
   ```

4. **Try staging first:**
   ```bash
   /tw-deploy:ssl --staging
   ```

### 2. Certificate expiring

**Symptoms:**
Browser shows certificate warning, or preflight shows expiring cert.

**Solution:**
```bash
/tw-deploy:ssl --renew
```

Or set up auto-renewal:
```bash
# On server
certbot renew --dry-run
# Add cron job for auto-renewal
```

---

## Application Issues

### 1. Application not starting (Node.js)

**Symptoms:**
```
pm2 show app-name -> status: errored
```

**Solutions:**

1. **Check PM2 logs:**
   ```bash
   /tw-deploy:logs --error
   # Or: ssh root@SERVER_IP "pm2 logs app-name --lines 50"
   ```

2. **Verify Node.js version:**
   ```bash
   ssh root@SERVER_IP "node -v"
   ```

3. **Check port is not in use:**
   ```bash
   ssh root@SERVER_IP "lsof -i :3000"
   ```

4. **Restart manually:**
   ```bash
   ssh root@SERVER_IP "cd /var/www/app-name && pm2 restart app-name"
   ```

### 2. Application not starting (Python)

**Symptoms:**
```
systemctl status app-name -> failed
```

**Solutions:**

1. **Check service logs:**
   ```bash
   ssh root@SERVER_IP "journalctl -u app-name -n 50"
   ```

2. **Verify venv and dependencies:**
   ```bash
   ssh root@SERVER_IP "cd /var/www/app-name && source venv/bin/activate && pip list"
   ```

3. **Check WSGI/ASGI app path:**
   Ensure `ExecStart` in systemd service points to correct module.

### 3. Build fails

**Symptoms:**
```
npm run build -> error
```

**Solutions:**

1. **Check Node.js memory:**
   ```bash
   export NODE_OPTIONS="--max-old-space-size=4096"
   npm run build
   ```

2. **Clear caches:**
   ```bash
   rm -rf node_modules .next
   npm ci
   npm run build
   ```

---

## DNS Issues

### 1. Domain not resolving

**Symptoms:**
```
dig +short domain.com A -> (empty)
```

**Solutions:**

1. **Check nameservers:**
   ```bash
   dig +short domain.com NS
   ```

2. **If domain in Timeweb, run:**
   ```bash
   /tw-deploy:dns-setup domain.com
   ```

3. **For external domains:**
   - Login to your domain registrar
   - Add A record pointing to SERVER_IP
   - Wait 15-30 minutes for propagation

### 2. DNS propagation slow

**Solution:** Wait 15-30 minutes. Check propagation status:
```bash
# Check via different DNS servers
dig +short domain.com @8.8.8.8 A
dig +short domain.com @1.1.1.1 A
```

---

## GitHub Actions Issues

### 1. Workflow not triggering

**Symptoms:**
Push to main, but no workflow runs.

**Solutions:**

1. **Check workflow file exists:**
   ```bash
   cat .github/workflows/deploy.yml
   ```

2. **Verify trigger branch:**
   ```yaml
   on:
     push:
       branches:
         - main  # Make sure this matches your branch
   ```

3. **Check GitHub Actions is enabled:**
   - Go to repo Settings > Actions > General

### 2. SSH connection fails in workflow

**Symptoms:**
```
Permission denied (publickey)
```

**Solutions:**

1. **Verify secrets are set:**
   - Go to repo Settings > Secrets > Actions
   - Check: `SSH_PRIVATE_KEY`, `SERVER_IP`, `SERVER_USER`

2. **Re-add SSH key:**
   ```bash
   # Copy private key content
   cat ~/.ssh/id_ed25519

   # Paste as SSH_PRIVATE_KEY secret in GitHub
   ```

---

## Quick Diagnostics

Run preflight checks to identify issues:
```bash
/tw-deploy:preflight --verbose
```

This will check:
- Environment variables
- SSH connectivity
- Git status
- Server health
- DNS resolution
- GitHub setup (for github-actions method)
