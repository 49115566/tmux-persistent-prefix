#!/bin/bash
# Tmux Persistent Prefix Mode Installer
# Safely installs persistent prefix mode while preserving existing configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation paths
TMUX_CONF="$HOME/.tmux.conf"
INSTALL_DIR="$HOME/.tmux/persistent-prefix"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   Tmux Persistent Prefix Mode - Installer                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Check if tmux is installed
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        print_error "tmux is not installed. Please install tmux first."
        exit 1
    fi
    
    local version=$(tmux -V | grep -oP '\d+\.\d+' | head -1)
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    
    print_info "Found tmux version $version"
    
    if [ "$major" -lt 2 ] || ([ "$major" -eq 2 ] && [ "$minor" -lt 9 ]); then
        print_warning "tmux 2.9 or later is recommended. You have $version."
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "tmux version OK"
}

# Backup existing configuration
backup_config() {
    if [ -f "$TMUX_CONF" ]; then
        local backup="$TMUX_CONF.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$TMUX_CONF" "$backup"
        print_success "Backed up existing config to: $backup"
        echo "$backup" > /tmp/tmux-backup-path.txt
    else
        print_info "No existing tmux config found"
    fi
}

# Check for keybinding conflicts
check_conflicts() {
    local conflict_key=""
    
    if [ -f "$TMUX_CONF" ]; then
        # Check for C-p binding
        if grep -q "bind.*C-p" "$TMUX_CONF"; then
            conflict_key="C-p"
        fi
    fi
    
    if [ -n "$conflict_key" ]; then
        print_warning "Found existing binding for $conflict_key in your config"
        echo ""
        echo "Options:"
        echo "  1) Use C-p anyway (overwrites existing binding)"
        echo "  2) Use alternative: M-p (Alt+p)"
        echo "  3) Use alternative: C-o (Ctrl+o)"
        echo "  4) Abort installation"
        echo ""
        read -p "Choose option (1-4): " -n 1 -r choice
        echo ""
        
        case $choice in
            1) return 0 ;;
            2) ACTIVATION_KEY="M-p"; print_info "Using Alt+p as activation key" ;;
            3) ACTIVATION_KEY="C-o"; print_info "Using Ctrl+o as activation key" ;;
            4) print_info "Installation aborted"; exit 0 ;;
            *) print_error "Invalid option"; exit 1 ;;
        esac
    else
        ACTIVATION_KEY="C-p"
        print_success "No keybinding conflicts detected"
    fi
}

# Create installation directory
create_install_dir() {
    mkdir -p "$INSTALL_DIR"
    print_success "Created installation directory: $INSTALL_DIR"
}

