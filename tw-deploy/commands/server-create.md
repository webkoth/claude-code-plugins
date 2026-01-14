---
description: Create a new server on Timeweb Cloud
allowed-tools: Read, Write, Bash
argument-hint: [name] [--preset PRESET]
---

# Create New Server

Create a new cloud server on Timeweb using MCP API.

## Parameters

- `name`: Server name (required)
- `--preset`: Server preset (default: 2453 = 2 CPU / 4 GB RAM)

## Available Presets (ru-1)

| ID | CPU | RAM | Disk | Price |
|----|-----|-----|------|-------|
| 2449 | 1 | 2 GB | 30 GB | 550 RUB/mo |
| 2453 | 2 | 4 GB | 50 GB | 1000 RUB/mo |
| 2455 | 4 | 8 GB | 80 GB | 1800 RUB/mo |

## Process

### 1. Use MCP Timeweb to create server
```
mcp__timeweb__timeweb_create_server
- name: server-name
- os_id: 79 (Ubuntu 24.04)
- preset_id: 2453
```

### 2. Wait for server to be ready
Poll server status until status = "on"

### 3. Create Floating IP (IPv4)
```
mcp__timeweb__timeweb_create_floating_ip
```

### 4. Bind IP to server
```
mcp__timeweb__timeweb_bind_floating_ip
```

### 5. Display connection info
- IP address
- Root password
- SSH command

## Notes

- Server takes 1-3 minutes to provision
- Save root password securely
- Consider adding SSH key for security
