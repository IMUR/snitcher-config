# 🚀 BEGIN HERE - Snitcher Self-Verification Guide

**You're on snitcher and want to deploy this configuration?** Start here!

This guide helps you verify your system matches what this repository expects, evaluates the repo's assumptions about your setup, and guides you through safe deployment.

## Step 1: Evaluate Repository Assumptions

This repository makes several assumptions about your snitcher setup. Let's verify each one:

### 🔍 Repository Assumptions to Verify:

**ASSUMPTION 1**: You're experiencing zsh config failures due to cluster-nas symlinks
**ASSUMPTION 2**: Your hostname is some variant of "snitcher"
**ASSUMPTION 3**: You're running Debian 13 (trixie) with zsh as default shell
**ASSUMPTION 4**: You have modern CLI tools installed (eza, bat, fd, rg)
**ASSUMPTION 5**: You're authenticated with GitHub as "IMUR"
**ASSUMPTION 6**: You have SSH config for cluster nodes (crtr, prtr, drtr)
**ASSUMPTION 7**: Public IP for cluster is 47.155.237.161
**ASSUMPTION 8**: Cluster nodes are at 192.168.254.10/20/30 (crtr/prtr/drtr)

Let's test each assumption:

## Step 2: System Verification

Run these commands on snitcher to confirm your setup:

### 2.1 Test Assumption 1 & 2: Hostname and Current Problem
```bash
# ASSUMPTION 1 & 2: Hostname and zsh config issues
hostname && whoami
# ✅ PASS: If hostname contains "snitcher" and you recognize the username
# ❌ FAIL: If this is not the snitcher machine

# ASSUMPTION 1: Check if zsh config is symlinked and broken
ls -la ~/.zshrc
echo "---"
zsh -c "source ~/.zshrc" 2>&1 | head -3
# ✅ PASS: Shows symlink to /cluster-nas AND shows errors when sourcing
# ❌ FAIL: No symlink or no errors (problem may not exist)
```

### 2.2 Test Assumption 3: OS and Shell
```bash
# ASSUMPTION 3: Debian 13 with zsh
cat /etc/os-release | grep -E "PRETTY_NAME|VERSION"
echo "Default shell: $SHELL"
echo "Current shell: $0"
# ✅ PASS: Shows Debian and zsh as default
# ⚠️ PARTIAL: Different OS/shell (config may still work)
# ❌ FAIL: Completely different environment
```

### 2.3 Test Assumption 4: Modern CLI Tools
```bash
# ASSUMPTION 4: You have eza, bat, fd, ripgrep installed
echo "Checking tool assumptions..."
ls -la ~/.cargo/bin/eza 2>/dev/null && echo "✅ eza in ~/.cargo/bin/" || echo "❌ eza not in ~/.cargo/bin/"
ls -la ~/.local/bin/bat 2>/dev/null && echo "✅ bat in ~/.local/bin/" || echo "❌ bat not in ~/.local/bin/"
ls -la ~/.local/bin/fd 2>/dev/null && echo "✅ fd in ~/.local/bin/" || echo "❌ fd not in ~/.local/bin/"
which rg >/dev/null && echo "✅ ripgrep found at $(which rg)" || echo "❌ ripgrep not found"
# ✅ PASS: Most tools found (aliases will work)
# ⚠️ PARTIAL: Some tools missing (basic config still works)
# ❌ FAIL: No tools found (config works but no enhancements)
```

### 2.4 Test Assumption 5 & 6: GitHub and SSH Setup
```bash
# ASSUMPTION 5: GitHub authentication as IMUR
ssh -T git@github.com 2>&1 | head -1
git config user.name && git config user.email
# ✅ PASS: Shows "Hi IMUR" and correct email (rjallen22@gmail.com)
# ❌ FAIL: Different user or authentication issues

# ASSUMPTION 6: SSH config for cluster nodes
echo "SSH configuration check:"
grep -E "^Host (crtr|prtr|drtr)$" ~/.ssh/config 2>/dev/null || echo "No SSH config found"
echo "SSH key count:"
ls -la ~/.ssh/id_ed25519* 2>/dev/null | wc -l
# ✅ PASS: Has SSH config for cluster nodes and multiple keys
# ⚠️ PARTIAL: Has some SSH setup but different configuration
# ❌ FAIL: No SSH configuration for cluster nodes
```

