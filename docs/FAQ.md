# Frequently Asked Questions

## General Questions

### Q: What is persistent prefix mode?

A: It's a tmux configuration that lets you toggle a mode where you don't need to press `Ctrl+b` before each command. Press `Ctrl+b Ctrl+p` once, then use commands like `c`, `n`, `%` directly until you exit the mode.

### Q: Is this different from sticky keys?

A: Yes! This is a full toggle mode. Sticky keys would auto-exit after one command. Persistent prefix mode stays active until you explicitly toggle it off with `Ctrl+p` or `Escape`.

### Q: Will this break my existing tmux setup?

A: No. The installer preserves your existing configuration and only adds the persistent prefix feature. All your existing keybindings remain unchanged.

## Usage Questions

### Q: Why do some commands exit persistent mode?

A: Modal commands like copy mode `[`, display-panes `q`, and choose-tree `s`/`w` enter their own modes with their own keybindings. They exit persistent mode so their native keys work properly (like `q` to quit copy mode). Simply re-enter persistent mode with `Ctrl+b Ctrl+p` when done.

### Q: Can I use this with tmux plugins?

A: Yes! This works alongside tmux plugins like tmux-resurrect, tmux-continuum, etc.

### Q: Does this work with custom prefix keys?

A: Yes! If you've changed your prefix from `Ctrl+b` to something else, persistent prefix mode works with your custom prefix.

### Q: Can I change the activation key from Ctrl+p?

A: Yes! Edit `~/.tmux/persistent-prefix/persistent-prefix.conf` and change `C-p` to your preferred key. Or run the installer which detects conflicts and offers alternatives.

## Technical Questions

### Q: What tmux version do I need?

A: tmux 2.9 or later is required. The configuration uses key tables which were improved in version 2.9.

### Q: Why don't repeatable keys work?

A: The `-r` (repeat) flag is incompatible with the wrapper script approach. Instead, just press the key multiple times. With `repeat-time` set to 0, this actually feels more responsive.

### Q: What's the performance impact?

A: Minimal. Commands run through lightweight bash wrapper scripts that add ~10ms delay. This is imperceptible in normal use.

### Q: Can I use this in nested tmux sessions?

A: Yes, but you'll need to use `Ctrl+b b` to send the prefix to the inner session first, then activate persistent mode there.

## Troubleshooting Questions

### Q: Commands aren't working in persistent mode

A: Check that:
1. Scripts are executable: `ls -la ~/.tmux/persistent-prefix/`
2. Scripts exist in the right location
3. Configuration is loaded: `tmux source-file ~/.tmux.conf`

### Q: Arrow keys exit persistent mode

A: This should be fixed in the current version. Make sure you have the latest configuration with `repeat-time` set to 0.

### Q: Errors exit persistent mode

A: This should be fixed in the current version. The `exec-and-return.sh` script catches errors gracefully.

### Q: Status bar doesn't change color

A: Check your terminal supports colors. Try: `echo -e "\e[33mYellow\e[0m"`

### Q: Copy mode doesn't work right

A: Copy mode intentionally exits persistent mode so you can use `q`, `Escape`, etc. naturally. Re-enter persistent mode after exiting copy mode.

## Configuration Questions

### Q: Can I customize the status bar message?

A: Yes! Edit `persistent-prefix.conf` and change this line:
```tmux
set-option -g status-right "#[bg=yellow,fg=black,bold] ⌨  PERSISTENT MODE ⌨  #[default] %H:%M"
```

### Q: Can I add custom commands to persistent mode?

A: Yes! Add to `persistent-prefix.conf`:
```tmux
bind-key -T persistent-prefix <key> run-shell "~/.tmux/persistent-prefix/exec-and-return.sh <command>"
```

### Q: Can I have different activation keys for different sessions?

A: Not currently. The configuration is global. However, you could create session-specific config files.

## Comparison Questions

### Q: How is this different from tmux-fingers or tmux-copycat?

A: Those are plugins for specific tasks (hint mode, pattern matching). Persistent prefix mode is about the core tmux interface - reducing the need to repeatedly press the prefix key.

### Q: Is this better than using shorter prefix keys?

A: It's different. A shorter prefix (like `` ` ``) is faster to press, but you still press it repeatedly. Persistent mode means pressing it once for multiple commands.

### Q: Should I use this or learn to type Ctrl+b faster?

A: Why not both? You can use persistent mode when setting up layouts (multiple commands in a row) and normal mode for single commands. It's a tool, not a replacement.

## Installation Questions

### Q: Can I install without the installer script?

A: Yes! See [Manual Installation](INSTALLATION.md#manual-installation) in the installation guide.

### Q: How do I update to a newer version?

A: Run `git pull` in the repo directory, then run `./install.sh` again. It will update the scripts and configuration.

### Q: How do I uninstall?

A: Run `./install.sh --uninstall` or manually remove:
1. The `source-file` line from `~/.tmux.conf`
2. The `~/.tmux/persistent-prefix/` directory

## Still Have Questions?

Open an issue on GitHub with your question!
