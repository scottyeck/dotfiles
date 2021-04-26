# dotfiles

> My dotfiles repo.

Here I store my dotfiles and other miscellanea regarding machine configuration. For the most part this comprises of: 

* runtime configurations, primarily for my regular `zsh` / `tmux` / `neovim` workflows.
* many tools I've written to make my life easier.
* notes on manual OSX settings. Hopefully someday I can automate these.

I've not built much here with consideration for needs beyond my own, so if you _somehow_ find yourself (1) reading this and (2) considering for some reason installing my dotfiles, proceed at your own peril.

## Install

These dotfiles are intended to be installed via a [bare git repository](https://www.atlassian.com/git/tutorials/dotfiles) - thank you to @liamfd for the [recommendation](https://github.com/liamfd/dotfiles/blob/master/README_DOTFILES.md).

```
# install dotfiles
cd $HOME
curl -o "https://raw.githubusercontent.com/scottyeck/dotfiles/tree/master/core/install" | bash

# bootstrap system
./core/bootstrap
```

## Further reading

- [Machine Setup](./core/docs/machine-setup.md)
- [TODOs](./core/docs/todo.md)
- [CLI Helper Docs](./core/docs/readme)
