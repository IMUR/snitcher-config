# Deployment Instructions for Snitcher

## Current Problem
Snitcher's `.zshrc` is symlinked to `/cluster-nas/configs/zsh/zshrc` which **fails when snitcher is remote** (cluster-nas not mounted).

## Solution
Deploy this lightweight configuration that works both on-network and offline.

## Deployment Steps

### 1. When Snitcher is Back on Local Network

```bash
# SSH into snitcher from cooperator
ssh snitcher

# Clone the configuration
git clone https://github.com/IMUR/snitcher-config.git ~/.config/snitcher-config

# Run the setup (will backup and replace symlinks)
~/.config/snitcher-config/setup.sh

# Restart shell
exec $SHELL
```

### 2. Alternative: Deploy When Remote

If you can SSH to snitcher while it's remote:

```bash
# From your current location, SSH to snitcher via cooperator
ssh -J crtr@47.155.237.161 snitcher@192.168.254.96

# Then follow same steps as above
```

## What the Setup Does

1. **Backs up** existing configs to `~/.config/snitcher-backups/TIMESTAMP/`
2. **Removes** broken symlinks to `/cluster-nas/`
3. **Installs** resilient local configurations
4. **Preserves** all existing SSH keys and tools
5. **Updates** shell to work with installed tools (eza, bat, fd, rg)

## After Setup

Snitcher will have:
- ✅ Shell configs that work offline
- ✅ Smart SSH routing (auto-detects local vs remote)
- ✅ Tool aliases for modern CLI utilities
- ✅ No dependency on cluster-nas
- ✅ Same Git identity (IMUR/rjallen22@gmail.com)

## Rollback

If needed, restore from backup:
```bash
cp ~/.config/snitcher-backups/TIMESTAMP/.zshrc.backup ~/.zshrc
```

## Testing

After setup, test both scenarios:
```bash
# Test shell loading
source ~/.zshrc

# Test SSH routing
sshcrtr  # Should work whether local or remote
```