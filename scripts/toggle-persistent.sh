#!/bin/bash
# Toggle persistent prefix mode on/off

PERSISTENT_MODE=$(tmux show-environment -g TMUX_PERSISTENT_PREFIX 2>/dev/null | cut -d= -f2)

if [ "$PERSISTENT_MODE" = "1" ]; then
    # Turn OFF persistent mode
    tmux set-environment -g TMUX_PERSISTENT_PREFIX 0
    tmux set-option -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}],}\"#{=21:pane_title}\" %H:%M %d-%b-%y"
    tmux set-option -g status-style "bg=green,fg=black"
    tmux display-message "🔓 Persistent Prefix Mode: OFF"
else
    # Turn ON persistent mode
    tmux set-environment -g TMUX_PERSISTENT_PREFIX 1
    tmux set-option -g status-right "#[bg=yellow,fg=black,bold] ⌨  PERSISTENT PREFIX ACTIVE ⌨  #[default] \"#{=10:pane_title}\" %H:%M"
    tmux set-option -g status-style "bg=colour208,fg=black,bold"
    tmux display-message "🔒 Persistent Prefix Mode: ON (Ctrl+b Ctrl+p or Escape to exit)"
    
    # Switch to the persistent prefix key table
    tmux switch-client -T persistent-prefix
fi
