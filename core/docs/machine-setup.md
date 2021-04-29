# machine setup

```
# 1. install dotfiles

cd $HOME
curl -o "https://raw.githubusercontent.com/scottyeck/dotfiles/tree/master/core/install" | bash

# 2. bootstrap system

./core/bootstrap

```
…

## Install Password Manager(s)

(Instructions omitted on purpose.)

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
  - Vs Code
    - Prettier / eslint / quit thing / project manager
  - Fl.ux
    - https://justgetflux.com/news/pages/macquickstart/
- System
  - Python
    - Install > Python 3.4 using [pyenv](https://opensource.com/article/19/5/python-3-default-mac#what-to-do).

## Manual Installs

These are applications whose installations I don't currently automate because manual installation is simpler.

* [Karabiner Elements](https://karabiner-elements.pqrs.org/docs/getting-started/installation/)
