echo "Loading zsh configuration"
echo "..."

# Path to your oh-my-zsh installation.
export ZSH=/Users/$USER/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="simple"

source $ZSH/oh-my-zsh.sh
# Custom zsh configuration

alias gcur='echo $(git_current_branch)'
alias todo='todo.sh'
alias vtodo='vim $TODO_FILE'
# TODO: Uninstall nvim via brew and extend $PATH
alias nvim="~/.local/bin/nvim"
alias vim='nvim'
alias python='python3'
alias pip="pip3"

# Render an interactive git branch picker sorted by most recent commit,
# and checkout the selection.
# @via https://github.com/liamfd
alias gbrecent='git checkout $(git branch --sort=-committerdate | fzf)'
alias gbyank='git branch --sort=-committerdate | fzf | pbcopy'

alias dots="$(which git) --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dotsv="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME vim"

# Render an interactive git commit log sorted by recency and copy
# the sha of the selection the clipboard.
alias gsha="git log --oneline | fzf | awk '{print \$1}' | pbcopy"

# Initialize bitwarden and expose session as env var
alias bwi='eval $(bw login | grep export | sed "s/^$ //")'
alias bwu='eval $(bw unlock | grep export | sed "s/^$ //")'

# Mimics existing gcn! but without amend
alias gcn='git commit -v --no-edit'

# Shortcut to meme
alias meme='go run ~/go/src/github.com/nomad-software/meme/main.go'

alias brb='brew_bundle'

alias tp='tmuxproj'
alias pomo='pomodoro'

# Base vi mode configuration
# https://dougblack.io/words/zsh-vi-mode.html

bindkey -v
export KEYTIMEOUT=1

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# Override cursor behavior to detect mode
# http://lynnard.me/blog/2014/01/05/change-cursor-shape-for-zsh-vi-mode/

function _set_cursor() {
    if [[ $TMUX = '' ]]; then
      echo -ne $1
    else
      echo -ne "\ePtmux;\e\e$1\e\\"
    fi
}

function _set_block_cursor() { _set_cursor '\e[2 q' }
function _set_beam_cursor() { _set_cursor '\e[6 q' }

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
      _set_block_cursor
  else
      _set_beam_cursor
  fi
}

zle -N zle-keymap-select

# ensure beam cursor when starting new terminal
precmd_functions+=(_set_beam_cursor) #
# ensure insert mode and beam cursor when exiting vim
zle-line-init() { zle -K viins; _set_beam_cursor }

# Overload system pallette with precise gruvbox colors in nvim.
# @see https://github.com/gruvbox-community/gruvbox/wiki/Terminal-specific
source "$HOME/.vim/plugged/gruvbox/gruvbox_256palette.sh"

# Remove latency when pasting large commands
# @see https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# Bash configuration

source ~/.bashrc

# Log bash history
#
# Temporarily disabling this as it's untenable as history grows in
# size. There is prior art to resolving this, likely involving a
# regular CRON that backs up history in schedules batches rather
# than via a continuous stream, thus avoiding the bottleneck.
# @see relevant prior art:
# https://lukas.zapletalovi.com/2013/03/never-lost-your-bash-history-again.html
#
# @see https://spin.atomicobject.com/2016/05/28/log-bash-history/
# mkdir -p ~/.logs
# export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history -E 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log; fi'

# # Zsh execution of bash prompt helper
# # @see https://spin.atomicobject.com/2016/05/28/log-bash-history/
# # @see https://superuser.com/questions/735660/whats-the-zsh-equivalent-of-bashs-prompt-command
# prmptcmd() { eval "$PROMPT_COMMAND" }
# precmd_functions=(prmptcmd)

echo "Successfully loaded zsh configuration"
echo "..."

# Initialize pyenv
eval "$(pyenv init -)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
