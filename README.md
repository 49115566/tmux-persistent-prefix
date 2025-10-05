# Tmux Persistent Prefix Mode

A tmux configuration that adds a **toggle-able persistent prefix mode**, eliminating the need to repeatedly press `Ctrl+b` before each command. When activated, you can execute multiple tmux commands in succession without pressing the prefix key each time.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![tmux](https://img.shields.io/badge/tmux-2.9%2B-green.svg)](https://github.com/tmux/tmux)

## 🎯 What Problem Does This Solve?

When working with tmux, you normally need to press `Ctrl+b` before every command:
```
Ctrl+b c    (create window)
Ctrl+b %    (split pane)
Ctrl+b n    (next window)
Ctrl+b o    (next pane)
```

With persistent prefix mode, you press `Ctrl+b` once to enter the mode, then execute commands freely:
```
Ctrl+b Ctrl+p    (enter persistent mode)
c                (create window)
%                (split pane)
n                (next window)
o                (next pane)
Ctrl+p           (exit persistent mode)
```

## ✨ Features

- **Toggle-able persistent mode** - Not just sticky keys, but a true modal interface
- **Visual feedback** - Status bar turns orange with keyboard emoji when active
- **Error resilient** - Commands that fail don't break persistent mode
- **Full keybinding support** - All 70+ default tmux commands work
- **Smart modal handling** - Copy mode and other modal commands work naturally
- **Easy installation** - Smart installer preserves existing configurations
- **Configurable activation key** - Choose your preferred keybinding

## 🚀 Quick Start

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/tmux-persistent-prefix.git
cd tmux-persistent-prefix
./install.sh
```

The installer will:
- ✓ Backup your existing tmux configuration
- ✓ Check for keybinding conflicts
- ✓ Install persistent prefix mode
- ✓ Preserve your custom settings

### Usage

1. **Activate:** Press `Ctrl+b` then `Ctrl+p`
2. **Status bar turns orange** with "⌨ PERSISTENT MODE ⌨"
3. **Use any tmux command** without `Ctrl+b`: `c`, `n`, `%`, `"`, `o`, arrows, etc.
4. **Deactivate:** Press `Ctrl+p` or `Escape`

### Example: Creating a Multi-Pane Layout

**Before (5 key combinations):**
```
Ctrl+b %    Ctrl+b "    Ctrl+b o    Ctrl+b "    Ctrl+b o
```

**After (1 activation + 5 simple keys + 1 deactivation):**
```
Ctrl+b Ctrl+p    %    "    o    "  o  Escape (or Ctrl+p)
```

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [FAQ](docs/FAQ.md)

## 🎮 Commands Reference

### Commands that STAY in Persistent Mode

Most commands keep you in persistent mode:
- **Windows:** `c`, `n`, `p`, `l`, `0-9`, `&`, `,`, `.`
- **Panes:** `%`, `"`, `o`, `;`, `z`, `x`, `!`, `{`, `}`
- **Navigation:** Arrow keys, `M-arrows`, `C-arrows`
- **Layouts:** `Space`, `M-1` through `M-5`, `E`
- **Other:** `i`, `r`, `m`, `M`, `]`, `~`, `<`, `>`

### Commands that EXIT Persistent Mode (Modal)

These commands enter their own modes and intentionally exit persistent mode so their native keybindings work:
- **`[`** - Copy mode (use `q` to quit, `Escape` to exit)
- **`q`** - Display panes (use number keys to select)
- **`s`** - Choose session tree
- **`w`** - Choose window tree
- **`t`** - Clock mode
- **`C`** - Customize mode
- **`D`** - Choose client

After using a modal command, simply re-enter persistent mode with `Ctrl+b Ctrl+p`.

## 🔧 Configuration

### Change Activation Key

Edit `~/.tmux.conf` and modify the activation binding:
```tmux
# Change C-p to your preferred key
bind-key -T prefix C-p \
    set-environment -g TMUX_PERSISTENT_PREFIX 1 \; \
    ...
```

### Customize Colors

```tmux
# Change status bar color when active
set-option -g status-style "bg=colour208,fg=black,bold" \; \
```

## 🛠️ Requirements

- tmux 2.9 or later
- Bash (for installation scripts)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Created to solve the repetitive strain of pressing `Ctrl+b` constantly when working with complex tmux layouts.

## 📊 Technical Details

### How It Works

1. Uses tmux's native **key table** feature for performance
2. Custom `persistent-prefix` key table contains all command bindings
3. Each binding executes and returns to the persistent table
4. Environment variable tracks state
5. Wrapper scripts handle errors gracefully
6. Modal commands exit to their own key tables

### Architecture

```
prefix table (Ctrl+b)
    ↓
persistent-prefix table (Ctrl+p to enter)
    ↓
Commands → exec-and-return.sh → Back to persistent-prefix
    OR
Modal commands → exec-modal-exit.sh → Exit to normal mode
```

## 🐛 Known Issues

- Some terminal emulators may not support all key combinations
- Some commands don't function in persistent mode (e.g. Ctrl+b : doesn't work to my knowledge)
- Modal commands exit persistent mode by design (this is a feature, not a bug!)

## 📈 Roadmap

- [ ] Dynamic command support (parses existing commands and saves them to a table rather than using a premade table)
- [ ] Optional sound/visual notifications
- [ ] Per-session persistent mode settings
- [ ] Integration with tmux plugins
- [ ] Integration wtih tmux itself??? (feel free to make an official integration of this!)

## 💬 Support

- 🐛 [Report a bug](https://github.com/49115566/tmux-persistent-prefix/issues)
- 💡 [Request a feature](https://github.com/49115566/tmux-persistent-prefix/issues)
- 📖 [Read the docs](docs/)

---

**Made with ❤️ for tmux users who are tired of Ctrl+b spam**
