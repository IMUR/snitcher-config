#!/bin/bash
# Snitcher Remote Access Configuration Setup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
BACKUP_DIR="$HOME/.config/snitcher-backups/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running with --update flag
UPDATE_MODE=false
if [[ "$1" == "--update" ]]; then
    UPDATE_MODE=true
    print_info "Running in update mode"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
print_info "Backup directory: $BACKUP_DIR"

# Function to backup and install file
install_file() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    # Backup existing file if it exists
    if [[ -f "$dest" ]]; then
        cp "$dest" "$BACKUP_DIR/$(basename "$dest").backup"
        print_info "Backed up existing $desc"
    fi

    # Install new file
    cp "$src" "$dest"
    print_info "Installed $desc"
}

# Function to create resilient config with fallback
create_resilient_config() {
    local config_type="$1"
    local target_file="$2"

    cat > "$target_file" << 'EOF'
# Resilient configuration wrapper for snitcher
# Works whether connected to cluster or not

# Check if cluster-nas is available (1 second timeout)
CLUSTER_AVAILABLE=false
if timeout 1 test -d /cluster-nas 2>/dev/null; then
    CLUSTER_AVAILABLE=true
fi

# Load appropriate configuration
if [[ "$CLUSTER_AVAILABLE" == "true" ]] && [[ -f /cluster-nas/configs/CONFIG_TYPE ]]; then
    # Use cluster configuration if available
    source /cluster-nas/configs/CONFIG_TYPE
else
    # Use local configuration
    source ~/.config/snitcher-config/shell/CONFIG_TYPE.local
fi
EOF

    sed -i "s/CONFIG_TYPE/$config_type/g" "$target_file"
}

# 1. Setup shell configurations
print_info "Setting up shell configurations..."

# Bash configuration
if [[ ! "$UPDATE_MODE" == true ]] || [[ ! -f "$HOME/.bashrc" ]]; then
    install_file "$CONFIG_DIR/shell/bashrc" "$HOME/.bashrc" ".bashrc"
fi

# Zsh configuration (if zsh is installed)
if command -v zsh &> /dev/null; then
    if [[ ! "$UPDATE_MODE" == true ]] || [[ ! -f "$HOME/.zshrc" ]]; then
        install_file "$CONFIG_DIR/shell/zshrc" "$HOME/.zshrc" ".zshrc"
    fi
fi

# 2. Setup SSH configuration (smart enhancement)
print_info "Enhancing SSH configuration..."

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Check for existing SSH config
if [[ -f "$HOME/.ssh/config" ]]; then
    print_info "Found existing SSH config - will enhance rather than replace"

    # Check if our enhancements are already present
    if ! grep -q "# Snitcher SSH Configuration Enhancement" "$HOME/.ssh/config"; then
        print_info "Adding smart routing enhancements to existing SSH config"
        echo "" >> "$HOME/.ssh/config"
        cat "$CONFIG_DIR/ssh/config-enhancement" >> "$HOME/.ssh/config"
        print_info "✅ Enhanced SSH config with smart routing"
        print_info "Your existing SSH hosts (crtr, prtr, drtr) still work for local access"
        print_info "New smart hosts available: crtr-smart, prtr-smart, drtr-smart"
        print_info "Explicit remote hosts: crtr-remote, prtr-remote, drtr-remote"
    else
        print_warn "SSH enhancements already present, skipping"
    fi
else
    # No existing config - install full config
    install_file "$CONFIG_DIR/ssh/config" "$HOME/.ssh/config" "SSH config"
    chmod 600 "$HOME/.ssh/config"
    print_info "Installed complete SSH configuration"
fi

# 3. Setup Git configuration (if not exists)
if [[ ! -f "$HOME/.gitconfig" ]] || [[ "$UPDATE_MODE" == true ]]; then
    print_info "Setting up Git configuration..."
    install_file "$CONFIG_DIR/git/gitconfig" "$HOME/.gitconfig" "Git config"
fi

# 4. Setup Tmux configuration
if command -v tmux &> /dev/null; then
    print_info "Setting up Tmux configuration..."
    install_file "$CONFIG_DIR/tmux/tmux.conf" "$HOME/.tmux.conf" "Tmux config"
fi

# 5. Create local bin directory
mkdir -p "$HOME/.local/bin"
print_info "Created ~/.local/bin directory"

# 6. Test configuration
print_info "Testing configuration..."

# Test shell sourcing
if bash -c "source $HOME/.bashrc" 2>/dev/null; then
    print_info "✓ Bash configuration loads successfully"
else
    print_warn "⚠ Bash configuration may have issues"
fi

if command -v zsh &> /dev/null; then
    if zsh -c "source $HOME/.zshrc" 2>/dev/null; then
        print_info "✓ Zsh configuration loads successfully"
    else
        print_warn "⚠ Zsh configuration may have issues"
    fi
fi

# 7. Check SSH key existence
if [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
    print_info "✓ SSH keys found"
else
    print_warn "⚠ No SSH keys found. You may need to generate them:"
    print_warn "  ssh-keygen -t ed25519 -C 'snitcher@remote'"
fi

# 8. Final message
echo ""
print_info "========================================="
print_info "Snitcher configuration complete!"
print_info "========================================="
echo ""
print_info "Configuration features:"
echo "  • Resilient shell configs (work offline)"
echo "  • Smart SSH routing (auto-detects network)"
echo "  • Essential tool configurations"
echo "  • Automatic cluster access setup"
echo ""

if [[ "$UPDATE_MODE" == true ]]; then
    print_info "Update complete. Restart your shell to apply changes."
else
    print_info "Setup complete. Restart your shell to apply changes:"
    echo "  exec \$SHELL"
fi

echo ""
print_info "Backups saved to: $BACKUP_DIR"