### 2.5 Test Assumption 7 & 8: Network Configuration
```bash
# ASSUMPTION 7 & 8: Cluster network setup
echo "Testing cluster network assumptions..."
echo "Public IP assumption: 47.155.237.161"
echo "Cluster nodes assumption: crtr@192.168.254.10, prtr@192.168.254.20, drtr@192.168.254.30"

# Test if we can reach cluster nodes directly (should fail when remote)
ping -c 1 -W 1 192.168.254.10 >/dev/null 2>&1 && echo "✅ Direct access to crtr (you're on local network)" || echo "❌ No direct access to crtr (you're remote - EXPECTED)"

# Check if cluster-nas mount exists but is inaccessible
ls /cluster-nas 2>/dev/null | wc -l
echo "Cluster-nas accessibility: $(ls /cluster-nas 2>/dev/null && echo 'accessible' || echo 'not accessible (expected when remote)')"
# ✅ PASS: cluster-nas not accessible (confirming remote status)
# ⚠️ UNEXPECTED: cluster-nas is accessible (you might be local)
```

## Step 3: Assumption Evaluation Results

Based on your test results above, evaluate:

### 🟢 PROCEED if you have:
- ✅ Most assumptions are correct (PASS)
- ✅ You're experiencing the zsh symlink problem
- ✅ You have the expected tools and setup

### 🟡 PROCEED WITH CAUTION if you have:
- ⚠️ Some assumptions are partial matches
- ⚠️ Different tools or paths (config will adapt)
- ⚠️ Different OS but similar environment

### 🟑 DO NOT PROCEED if you have:
- ❌ Most assumptions are wrong
- ❌ This is not snitcher or you don't have the expected problems
- ❌ Completely different environment

**📝 TIP**: Take notes on which assumptions failed - you might need to customize the config files!

## Step 4: Deploy the Configuration

If Step 1 confirms your setup matches expectations:

```bash
# Clone this repository
git clone https://github.com/IMUR/snitcher-config.git ~/.config/snitcher-config

# Review what will happen (optional)
cat ~/.config/snitcher-config/DEPLOY.md

# Run the setup script
~/.config/snitcher-config/setup.sh
```

## Step 5: Verify the Fix

After running setup:

```bash
# Test new shell configuration
source ~/.zshrc
# Expected: Should load without errors and show welcome message

# Test cluster SSH routing
echo "Testing SSH routing..."
sshcrtr  # Should attempt connection through jump host when remote
# (You can exit immediately with 'exit')

# Verify tools work
ls    # Should use eza if available
cat ~/.zshrc | head -5  # Should use bat if available
```

## Step 6: What Changed?

After successful deployment, check what was modified:

```bash
# See what was backed up
ls -la ~/.config/snitcher-backups/*/
# Should show timestamped backups of your old configs

# Confirm symlinks were replaced
ls -la ~/.zshrc
# Should now be a regular file (not symlink)

# Test offline capability
# Your configs now work whether cluster-nas is mounted or not!
```

## 🔧 Troubleshooting

### If Step 2.1 shows zsh config is NOT symlinked:
- You may have already fixed this, or have a different setup
- Check if `.zshrc` loads successfully: `source ~/.zshrc`
- You might still benefit from the smart SSH routing

### If Step 2.3 shows tools missing:
- The configuration will still work, just without fancy aliases
- Tools are optional enhancements, not requirements

### If Step 2.4 shows GitHub issues:
- You can still use the configuration
- Some git features might not work optimally

### If setup fails:
- Check the error message
- Your backups are saved in `~/.config/snitcher-backups/`
- You can restore with: `cp ~/.config/snitcher-backups/TIMESTAMP/.zshrc.backup ~/.zshrc`

## 🎯 Expected Outcome

After successful deployment:
- ✅ Shell loads quickly without cluster-nas dependency
- ✅ SSH to cluster nodes works from anywhere (auto-routing)
- ✅ Modern CLI tools integrated (eza, bat, fd, rg)
- ✅ No more configuration failures when remote
- ✅ All your SSH keys and git settings preserved

## 📞 Need Help?

If something doesn't match expectations, you can:
1. Check the error messages carefully
2. Look at `~/.config/snitcher-config/README.md` for more details
3. Your original configs are safely backed up
4. You can always restore the old setup if needed

**Ready to begin?** Start with Step 1 to evaluate assumptions, then proceed based on your results! 🚀

---

## 🧪 Quick Self-Check Summary

Before you dive into the detailed steps, here's a 30-second check:

```bash
# Quick validation (run this first)
echo "=== QUICK ASSUMPTION CHECK ==="
echo "Hostname: $(hostname)"
echo "Username: $(whoami)"
echo "Shell: $SHELL"
echo "OS: $(grep PRETTY_NAME /etc/os-release)"
ls -la ~/.zshrc | grep -q cluster-nas && echo "❗ PROBLEM CONFIRMED: zshrc symlinked to cluster-nas" || echo "No cluster-nas symlink found"
ls /cluster-nas >/dev/null 2>&1 && echo "cluster-nas accessible" || echo "cluster-nas NOT accessible (expected when remote)"
echo "GitHub user: $(git config user.name) <$(git config user.email)>"
echo "=== END QUICK CHECK ==="
```

If this shows the expected problems and identity, proceed to the full evaluation!