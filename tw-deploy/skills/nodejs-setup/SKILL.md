---
name: nodejs-setup
description: Setup Node.js environment on server using nvm and PM2. Use when preparing a server for Node.js/Next.js deployment.
---

# Node.js Server Setup

Install and configure Node.js environment on Ubuntu server.

## Installation Steps

### 1. Install nvm
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### 2. Install Node.js LTS
```bash
nvm install --lts
nvm use --lts
nvm alias default lts/*
```

### 3. Install PM2
```bash
npm install -g pm2
pm2 startup systemd
```

### 4. Install libatomic (if needed)
```bash
apt install -y libatomic1
```

## Verify Installation
```bash
node -v
npm -v
pm2 -v
```

## PM2 Commands

```bash
# Start app
pm2 start npm --name "app-name" -- start

# Restart
pm2 restart app-name

# View logs
pm2 logs app-name

# Save process list
pm2 save

# List processes
pm2 list
```

## Environment Variables

Add to `~/.bashrc` or `/etc/environment`:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```
