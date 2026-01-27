---
description: Run pre-deployment checks to ensure everything is ready
allowed-tools: Read, Bash, Grep
argument-hint: [--fix] [--verbose]
---

# Pre-flight Checks

Comprehensive verification before deployment. Run this to identify issues before they cause deployment failures.

## Checks Performed

### 1. Environment Variables

```bash
# Check TIMEWEB_CLOUD_TOKEN
if [ -z "$TIMEWEB_CLOUD_TOKEN" ]; then
  echo "FAIL: TIMEWEB_CLOUD_TOKEN not set"
  echo "Get token from: https://timeweb.cloud/my/api-keys"
else
  echo "OK: TIMEWEB_CLOUD_TOKEN is set"
fi
```

Read `.deploy.yml` and check all required env vars are set.

### 2. SSH Configuration

```bash
# Check local SSH key exists
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
  echo "OK: SSH key found"
else
  echo "FAIL: No SSH key found"
  echo "Run: /tw-deploy:ssh-setup SERVER_IP --generate"
fi

# Check server in known_hosts
SERVER_IP=$(grep "^server:" .deploy.yml | awk '{print $2}')
if ssh-keygen -F $SERVER_IP &>/dev/null; then
  echo "OK: Server in known_hosts"
else
  echo "WARN: Server not in known_hosts"
fi

# Test SSH connection
if ssh -o BatchMode=yes -o ConnectTimeout=5 root@$SERVER_IP "echo ok" &>/dev/null; then
  echo "OK: SSH connection works"
else
  echo "FAIL: SSH connection failed"
  echo "Run: /tw-deploy:ssh-setup $SERVER_IP"
fi
```

### 3. Configuration File

```bash
# Check .deploy.yml exists
if [ -f .deploy.yml ]; then
  echo "OK: .deploy.yml found"
else
  echo "FAIL: .deploy.yml not found"
  echo "Run: /tw-deploy:init"
fi

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.deploy.yml'))" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "OK: Valid YAML syntax"
else
  echo "FAIL: Invalid YAML syntax"
fi
```

### 4. Git Repository

```bash
# Check is git repo
if git rev-parse --git-dir &>/dev/null; then
  echo "OK: Git repository"
else
  echo "FAIL: Not a git repository"
fi

# Check remote configured
if git remote get-url origin &>/dev/null; then
  echo "OK: Git remote configured"
else
  echo "FAIL: No git remote"
fi

# Check uncommitted changes
if [ -z "$(git status --porcelain)" ]; then
  echo "OK: No uncommitted changes"
else
  echo "WARN: Uncommitted changes exist"
fi
```

### 5. GitHub Repository (for github-actions method)

```bash
DEPLOY_METHOD=$(grep "method:" .deploy.yml | awk '{print $2}')
if [ "$DEPLOY_METHOD" = "github-actions" ]; then
  # Check GitHub CLI
  if command -v gh &>/dev/null; then
    echo "OK: GitHub CLI installed"
  else
    echo "FAIL: GitHub CLI not installed"
    echo "Install: brew install gh"
  fi

  # Check repo exists on GitHub
  if gh repo view &>/dev/null; then
    echo "OK: GitHub repository exists"
  else
    echo "FAIL: GitHub repository not found"
    echo "Run: /tw-deploy:github-setup"
  fi

  # Check workflow file exists
  if [ -f .github/workflows/deploy.yml ]; then
    echo "OK: Deploy workflow exists"
  else
    echo "FAIL: No deploy workflow"
    echo "Run: /tw-deploy:github-setup"
  fi
fi
```

### 6. Server Health

```bash
# Check server is running (via Timeweb API)
# mcp__timeweb__timeweb_get_server with server_id

# Check disk space
ssh root@$SERVER_IP "df -h / | tail -1 | awk '{print \$5}' | tr -d '%'"
# Warn if > 90%

# Check required runtime installed
# Based on project type from .deploy.yml
```

### 7. DNS Resolution

```bash
DOMAIN=$(grep "^domain:" .deploy.yml | awk '{print $2}')
SERVER_IP=$(grep "^server:" .deploy.yml | awk '{print $2}')

if [ -n "$DOMAIN" ]; then
  RESOLVED=$(dig +short $DOMAIN A | head -1)
  if [ "$RESOLVED" = "$SERVER_IP" ]; then
    echo "OK: DNS resolves correctly"
  else
    echo "WARN: DNS not configured"
    echo "  $DOMAIN -> $RESOLVED (expected $SERVER_IP)"
    echo "  SSL certificate will fail until DNS is configured"
    echo "Run: /tw-deploy:dns-setup"
  fi
fi
```

## Options

- `--fix`: Attempt to fix issues automatically (run ssh-setup, add to known_hosts, etc.)
- `--verbose`: Show detailed output for each check

## Output Format

```
═══════════════════════════════════════════════════
  Pre-flight Checks: my-app
═══════════════════════════════════════════════════

Environment:
  ✓ TIMEWEB_CLOUD_TOKEN set
  ✓ DATABASE_URL set
  ✓ NODE_ENV set

SSH:
  ✓ SSH key found (~/.ssh/id_ed25519)
  ✓ Server in known_hosts
  ✓ SSH connection OK

Configuration:
  ✓ .deploy.yml found
  ✓ Valid YAML syntax
  ✓ Server: 77.232.136.239
  ✓ Domain: example.com

Git:
  ✓ Git repository
  ✓ Remote: git@github.com:user/my-app.git
  ⚠ 2 uncommitted changes

GitHub (github-actions method):
  ✓ GitHub CLI installed
  ✓ Repository exists
  ✓ Deploy workflow exists

Server:
  ✓ Server running (Timeweb)
  ✓ Node.js v22.13.0 installed
  ✓ PM2 installed
  ✓ 45GB free disk space

DNS:
  ✓ example.com -> 77.232.136.239

═══════════════════════════════════════════════════
  Result: Ready to deploy ✓

  1 warning (non-blocking):
  - Uncommitted changes
═══════════════════════════════════════════════════
```

## Blocking vs Non-blocking Issues

**Blocking (will stop deployment):**
- No `.deploy.yml`
- SSH connection fails
- TIMEWEB_CLOUD_TOKEN not set
- Server not running
- GitHub repo missing (for github-actions method)

**Warnings (proceed with caution):**
- Uncommitted changes
- DNS not configured
- Low disk space (< 10GB)
- SSL certificate expiring soon
