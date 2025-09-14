# Snitcher Remote Access Configuration

Lightweight configuration for snitcher as a remote access point to the Co-lab cluster.

## Purpose

Snitcher is a mobile laptop that serves as a remote access point to the cluster. Unlike the core cluster nodes (cooperator, projector, director), snitcher:

- May operate disconnected from the cluster network
- Needs to work seamlessly when remote
- Requires minimal dependencies
- Focuses on SSH access rather than cluster services

## Quick Setup on Snitcher

**Current Issue**: snitcher's `.zshrc` is symlinked to `/cluster-nas/configs/zsh/zshrc` which fails when remote.

```bash
# Clone this repo on snitcher
git clone https://github.com/IMUR/snitcher-config.git ~/.config/snitcher-config

# Run the setup script (will backup existing symlinks)
~/.config/snitcher-config/setup.sh

# Restart shell to apply changes
exec $SHELL
```

## What This Provides

### 1. Shell Configuration
- Resilient `.bashrc` and `.zshrc` that work offline
- No dependencies on `/cluster-nas`
- Local tool configurations

### 2. SSH Configuration
- Pre-configured access to cluster nodes
- Smart ProxyJump through cooperator when remote
- SSH key management

### 3. Essential Tools
- Git configuration
- Tmux configuration
- Basic aliases and functions
- Python/pip setup

## Network Detection

The configuration automatically detects if you're on the local network or remote:

- **Local**: Direct SSH to cluster nodes
- **Remote**: Automatic ProxyJump through cooperator's public IP

## Files Included

```
├── setup.sh                 # Main setup script
├── shell/
│   ├── bashrc              # Bash configuration
│   ├── zshrc               # Zsh configuration
│   └── aliases             # Common aliases
├── ssh/
│   ├── config              # SSH client configuration
│   └── known_hosts.template # Cluster host keys
├── git/
│   └── gitconfig           # Git configuration
└── tmux/
    └── tmux.conf           # Tmux configuration
```

## Requirements

- ✅ Debian GNU/Linux 13 (trixie) - **CONFIRMED ON SNITCHER**
- ✅ SSH client with cluster keys - **CONFIRMED (multiple keys setup)**
- ✅ Git with GitHub access - **CONFIRMED (authenticated as IMUR)**
- ✅ Zsh (default shell) - **CONFIRMED**

## Manual Configuration

If you prefer manual setup:

1. Copy shell configs to home directory
2. Copy SSH config to `~/.ssh/config`
3. Ensure SSH keys are in place
4. Source the shell configuration

## Updating

```bash
cd ~/.config/snitcher-config
git pull
./setup.sh --update
```