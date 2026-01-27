# tw-deploy

A Claude Code plugin for deploying applications to [Timeweb Cloud](https://timeweb.cloud).

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Multi-stack support**: Node.js/Next.js, Python (Django, FastAPI, Flask), PHP (Laravel, WordPress), Static sites
- **Integrated with Timeweb Cloud**: Uses MCP for server management
- **Two deployment methods**: Git-pull (SSH) or GitHub Actions
- **Pre-flight checks**: Verify everything before deployment
- **Automated SSH setup**: One command to configure SSH keys
- **Health checks**: Automatic verification after deployment
- **Simple commands**: `/tw-deploy`, `/tw-deploy:status`, `/tw-deploy:logs`
- **Automated setup**: Configure servers, SSL certificates, databases

## Installation

### Option 1: Install from GitHub (Recommended)

```bash
claude /install-plugin github:webkoth/tw-deploy
```

### Option 2: Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/webkoth/tw-deploy.git ~/.claude/plugins/tw-deploy
```

2. Add to your `~/.claude/plugins/installed_plugins.json`:
```json
{
  "tw-deploy@local": [{
    "scope": "user",
    "installPath": "/Users/YOUR_USERNAME/.claude/plugins/tw-deploy",
    "version": "1.0.0"
  }]
}
```

3. Enable in `~/.claude/settings.json`:
```json
{
  "enabledPlugins": {
    "tw-deploy@local": true
  }
}
```

4. Restart Claude Code

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- [Timeweb MCP Server](https://github.com/patsevanton/mcp-timeweb-cloud) configured
- SSH access to your server

## Commands

| Command | Description |
|---------|-------------|
| `/tw-deploy` | Deploy current project |
| `/tw-deploy:init` | Initialize deployment config |
| `/tw-deploy:preflight` | Run pre-deployment checks |
| `/tw-deploy:ssh-setup` | Setup SSH key authentication |
| `/tw-deploy:dns-setup` | Configure DNS records |
| `/tw-deploy:github-setup` | Setup GitHub repo and Actions workflow |
| `/tw-deploy:status` | Check application status |
| `/tw-deploy:logs` | View application logs |
| `/tw-deploy:rollback` | Rollback to previous version |
| `/tw-deploy:ssl` | Setup SSL certificate |
| `/tw-deploy:server-create` | Create new Timeweb server |
| `/tw-deploy:server-list` | List all servers |

## Quick Start

1. **Initialize config** in your project:
```bash
/tw-deploy:init
```

2. **Setup SSH** for your server:
```bash
/tw-deploy:ssh-setup SERVER_IP
```

3. **Run preflight checks**:
```bash
/tw-deploy:preflight
```

4. **For GitHub Actions deployment** (optional):
```bash
/tw-deploy:github-setup
```

5. **Deploy**:
```bash
/tw-deploy:deploy
```

## Configuration

Create `.deploy.yml` in your project root:

```yaml
name: my-app
type: nextjs  # nextjs | python | php | static
server: 77.232.136.239
domain: example.com
port: 3000

# Deployment method
deploy:
  method: github-actions  # or git-pull

git:
  repo: git@github.com:user/my-app.git
  branch: main
  deploy_path: /var/www/my-app

ssh:
  user: root
  # Uses SSH key (configured via /tw-deploy:ssh-setup)

build:
  command: npm run build

start:
  command: npm start

env:
  - DATABASE_URL
  - NODE_ENV=production

pm2:
  name: my-app
  instances: 1
```

### Deployment Methods

- **github-actions**: Push triggers GitHub Actions workflow that deploys to server
- **git-pull**: SSH to server, git pull, build and restart (direct deployment)

## Deployment Flow

### Method 1: GitHub Actions (Recommended)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Commit    │────▶│ Push to     │────▶│  GitHub     │
│   Changes   │     │   GitHub    │     │  Actions    │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Verify    │◀────│   Deploy    │◀────│   Build     │
│   Health    │     │  via rsync  │     │  in CI      │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Method 2: Git Pull (Direct SSH)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Commit    │────▶│  Tag/Push   │────▶│  Git Pull   │
│   Changes   │     │  to Remote  │     │  on Server  │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Verify    │◀────│   Restart   │◀────│    Build    │
│   Health    │     │   App/PM2   │     │  on Server  │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Steps

1. **Preflight** - Check SSH, env vars, server health
2. **Commit** - All changes must be committed
3. **Push** - Push to remote repository
4. **Build** - Build locally (GitHub Actions) or on server (git-pull)
5. **Deploy** - rsync files (GitHub Actions) or git pull (git-pull)
6. **Restart** - Restart application via PM2/systemd
7. **Verify** - Check application health

## Rollback

Each deploy saves the previous commit hash. Rollback is instant:

```bash
/tw-deploy:rollback           # Rollback to previous version
/tw-deploy:rollback --list    # Show available versions
/tw-deploy:rollback --to TAG  # Rollback to specific tag
```

## Supported Stacks

### Node.js / Next.js
- Uses nvm for Node.js installation
- PM2 for process management
- Nginx as reverse proxy

### Python
- Django, FastAPI, Flask support
- Gunicorn/Uvicorn for WSGI/ASGI
- Systemd service management

### PHP
- Laravel, WordPress support
- PHP-FPM configuration
- Composer dependency management

### Static Sites
- Built React/Vue/Angular
- Hugo, Jekyll output
- Nginx with caching

## Plugin Structure

```
tw-deploy/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/                # Slash commands
│   ├── deploy.md
│   ├── init.md
│   ├── preflight.md         # Pre-deployment checks
│   ├── ssh-setup.md         # SSH key setup
│   ├── dns-setup.md         # DNS configuration
│   ├── github-setup.md      # GitHub Actions setup
│   ├── status.md
│   ├── logs.md
│   ├── rollback.md
│   ├── ssl.md
│   ├── server-create.md
│   └── server-list.md
├── agents/                  # Deployment agents
│   ├── deploy-nodejs.md
│   ├── deploy-python.md
│   ├── deploy-php.md
│   ├── deploy-static.md
│   └── deploy-validator.md
├── skills/                  # Setup skills
│   ├── nginx-config/
│   ├── ssl-setup/
│   └── database-setup/
├── templates/               # Config templates
│   ├── nginx/
│   ├── systemd/
│   └── github/              # GitHub Actions workflow
├── docs/
│   └── TROUBLESHOOTING.md   # Common issues
└── hooks/
    └── hooks.json
```

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions:
- SSH Permission denied
- TIMEWEB_CLOUD_TOKEN not set
- SSL certificate errors
- Application not starting
- DNS issues
- GitHub Actions problems

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Minas Sarkisyan ([@webkoth](https://github.com/webkoth))
