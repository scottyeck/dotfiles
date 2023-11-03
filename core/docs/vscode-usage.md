# vscode usage

A collection of notes related to my VSCode usage, which is - in effect - an attempt to emulate workflows I used while running neovim / tmux as a daily editor for several years.

## Gotchas

* Interacting with the file changes prompt is non-intuitive.
  * I'd like to see which option has focus, use `jk` to navigate, `<CR>` to confirm.
  * Instead you have to use System-Level shortcuts. (See for [OSX](https://github.com/microsoft/vscode/issues/80811#issuecomment-971023274)).

## Limitations

* Multi-root workspaces can't include individual files, only folders. (See [Issue](https://github.com/microsoft/vscode/issues/45177)).
