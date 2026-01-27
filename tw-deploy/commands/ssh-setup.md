---
description: Setup SSH key authentication for Timeweb server access
allowed-tools: Read, Bash
argument-hint: <server-ip> [--generate]
---

# SSH Key Setup

Configure SSH key-based authentication for your Timeweb server. Uses existing local SSH key - does not create new keys for each server.

## Process

### 1. Check Local SSH Key

```bash
# Check for existing keys (prefer ed25519, fallback to rsa)
if [ -f ~/.ssh/id_ed25519 ]; then
  SSH_KEY_PATH=~/.ssh/id_ed25519
  SSH_KEY_TYPE="ed25519"
elif [ -f ~/.ssh/id_rsa ]; then
  SSH_KEY_PATH=~/.ssh/id_rsa
  SSH_KEY_TYPE="rsa"
else
  SSH_KEY_PATH=""
fi

echo "SSH Key: $SSH_KEY_PATH"
```

### 2. Generate Key if Missing (with --generate flag)

Only if user explicitly requests with `--generate`:
```bash
ssh-keygen -t ed25519 -C "deploy@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
```

If no key exists and `--generate` not specified, show error:
```
ERROR: No SSH key found at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa
Run with --generate flag to create one:
  /tw-deploy:ssh-setup SERVER_IP --generate
```

### 3. Check if Key Already in Timeweb

Use MCP to list existing SSH keys:
```
mcp__timeweb__timeweb_list_ssh_keys
```

Compare local key fingerprint with existing keys to avoid duplicates.

### 4. Add Key to Timeweb (if not exists)

```
mcp__timeweb__timeweb_create_ssh_key
  name: "deploy-$(hostname)-$(date +%Y%m%d)"
  body: "$(cat ~/.ssh/id_ed25519.pub)"
```

Save the returned SSH key ID for later use.

### 5. Add Key to Server

```
mcp__timeweb__timeweb_add_ssh_key_to_server
  server_id: SERVER_ID
  ssh_key_id: SSH_KEY_ID
```

### 6. Add Server to known_hosts

```bash
# Remove old entry if exists
ssh-keygen -R SERVER_IP 2>/dev/null

# Add new entry
ssh-keyscan -H SERVER_IP >> ~/.ssh/known_hosts 2>/dev/null
```

### 7. Test Connection

```bash
# Test SSH connection without password
ssh -o BatchMode=yes -o ConnectTimeout=10 root@SERVER_IP "echo 'SSH connection successful'"
```

## Output Format

```
═══════════════════════════════════════════════════
  SSH Setup for 77.232.136.239
═══════════════════════════════════════════════════

Local Key:
  Path:        ~/.ssh/id_ed25519
  Type:        ed25519
  Fingerprint: SHA256:abc123...

Timeweb:
  Key ID:      12345
  Status:      Added to account ✓

Server:
  Added to:    77.232.136.239 ✓
  known_hosts: Updated ✓

Connection Test:
  SSH:         root@77.232.136.239 ✓

═══════════════════════════════════════════════════
  Setup complete! You can now connect:
  ssh root@77.232.136.239
═══════════════════════════════════════════════════
```

## Error Handling

- If no local key and no `--generate` flag: show instructions
- If key already in Timeweb: skip adding, just use existing ID
- If key already on server: skip, show success
- If connection test fails: show troubleshooting steps

## Notes

- One SSH key per local machine, used for all servers
- Key is added to Timeweb account once, then assigned to servers
- Always test connection after setup
