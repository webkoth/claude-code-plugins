---
description: Deploy current project to Timeweb server
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: [--dry-run] [--skip-build]
---

# Deploy Application

Deploy the current project to the configured Timeweb server using Git-based deployment.

## Prerequisites

- `.deploy.yml` must exist in project root (run `/tw-deploy:init` first)
- Project must be a git repository with remote configured
- Server must be accessible via SSH
- Required environment variables must be set

## Deployment Process

### 1. Pre-deploy Checks
- Read `.deploy.yml` configuration
- Ensure all changes are committed: `git status --porcelain`
- Check server connectivity via SSH

### 2. Tag Release
Create a git tag for this deployment:
```bash
# Format: deploy-YYYYMMDD-HHMMSS
git tag -a "deploy-$(date +%Y%m%d-%H%M%S)" -m "Deployment"
git push origin --tags
```

### 3. Push to Remote
```bash
git push origin main
```

### 4. Deploy on Server
SSH into server and pull latest:
```bash
ssh user@server << 'EOF'
  cd /var/www/app-name

  # Save current commit for rollback
  git rev-parse HEAD > .previous-deploy

  # Pull latest changes
  git fetch origin
  git reset --hard origin/main

  # Show deployed commit
  echo "Deployed: $(git log -1 --oneline)"
EOF
```

### 5. Install Dependencies
Based on project type:
- **Node.js**: `npm ci --production` (uses lockfile for reproducible builds)
- **Python**: `pip install -r requirements.txt`
- **PHP**: `composer install --no-dev --optimize-autoloader`

### 6. Build Application
Run build command from config (if applicable):
- **Node.js/Next.js**: `npm run build`
- **Static**: Build locally, push dist

### 7. Restart Application
Based on project type:
- **Node.js**: `pm2 restart app-name`
- **Python**: `systemctl restart app-name`
- **PHP**: `systemctl restart php-fpm`

### 8. Verify Deployment
- Check application health endpoint
- Verify HTTP response from domain
- Show deployed git commit hash

## Options

- `--dry-run`: Show what would be deployed without making changes
- `--skip-build`: Skip the build step
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

- If deployment fails, application stays on previous version
- Use `/tw-deploy:rollback` to revert to last known good state
- Check logs with `/tw-deploy:logs`
