---
description: View application logs from server
allowed-tools: Read, Bash
argument-hint: [--lines N] [--follow] [--error]
---

# View Application Logs

Fetch and display logs from the deployed application.

## Options

- `--lines N`: Show last N lines (default: 100)
- `--follow`: Stream logs in real-time (like tail -f)
- `--error`: Show only error logs

## Log Sources

Based on project type:

### Node.js (PM2)
```bash
pm2 logs app-name --lines 100
pm2 logs app-name --err  # errors only
```

### Python (systemd)
```bash
journalctl -u app-name -n 100
journalctl -u app-name -f  # follow
```

### PHP
```bash
tail -n 100 /var/log/php-fpm/error.log
tail -n 100 /var/log/nginx/error.log
```

### Nginx Access Logs
```bash
tail -n 100 /var/log/nginx/access.log
```

## Output

Display logs with syntax highlighting:
- Timestamps in gray
- Errors in red
- Warnings in yellow
- Info in default color
