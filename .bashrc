echo "Loading remote bash configuration"
echo "..."

# npm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvmCKAGES="${HOME}/.npm-packages"

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# manpages
unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

# dotfiles
PATH="$PATH:$HOME/bin"

# node_modules
PATH="$PATH:$HOME/node_modules/.bin"

# Provide node some more memory
export NODE_OPTIONS="--max-old-space-size=4096"

# cargo
PATH="$PATH:$HOME/.cargo/bin"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
PATH="$PATH:$PYENV_ROOT/bin"

# go
PATH="$PATH:/usr/local/go/bin"

PATH="$PATH:/usr/local/opt/ruby/bin"

source "$HOME/.cargo/env"

export TMUX_PROJ_DIR="$HOME/.tmuxproj"

# sqlite, via brew
# > sqlite is keg-only, which means it was not symlinked into /usr/local,
# > because macOS provides an older sqlite3.
PATH="$PATH:/usr/local/opt/sqlite/bin"

# note.sh
export NOTE_DIR=$HOME/notes/daily

# Ensure we're using the corect ctags
# @see https://www.freecodecamp.org/news/make-your-vim-smarter-using-ctrlp-and-ctags-846fc12178a4/
alias ctags="$(brew --prefix)/bin/ctags"

export PATH
export EDITOR='vim'

# If vim is launched inside a Neovim terminal, launch
# vanilla vim and not neovim.
# @see https://github.com/neovim/neovim/issues/9960#issuecomment-488269954
if [[ -n "${NVIM_LISTEN_ADDRESS}" ]]
then
    # TODO update the path each time Vim has a major upgrade
    export VIMRUNTIME=/usr/share/vim/vim81
fi

LOCAL_CONFIG_FILE="/Users/$USER/.localrc"

if [ -f "$LOCAL_CONFIG_FILE" ]; then
  echo "Loading local bash configuration"
  echo '...'
  source $LOCAL_CONFIG_FILE
  echo "Successfully loaded local bash configuration"
  echo '...'
else
  echo "Warning - No local bash configuration found. You may be missing important environment settings."
  echo "Please ensure the existence of /Users/$USER/.localrc"
  echo "..."
fi

echo "Successfully loaded remote bash configuration"
echo "..."
source "$HOME/.cargo/env"
