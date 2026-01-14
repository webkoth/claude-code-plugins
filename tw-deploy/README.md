# tw-deploy

A Claude Code plugin for deploying applications to [Timeweb Cloud](https://timeweb.cloud).

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Multi-stack support**: Node.js/Next.js, Python (Django, FastAPI, Flask), PHP (Laravel, WordPress), Static sites
- **Integrated with Timeweb Cloud**: Uses MCP for server management
- **Git-based deployments**: Tag-based releases with instant rollback
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

2. **Configure** `.deploy.yml` with your server details

3. **Deploy**:
```bash
/tw-deploy
```

## Configuration

Create `.deploy.yml` in your project root:

```yaml
name: my-app
type: nextjs  # nextjs | python | php | static
server: 77.232.136.239
domain: example.com
port: 3000

git:
  repo: git@github.com:user/my-app.git
  branch: main
  deploy_path: /var/www/my-app

ssh:
  user: root
  password_env: SERVER_PASSWORD

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

## Deployment Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Commit    │────▶│  Tag/Push   │────▶│  Git Pull   │
│   Changes   │     │  to Remote  │     │  on Server  │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Verify    │◀────│   Restart   │◀────│    Build    │
│   Health    │     │   App/PM2   │     │  & Install  │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. **Commit** - All changes must be committed
2. **Tag** - Create deployment tag `deploy-YYYYMMDD-HHMMSS`
3. **Push** - Push to remote repository
4. **Pull** - Server pulls latest from git
5. **Build** - Run build command on server
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
│   ├── nodejs-setup/
│   ├── python-setup/
│   ├── php-setup/
│   ├── nginx-config/
│   ├── ssl-setup/
│   └── database-setup/
├── templates/               # Config templates
│   ├── nginx/
│   └── systemd/
└── hooks/
    └── hooks.json
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Minas Sarkisyan ([@webkoth](https://github.com/webkoth))
