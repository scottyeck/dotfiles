#!/bin/bash

SESSION="debugging-exercise"
SESSION_EXISTS=$(tmux list-sessions | grep $SESSION)

# Default session target, specifying no active window, which
# will return us to the previously active window.
SESSION_TARGET="$SESSION"

# If session doesn't exist, we'll create a new one.
if [ "$SESSION_EXISTS" = "" ]; then

tmux new-session -d -s $SESSION

tmux rename-window -t 0 'home'

tmux new-window -t $SESSION:1 -n 'app'
tmux send-keys -t 'app' 'cd debugging-exercise' C-m 'yarn dev' C-m

tmux new-window -t $SESSION:2 -n 'tunnel'
tmux send-keys -t 'tunnel' 'cd debugging-exercise' C-m '' C-m

# Specify the window to which we want to attach
SESSION_TARGET="$SESSION_TARGET:0"

fi # // if session exists

echo $SESSION_TARGET

# Now that we know the session (either new or existing)
# exists, attach to it.
tmux attach-session -t "$SESSION_TARGET"

