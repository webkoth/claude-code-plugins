---
description: List all Timeweb servers
allowed-tools: Read
---

# List Servers

Display all servers in Timeweb Cloud account.

## Process

Use MCP Timeweb to fetch server list:
```
mcp__timeweb__timeweb_list_servers
```

## Output Format

```
═══════════════════════════════════════════════════════════════
  Timeweb Cloud Servers
═══════════════════════════════════════════════════════════════

  ID        Name                  IP               Status    Cost
  ────────────────────────────────────────────────────────────────
  6398745   sellerai-dashboard    77.232.136.239   online    1000 RUB/mo
  6398800   api-service           77.232.136.240   online    550 RUB/mo

  Total: 2 servers
  Monthly cost: 1550 RUB/mo
═══════════════════════════════════════════════════════════════
```

## Additional Info

For each server, also show:
- Location (ru-1, ru-2, etc.)
- OS version
- CPU / RAM / Disk
- Creation date
