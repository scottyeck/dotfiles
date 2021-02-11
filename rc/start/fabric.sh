#!/bin/bash

SESSION="fabric"
SESSION_EXISTS=$(tmux list-sessions | grep $SESSION)

# Default session target, specifying no active window, which
# will return us to the previously active window.
SESSION_TARGET="$SESSION"

# If session doesn't exist, we'll create a new one.
if [ "$SESSION_EXISTS" = "" ]; then

tmux new-session -d -s $SESSION

tmux rename-window -t 0 'home'
tmux send-keys -t 'home' 'cd ~'

tmux new-window -t $SESSION:1 -n 'linen'
tmux send-keys -t 'linen' 'cd ~/git/fabric/linen' C-m 'vim' C-m

tmux new-window -t $SESSION:2 -n 'cashmere'
tmux send-keys -t 'cashmere' 'cd ~/git/fabric/cashmere' C-m 'vim' C-m

tmux new-window -t $SESSION:3 -n 'www'
tmux send-keys -t 'www' 'cd ~/git/fabric/cashmere' C-m 'yw www local'

tmux new-window -t $SESSION:4 -n 'quilt'
tmux send-keys -t 'quilt' 'cd ~/git/fabric/cashmere/apps/quilt' C-m

tmux new-window -t $SESSION:5 -n 'notes'
tmux send-keys -t 'notes' 'cd ~/notes' C-m 'vim' C-m

# Specify the window to which we want to attach
SESSION_TARGET="$SESSION_TARGET:0"

fi # // if session exists

echo $SESSION_TARGET

# Now that we know the session (either new or existing)
# exists, attach to it.
tmux attach-session -t "$SESSION_TARGET"