# Install scripts
install_scripts() {
    print_info "Installing scripts..."
    
    cp "$SCRIPT_DIR/scripts/exec-and-return.sh" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/scripts/exec-modal-exit.sh" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/scripts/toggle-persistent.sh" "$INSTALL_DIR/"
    
    chmod +x "$INSTALL_DIR"/*.sh
    
    print_success "Scripts installed"
}

# Update configuration file
update_tmux_config() {
    print_info "Updating tmux configuration..."
    
    # Create temp config with proper paths
    local temp_conf=$(mktemp)
    cp "$SCRIPT_DIR/persistent-prefix.conf" "$temp_conf"
    
    # Replace placeholder with actual installation path
    sed -i "s|PERSISTENT_PREFIX_SCRIPTS_PATH=\"~/.tmux/persistent-prefix\"|PERSISTENT_PREFIX_SCRIPTS_PATH=\"$INSTALL_DIR\"|g" "$temp_conf"
    
    # Replace activation key if needed
    if [ "$ACTIVATION_KEY" != "C-p" ]; then
        sed -i "s|bind-key -T prefix C-p|bind-key -T prefix $ACTIVATION_KEY|g" "$temp_conf"
        sed -i "s|bind-key -T persistent-prefix C-p|bind-key -T persistent-prefix $ACTIVATION_KEY|g" "$temp_conf"
        sed -i "s|Ctrl+b Ctrl+p|Ctrl+b $ACTIVATION_KEY|g" "$temp_conf"
    fi
    
    # Check if config already has our source line
    if [ -f "$TMUX_CONF" ] && grep -q "persistent-prefix.conf" "$TMUX_CONF"; then
        print_warning "Persistent prefix already configured, updating..."
        # Remove old configuration
        sed -i '/# BEGIN PERSISTENT PREFIX/,/# END PERSISTENT PREFIX/d' "$TMUX_CONF"
    fi
    
    # Add source line to tmux.conf
    cat >> "$TMUX_CONF" << EOF

# BEGIN PERSISTENT PREFIX MODE
# Added by tmux-persistent-prefix installer
source-file $INSTALL_DIR/persistent-prefix.conf
# END PERSISTENT PREFIX MODE
EOF
    
    # Copy the conf file to install dir
    cp "$temp_conf" "$INSTALL_DIR/persistent-prefix.conf"
    rm "$temp_conf"
    
    print_success "Configuration updated"
}

# Test configuration
test_config() {
    print_info "Testing configuration..."
    
    if tmux -f "$TMUX_CONF" -L test-persistent start-server \; kill-server 2>&1 | grep -i error; then
        print_error "Configuration test failed"
        
        # Restore backup
        if [ -f /tmp/tmux-backup-path.txt ]; then
            local backup=$(cat /tmp/tmux-backup-path.txt)
            cp "$backup" "$TMUX_CONF"
            print_info "Restored backup configuration"
            rm /tmp/tmux-backup-path.txt
        fi
        
        exit 1
    else
        print_success "Configuration test passed"
    fi
}

# Reload tmux if running
reload_tmux() {
    if tmux list-sessions &>/dev/null; then
        print_info "Tmux is running. Reload configuration?"
        read -p "Reload now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tmux source-file "$TMUX_CONF"
            print_success "Configuration reloaded in running tmux sessions"
        else
            print_info "Skipped reload. Run 'tmux source-file ~/.tmux.conf' manually"
        fi
    fi
}

# Print usage instructions
print_usage() {
    local key_display="Ctrl+b Ctrl+p"
    if [ "$ACTIVATION_KEY" = "M-p" ]; then
        key_display="Ctrl+b Alt+p"
    elif [ "$ACTIVATION_KEY" = "C-o" ]; then
        key_display="Ctrl+b Ctrl+o"
    fi
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   Installation Complete! ✓                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🎉 Tmux Persistent Prefix Mode is now installed!"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Quick Start"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  1. Start tmux (or it's already running)"
    echo "  2. Press: $key_display"
    echo "  3. Status bar turns orange: ⌨ PERSISTENT MODE ⌨"
    echo "  4. Use commands without Ctrl+b: c, n, p, %, \", etc."
    echo "  5. Exit: Press Ctrl+p or Escape"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Files Installed"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  Config:  $INSTALL_DIR/persistent-prefix.conf"
    echo "  Scripts: $INSTALL_DIR/*.sh"
    echo "  Main:    $TMUX_CONF (updated)"
    echo ""
    if [ -f /tmp/tmux-backup-path.txt ]; then
        local backup=$(cat /tmp/tmux-backup-path.txt)
        echo "  Backup:  $backup"
        rm /tmp/tmux-backup-path.txt
    fi
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Documentation"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  README:   $SCRIPT_DIR/README.md"
    echo "  Docs:     $SCRIPT_DIR/docs/"
    echo "  Examples: $SCRIPT_DIR/examples/"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
}

# Uninstall function
uninstall() {
    print_header
    print_warning "This will remove tmux persistent prefix mode"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstall cancelled"
        exit 0
    fi
    
    # Remove from tmux.conf
    if [ -f "$TMUX_CONF" ]; then
        sed -i '/# BEGIN PERSISTENT PREFIX/,/# END PERSISTENT PREFIX/d' "$TMUX_CONF"
        print_success "Removed from $TMUX_CONF"
    fi
    
    # Remove installation directory
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_success "Removed $INSTALL_DIR"
    fi
    
    print_success "Uninstallation complete"
    exit 0
}

# Main installation flow
main() {
    # Check for uninstall flag
    if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
        uninstall
    fi
    
    print_header
    
    check_tmux
    backup_config
    check_conflicts
    create_install_dir
    install_scripts
    update_tmux_config
    test_config
    reload_tmux
    print_usage
}

# Run main function
main "$@"
