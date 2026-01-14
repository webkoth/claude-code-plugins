---
description: Check deployment status and application health
allowed-tools: Read, Bash, Grep
---

# Check Deployment Status

Show the current status of the deployed application.

## Information to Display

### 1. Server Info
- Server IP and hostname
- Server status (from Timeweb API if available)
- Uptime

### 2. Application Status
Based on project type:
- **Node.js**: `pm2 status app-name`
- **Python**: `systemctl status app-name`
- **PHP**: `systemctl status php-fpm`

### 3. Resource Usage
- CPU usage
- Memory usage
- Disk usage

### 4. Network
- Domain resolution
- SSL certificate status
- HTTP response code

### 5. Recent Activity
- Last deployment time
- Recent restarts
- Error count in logs

## Output Format

```
═══════════════════════════════════════════════════
  tw-deploy status: my-app
═══════════════════════════════════════════════════

Server:     77.232.136.239 (Ubuntu 24.04)
Domain:     https://example.com ✓
SSL:        Valid until 2025-03-15

Application Status:
├── Process:    online (PM2)
├── Uptime:     3d 14h 22m
├── Restarts:   0
└── Memory:     156 MB

Last Deploy:    2024-01-14 12:30:45
Git Commit:     abc1234 (main)

Health Check:   ✓ HTTP 200 (45ms)
═══════════════════════════════════════════════════
```
