#!/bin/bash
# Execute a command that enters a mode and exits persistent prefix
# Used for: copy mode, display-panes, clock, choose-tree, etc.
# These modes have their own keybindings and shouldn't stay in persistent mode

PERSISTENT_MODE=$(tmux show-environment -g TMUX_PERSISTENT_PREFIX 2>/dev/null | cut -d= -f2)

if [ "$PERSISTENT_MODE" = "1" ]; then
    # Execute the command
    eval "tmux $*" 2>/dev/null || true
    
    # Note: We DON'T return to persistent mode because these commands
    # enter their own modal states (copy mode, pane selection, etc.)
    # User will need to re-enter persistent mode when done with the modal command
fi
