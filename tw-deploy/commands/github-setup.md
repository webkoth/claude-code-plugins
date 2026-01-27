---
description: Setup GitHub repository and Actions workflow for deployment
allowed-tools: Read, Write, Bash, Glob
argument-hint: [--private] [--no-workflow]
---

# GitHub Setup

Configure GitHub repository and create GitHub Actions workflow for automated deployments.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Git repository initialized locally
- `.deploy.yml` configured

## Process

### 1. Check GitHub CLI

```bash
if ! command -v gh &>/dev/null; then
  echo "ERROR: GitHub CLI not installed"
  echo "Install: brew install gh"
  echo "Then: gh auth login"
  exit 1
fi

# Check authentication
if ! gh auth status &>/dev/null; then
  echo "ERROR: GitHub CLI not authenticated"
  echo "Run: gh auth login"
  exit 1
fi
```

### 2. Check for Existing Repository

```bash
# Check if remote exists
if git remote get-url origin &>/dev/null; then
  REPO_URL=$(git remote get-url origin)
  echo "Repository already configured: $REPO_URL"

  # Verify it exists on GitHub
  if gh repo view &>/dev/null; then
    echo "Repository exists on GitHub"
  else
    echo "WARNING: Remote configured but repo not found on GitHub"
  fi
else
  echo "No GitHub repository configured"
fi
```

### 3. Create Repository (if needed)

```bash
# Get project name from .deploy.yml or directory
PROJECT_NAME=$(grep "^name:" .deploy.yml | awk '{print $2}')
if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME=$(basename $(pwd))
fi

# Create repo (--private flag for private repo)
gh repo create $PROJECT_NAME --source=. --remote=origin --push
# Or with --private:
gh repo create $PROJECT_NAME --source=. --remote=origin --push --private
```

### 4. Add GitHub Secrets

Required secrets for deployment:

```bash
# SSH Private Key for server access
gh secret set SSH_PRIVATE_KEY < ~/.ssh/id_ed25519

# Server IP
SERVER_IP=$(grep "^server:" .deploy.yml | awk '{print $2}')
gh secret set SERVER_IP --body "$SERVER_IP"

# Server user (usually root)
SERVER_USER=$(grep "user:" .deploy.yml | awk '{print $2}')
gh secret set SERVER_USER --body "${SERVER_USER:-root}"

# Deploy path
DEPLOY_PATH=$(grep "deploy_path:" .deploy.yml | awk '{print $2}')
gh secret set DEPLOY_PATH --body "${DEPLOY_PATH:-/var/www/$PROJECT_NAME}"
```

### 5. Create Workflow File

Create `.github/workflows/deploy.yml`:

```bash
mkdir -p .github/workflows
```

Use template from `templates/github/deploy.yml` and substitute variables.

### 6. Commit and Push

```bash
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

## Output Format

```
═══════════════════════════════════════════════════
  GitHub Setup for my-app
═══════════════════════════════════════════════════

Repository:
  ✓ GitHub CLI authenticated
  ✓ Repository created: github.com/user/my-app
  ✓ Remote added: origin

Secrets:
  ✓ SSH_PRIVATE_KEY added
  ✓ SERVER_IP added (77.232.136.239)
  ✓ SERVER_USER added (root)
  ✓ DEPLOY_PATH added (/var/www/my-app)

Workflow:
  ✓ Created .github/workflows/deploy.yml
  ✓ Committed and pushed

═══════════════════════════════════════════════════
  Setup complete!

  Deployment will trigger on push to main branch.
  View workflow: https://github.com/user/my-app/actions
═══════════════════════════════════════════════════
```

## Options

- `--private`: Create private repository (default: public)
- `--no-workflow`: Skip creating workflow file

## Update .deploy.yml

After setup, update `.deploy.yml`:

```yaml
deploy:
  method: github-actions
  workflow: .github/workflows/deploy.yml
```

## Notes

- GitHub Actions is free for public repositories
- Private repos have limited free minutes (2000/month)
- Workflow runs on every push to main branch
- Manual trigger available via GitHub UI
