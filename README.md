# Claude Code Plugins by webkoth

A collection of plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [tw-deploy](./tw-deploy/) | Deploy applications to Timeweb Cloud |

## Quick Start

### 1. Add this Marketplace

```bash
/plugin
# Select "Add Marketplace"
# Enter: webkoth/claude-code-plugins
```

### 2. Install Plugin

```bash
/plugin install tw-deploy@webkoth
```

Or browse in `/plugin > Discover`

### 3. Setup

```bash
# Set your Timeweb API token
export TIMEWEB_CLOUD_TOKEN=your-token-here
```

Get your token at: https://timeweb.cloud/my/api-keys

## Included

- **tw-deploy plugin** - Deploy commands, agents, skills
- **@webkoth/mcp-timeweb** - Full Timeweb Cloud API via MCP

## Contributing

PRs welcome! Feel free to submit improvements.

## License

MIT
