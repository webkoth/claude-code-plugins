---
description: Rollback to previous deployment version
allowed-tools: Read, Write, Bash
argument-hint: [--list] [--to TAG|COMMIT]
---

# Rollback Deployment

Rollback to a previous version using git tags or commits.

## Options

- `--list`: Show available deployment tags
- `--to TAG|COMMIT`: Rollback to specific tag or commit hash

## Process

### 1. List Available Versions

Show deployment history:
```bash
ssh user@server << 'EOF'
  cd /var/www/app-name
  echo "=== Deployment Tags ==="
  git tag -l "deploy-*" --sort=-creatordate | head -10
  echo ""
  echo "=== Recent Commits ==="
  git log --oneline -10
  echo ""
  echo "=== Previous Deploy ==="
  cat .previous-deploy 2>/dev/null || echo "No previous deploy recorded"
EOF
```

### 2. Quick Rollback (to previous version)

If no version specified, rollback to `.previous-deploy`:
```bash
ssh user@server << 'EOF'
  cd /var/www/app-name

  PREV=$(cat .previous-deploy)
  CURRENT=$(git rev-parse HEAD)

  echo "Rolling back from $CURRENT to $PREV"

  # Save current as new previous (for undo)
  echo $CURRENT > .previous-deploy

  # Rollback
  git reset --hard $PREV

  # Reinstall dependencies
  npm ci --production

  # Restart
  pm2 restart app-name

  echo "Rolled back to: $(git log -1 --oneline)"
EOF
```

### 3. Rollback to Specific Version

With `--to TAG` or `--to COMMIT`:
```bash
ssh user@server << 'EOF'
  cd /var/www/app-name

  # Save current for potential undo
  git rev-parse HEAD > .previous-deploy

  # Checkout specific version
  git fetch origin --tags
  git reset --hard TARGET_VERSION

  # Reinstall dependencies
  npm ci --production

  # Rebuild if needed
  npm run build

  # Restart
  pm2 restart app-name
EOF
```

### 4. Verify Rollback

- Check application health
- Confirm correct version: `git log -1 --oneline`
- Test HTTP response

## Git-based Rollback Advantages

- **Instant**: No file copying, just pointer change
- **Traceable**: Every version is a commit
- **Reversible**: Can undo rollback easily
- **Auditable**: Full history in git log

## Example Usage

```bash
# Show available versions
/tw-deploy:rollback --list

# Rollback to previous deploy
/tw-deploy:rollback

# Rollback to specific tag
/tw-deploy:rollback --to deploy-20250114-153022

# Rollback to specific commit
/tw-deploy:rollback --to abc1234
```

## Safety Notes

- Database migrations may not be reversible
- Check for config changes between versions
- Consider feature flags for gradual rollout
