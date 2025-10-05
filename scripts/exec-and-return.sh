#!/bin/bash
# Execute a command and return to persistent mode even if it fails
# Usage: exec-and-return.sh "command"

PERSISTENT_MODE=$(tmux show-environment -g TMUX_PERSISTENT_PREFIX 2>/dev/null | cut -d= -f2)

if [ "$PERSISTENT_MODE" = "1" ]; then
    # Execute the command (may fail, that's ok)
    eval "tmux $*" 2>/dev/null || true
    
    # Small delay to let the command complete before returning
    sleep 0.01
    
    # Always return to persistent mode
    tmux switch-client -T persistent-prefix 2>/dev/null || true
fi
