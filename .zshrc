# https://apple.stackexchange.com/questions/148901/why-does-my-brew-installation-not-work
eval $(/opt/homebrew/bin/brew shellenv)

# Path to your oh-my-zsh installation.
export ZSH=/Users/$USER/.oh-my-zsh

# export PYTHON='/usr/local/bin/python3'
# export NODE_GYP_FORCE_PYTHON=$PYTHON

# Need to override and explicitly specify $TERM in order to use true
# RGB color with Alacritty / tmux / Neovim. See "Machine Setup" notes.
# This is likely overly restrictive, but given the value it will provide
# in the short term I'm okay with it.
# if [[ -n $TMUX ]]; then
#   export TERM="alacritty"
# else
#   export TERM="alacritty-direct"
# fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="simple"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-nvm git bundler zsh-vi-mode tmux yarn)

# nvm configuration
export NVM_NO_USE=false
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

source $ZSH/oh-my-zsh.sh
# Custom zsh configuration

alias gcur='echo $(git_current_branch)'
alias gcobak='git checkout -b $(git_current_branch)-bak'
alias todo='todo.sh'
alias vtodo='vim $TODO_FILE'
alias vim='nvim'
alias python='python3'
alias pip="pip3"

alias yf="fuzzy-yarn"
alias yfw="fuzzy-yarn workspace"

# Render an interactive git branch picker sorted by most recent commit,
# and checkout the selection.
# @via https://github.com/liamfd
alias gcho='git checkout $(git branch --sort=-committerdate | fzf)'
alias gbyank='git branch --sort=-committerdate | fzf | pbcopy'

alias dots="$(which git) --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dotsv="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME vim"

# Render an interactive git commit log sorted by recency and copy
# the sha of the selection the clipboard.
alias gsha="git log --oneline | fzf | awk '{print \$1}' | pbcopy"

alias gpmas="gh pr merge --auto --squash"

# Initialize bitwarden and expose session as env var
alias bwi='eval $(bw login | grep export | sed "s/^$ //")'
alias bwu='eval $(bw unlock | grep export | sed "s/^$ //")'

# Mimics existing gcn! but without amend
alias gcn='git commit -v --no-edit'

# Shortcut to meme
alias meme='go run ~/go/src/github.com/nomad-software/meme/main.go'

alias brb='brew_bundle'
alias cb='code_bundle'

# First attempt - try to open the Linear issue corresponding to the current branch
alias gci="echo $(git_current_branch) | sed -r 's/[^\/]*\/([^0-9]*-[0-9]+).*/\1/' | xargs -I {} lr issue {} --open"

alias tp='tmuxproj'
alias grit="gbhist | fzf | xargs git checkout"
alias grho="git reset --hard origin/$(gcur)"
# alias pomo='pomodoro'

# Base vi mode configuration
# https://dougblack.io/words/zsh-vi-mode.html

# bindkey -v
# export KEYTIMEOUT=1
#
# bindkey '^P' up-history
# bindkey '^N' down-history
# bindkey '^?' backward-delete-char
# bindkey '^h' backward-delete-char
# bindkey '^w' backward-kill-word
# bindkey '^r' history-incremental-search-backward
#
# export VI_MODE_SET_CURSOR=true
#
# # Remove latency when pasting large commands
# # @see https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
# zstyle ':bracketed-paste-magic' active-widgets '.self-*'

setopt auto_cd
cdpath=($HOME/git/hen/mvp)

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

# Initialize pyenv
# don't need pyenv either
# eval "$(pyenv init -)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 3); do /usr/bin/time $shell -i -c exit; done
}