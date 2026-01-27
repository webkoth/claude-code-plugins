---
description: Deploy current project to Timeweb server
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: [--dry-run] [--skip-build] [--force]
---

# Deploy Application

Deploy the current project to the configured Timeweb server. Supports two deployment methods:
- **github-actions**: Push triggers GitHub Actions workflow
- **git-pull**: SSH to server, pull and restart

## Prerequisites

- `.deploy.yml` must exist in project root (run `/tw-deploy:init` first)
- Project must be a git repository with remote configured
- Server must be accessible via SSH
- Required environment variables must be set

## Pre-deploy Verification

Before starting deployment, verify:

### 1. Configuration Check
```bash
# Check .deploy.yml exists
if [ ! -f .deploy.yml ]; then
  echo "ERROR: .deploy.yml not found"
  echo "Run: /tw-deploy:init"
  exit 1
fi

# Read deployment method
DEPLOY_METHOD=$(grep "method:" .deploy.yml | awk '{print $2}')
echo "Deployment method: $DEPLOY_METHOD"
```

### 2. SSH Connectivity Test
```bash
SERVER_IP=$(grep "^server:" .deploy.yml | awk '{print $2}')
SSH_USER=$(grep "user:" .deploy.yml | awk '{print $2}')
SSH_USER=${SSH_USER:-root}

# Test SSH without password prompt
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 $SSH_USER@$SERVER_IP "echo ok" &>/dev/null; then
  echo "ERROR: SSH connection failed"
  echo "Run: /tw-deploy:ssh-setup $SERVER_IP"
  exit 1
fi
```

### 3. Environment Variables
```bash
# Check TIMEWEB_CLOUD_TOKEN
if [ -z "$TIMEWEB_CLOUD_TOKEN" ]; then
  echo "WARNING: TIMEWEB_CLOUD_TOKEN not set"
fi

# Check env vars from .deploy.yml
```

### 4. Git Status
```bash
# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  if [ "$FORCE" != "true" ]; then
    echo "WARNING: Uncommitted changes exist"
    echo "Use --force to deploy anyway"
  fi
fi
```

### 5. Server Disk Space
```bash
DISK_USAGE=$(ssh $SSH_USER@$SERVER_IP "df -h / | tail -1 | awk '{print \$5}' | tr -d '%'")
if [ "$DISK_USAGE" -gt 90 ]; then
  echo "WARNING: Disk usage is ${DISK_USAGE}%"
fi
```

---

## Deployment Methods

### Method 1: GitHub Actions (Recommended)

If `deploy.method: github-actions` in `.deploy.yml`:

1. **Commit and push changes**
```bash
git add .
git commit -m "Deploy: $(date +%Y%m%d-%H%M%S)"
git push origin main
```

2. **Trigger workflow**
Push automatically triggers `.github/workflows/deploy.yml`

3. **Monitor workflow**
```bash
# Watch workflow run
gh run watch

# Or view in browser
gh run view --web
```

4. **Workflow handles**:
   - Build application
   - rsync to server
   - Install dependencies
   - Restart PM2
   - Health check

### Method 2: Git Pull (Direct SSH)

If `deploy.method: git-pull` in `.deploy.yml`:

1. **Tag Release**
```bash
git tag -a "deploy-$(date +%Y%m%d-%H%M%S)" -m "Deployment"
git push origin --tags
```

2. **Push to Remote**
```bash
git push origin main
```

3. **Deploy on Server**
```bash
ssh $SSH_USER@$SERVER_IP << 'EOF'
  cd /var/www/app-name

  # Save current commit for rollback
  git rev-parse HEAD > .previous-deploy

  # Pull latest changes
  git fetch origin
  git reset --hard origin/main

  echo "Deployed: $(git log -1 --oneline)"
EOF
```

4. **Install Dependencies**
Based on project type:
- **Node.js**: `npm ci --production`
- **Python**: `pip install -r requirements.txt`
- **PHP**: `composer install --no-dev --optimize-autoloader`

5. **Build Application**
Run build command from config (if applicable):
- **Node.js/Next.js**: `npm run build`
- **Static**: Build locally, push dist

6. **Restart Application**
Based on project type:
- **Node.js**: `pm2 restart app-name`
- **Python**: `systemctl restart app-name`
- **PHP**: `systemctl restart php-fpm`

---

## Post-deploy Health Check

After deployment completes:

### 1. Process Check
```bash
ssh $SSH_USER@$SERVER_IP << 'EOF'
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Check PM2 status
  pm2 show app-name | grep "status" | grep -q "online"
  if [ $? -eq 0 ]; then
    echo "Process: RUNNING"
  else
    echo "Process: FAILED"
    pm2 logs app-name --lines 20
    exit 1
  fi
EOF
```

### 2. HTTP Health Check
```bash
# Wait for app to start
sleep 5

# Check health endpoint
PORT=$(grep "^port:" .deploy.yml | awk '{print $2}')
HTTP_CODE=$(ssh $SSH_USER@$SERVER_IP "curl -s -o /dev/null -w '%{http_code}' http://localhost:$PORT/api/health 2>/dev/null || echo '000'")

if [ "$HTTP_CODE" = "200" ]; then
  echo "Health check: PASSED"
else
  echo "Health check: FAILED (HTTP $HTTP_CODE)"
  echo "Check logs: /tw-deploy:logs"
fi
```

### 3. Auto-rollback on Failure
```bash
if [ "$HEALTH_CHECK" = "FAILED" ]; then
  echo "Rolling back to previous version..."
  ssh $SSH_USER@$SERVER_IP << 'EOF'
    cd /var/www/app-name
    if [ -f .previous-deploy ]; then
      git reset --hard $(cat .previous-deploy)
      pm2 restart app-name
      echo "Rolled back to: $(git log -1 --oneline)"
    fi
EOF
fi
```

---

## Options

- `--dry-run`: Show what would be deployed without making changes
- `--skip-build`: Skip the build step (use existing build)
- `--force`: Deploy even with uncommitted changes (not recommended)

## Deployment History

Each deployment is tagged in git:
```bash
git tag -l "deploy-*" --sort=-creatordate | head -10
```

## Rollback

Use `/tw-deploy:rollback` to revert to previous deployment:
```bash
# On server, stored in .previous-deploy
git reset --hard $(cat .previous-deploy)
```

## Error Handling

- If pre-deploy checks fail, deployment is aborted
- If deployment fails, application stays on previous version
- If health check fails, automatic rollback is attempted
- Use `/tw-deploy:rollback` to manually revert
- Check logs with `/tw-deploy:logs`
