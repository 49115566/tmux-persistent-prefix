# Installation Guide

## Quick Installation

```bash
git clone https://github.com/49115566/tmux-persistent-prefix.git
cd tmux-persistent-prefix
chmod +x install.sh
./install.sh
```

The installer will:
1. ✓ Check tmux version (2.9+ required)
2. ✓ Backup existing configuration
3. ✓ Detect keybinding conflicts
4. ✓ Install scripts and configuration
5. ✓ Test configuration
6. ✓ Optionally reload tmux

## Manual Installation

If you prefer manual installation:

### 1. Copy Scripts

```bash
mkdir -p ~/.tmux/persistent-prefix
cp scripts/*.sh ~/.tmux/persistent-prefix/
chmod +x ~/.tmux/persistent-prefix/*.sh
```

### 2. Update tmux Configuration

Add to your `~/.tmux.conf`:

```tmux
# Persistent Prefix Mode
source-file ~/.tmux/persistent-prefix/persistent-prefix.conf
```

### 3. Copy Configuration

```bash
cp persistent-prefix.conf ~/.tmux/persistent-prefix/
```

### 4. Reload tmux

```bash
tmux source-file ~/.tmux.conf
```

## Handling Conflicts

### Ctrl+p Conflict

If you already use `Ctrl+b Ctrl+p`, the installer will offer alternatives:
- `Alt+p` (recommended)
- `Ctrl+o`
- Custom key (edit configuration manually)

### Existing Configuration

The installer preserves your existing tmux configuration. It only adds:
```tmux
# BEGIN PERSISTENT PREFIX MODE
source-file ~/.tmux/persistent-prefix/persistent-prefix.conf
# END PERSISTENT PREFIX MODE
```

## Requirements

- tmux 2.9 or later
- Bash (for scripts)
- Unix-like OS (Linux, macOS, BSD)

## Uninstallation

```bash
./install.sh --uninstall
```

Or manually:
1. Remove `source-file` line from `~/.tmux.conf`
2. Delete `~/.tmux/persistent-prefix/` directory
3. Reload tmux: `tmux source-file ~/.tmux.conf`

## Troubleshooting Installation

### Permission Denied

```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

### Configuration Errors

Test your tmux configuration:
```bash
tmux -f ~/.tmux.conf -L test start-server \; kill-server
```

### Scripts Not Found

Ensure scripts are executable and in the correct location:
```bash
ls -la ~/.tmux/persistent-prefix/
```

All `.sh` files should have execute permissions (`-rwxr-xr-x`).
