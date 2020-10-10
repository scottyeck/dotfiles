# machine setup

## Install homebrew

See [here](https://brew.sh/). We'll use `brew cask` to install a whole buncha stuff.

```bash
$ # Install brew & brew cask (included) - see above.
$ #
$ # Then, verify everything's all good.
$ brew doctor
```

## Install Password Manager

(Instructions omitted on purpose.)

## GUI App Install

Use `brew cask` to install a million GUIs so we don't have to do it manually.

```
$ brew cask install \
  google-chrome \
  slack \
  alacritty \
  sonic-pi \
  spotify \
  alfred \
  karabiner-elements \
  figma \
  visual-studio-code \
  vlc \
  selfcontrol \
  flux \
  divvy
```

## zsh

Install `zsh`.

```
# brew install zsh
```

Then install [ `oh-my-zsh` ](https://github.com/ohmyzsh/ohmyzsh). (The install will set `zsh` as the default login shell.)

## Node tooling

* yarn
* nvm

## Dotfiles setup

1. Clone.
2. Install brew leaves via `brew bundle`
3. Run `sh init.sh` to initialize dots. - Follow steps following to Update Coc extensions.
4. Run `pgen install` to install vim plugins.

## Git Config

1. Set up 

## System Preferences

- _Dock_
  - Shrink size so it's tolerable.
  - Check "Automatically hide and show the Dock"
  - While at it, audit and remove anything unnecessary.
- _Trackpad_
  - Tap to click
- _Accessibility_
  - Set up [three-finger drag](https://www.makeuseof.com/tag/three-finger-drag-mac/)
    - _Pointer Control_ > _Trackpad Options_ > _Enable Dragging_ - Select _"three finger drag"_
    - (In older versions, the _Pointer Control_ section was titled _Mouse & Trackpad_)
- _Displays_
  - Increase resolution: _Display_ > _Scaled_ - Choose _"More space"_
- Bluetooth
  - Check _Show Bluetooth in menu bar_
  - Add external trackpad
  - Add headphones

- Download
  - Chrome
    - Login w/ personal email. Extensions will follow.
    - Settings > Default Browser > Make default
  - Divvy
    - License from email
    - Register name as "Scott Eckenthal"
    - Settings > General 
      - Check Start Divvy at Login
      - Use global shortcut: Cmd+Shift+Space
    - System Prefs > Security & Privacy > Privacy > Accessibility > Allow Divvy access
    - L / R / A / F shortcuts
  - Alfred
    - TODO: Maybe not?
  - Karabiner Elements
    - Remaps Caps Lock to Escape
    - Remaps Option / Cmd keys for external keyboard
    - TODO: Add karabiner rc to dotfiles
  - Slack
    - https://slack.com/downloads/instructions/mac
    - Configure security settings to allow for screen-sharing (via [/r/slack](https://www.reddit.com/r/Slack/comments/dfeg37/coworker_has_slack_screen_sharing_issues_on_macos/fdotj8p/))
  - Figma
  - Vs Code
    - Prettier / eslint / quit thing / project manager
  - iTerm 2
      - Enable _Scroll wheel sends arrow keys when in alternate screen mode_ (via [StackOverflow](https://stackoverflow.com/a/37879399))
    - TODO: Install oh-my-zsh
    - TODO: Change to zsh
  - Spotify
  - Fl.ux
    - https://justgetflux.com/news/pages/macquickstart/
  - SelfControl
    - https://selfcontrolapp.com/
  - VLC
    - https://get.videolan.org/

- System
  - Python
    - Install > Python 3.4 using [pyenv](https://opensource.com/article/19/5/python-3-default-mac#what-to-do).

- System Prefs
  - Dock
    - Shrink Size.
    - Check "Automatically hide and show the Dock"
  - Trackpad
    - Tap to click
  - Three-finger drag
    - Accessibility > Mouse & Trackpad > Trackpad Options > Enable Dragging - Select "three finger drag"
    - @see https://www.makeuseof.com/tag/three-finger-drag-mac/
  - Resolution
    - Displays > Display > Scaled - Choose "More space"
  - Bluetooth
    - Add external trackpad
    - Add headphones
