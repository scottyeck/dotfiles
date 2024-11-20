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

...

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
- _Bluetooth_
  - Check _Show Bluetooth in menu bar_
  - Add external trackpad
  - Add headphones
- _Security & Privacy_
  - _Privacy_ > _Screen Recording_
    - Add videoconferencing apps (Zoom, [Slack](https://slack.com/downloads/instructions/mac), Meet via Chrome) to allow perms for screen-sharing.
  - _Privacy_ > _Accessibility_
    - Add window management apps (Divvy)
  - _Privacy_ > _Full Disk Access_
    - Grant to apps that are running terminal emulators (Alacritty, VSCode).
    - Grant to apps that allow search (Raycast).

## Manual Installs

These are applications whose installations I don't currently automate because manual installation is simpler.

- [Karabiner Elements](https://karabiner-elements.pqrs.org/docs/getting-started/installation/)
- [Rust / Rustup](https://www.rust-lang.org/learn/get-started)

### `nvim`

I've played around with various automated installation mechanisms for `nvim` - [nvenv](https://github.com/NTBBloodbath/nvenv) is written in _v_ and thus requires an esoteric toolchain, while [bob](https://github.com/MordechaiHadad/bob) doesn't currently support M1 macs. Ultimately this isn't that complicated so I'll script up a tool that does this, but in the meantime...

[Visit the neovim releases page on GitHub](https://github.com/neovim/neovim/releases) and download the latest universal _macos_ release. Then...

```
# (to avoid "unknown developer" warning)
$ xattr -c ./nvim-macos.tar.gz
$ tar xzvf nvim-macos.tar.gz
$ mv nvim-macos ./local/share/nvim-versions/{version-name}
$ ln -s ~/.local/share/nvim-versions/{version-name}/bin/nvim ~/.local/bin/nvim
```

## Manual Settings Configuration

These are settings that I don't currently automate.

### .localrc

I use a local RC file containing env settings that should differ across machines and not live in source control. See `.localrc.template`

### Headphones

Set up an ["Aggregate Audio Device"](https://www.reddit.com/r/MacOS/comments/n6trw3/how_do_i_make_mac_not_connect_to_my_bluetooth/) that uses headphones for audio input and laptop microphone for audio output. (This way when headphones are connected, the microphone is not changed and audio is not disrupted.)

### Divvy Window Management

I've used [Divvy](https://mizage.com/windivvy/) for the past 10 years or so, and although I've tried other window managers, I just can't quit this one. Blame muscle memory.

_Unfortunately_, OSX [no longer lets me configure my Divvy settings the way I want to](https://apple.stackexchange.com/a/430456), so I have to [manually migrate my settings](https://andrew.hawker.io/dailies/2021/03/01/migrate-divvy-configuration/) from one machine to another.

> Long story short, we do this with an `export` + `import` using OSX defaults.
>
> First, export settings into `com.mizage.direct.Divvy.plist` with:
>
> ```
> defaults export com.mizage.direct.Divvy com.mizage.direct.Divvy.plist
> ```
>
> Copy this binary plist to your the machine (Airdrop works here) and import settings with:
>
> ```
> defaults import com.mizage.direct.Divvy com.mizage.direct.Divvy.plist
> ```
>
> Note: These settings contain the Divvy license key so treat accordingly.

### True Color w/ Alacritty / Tmux / Nvim

In order to properly use true color, we need to install `tmux-256color` so we can specify it as our `TERM` in `tmux`. This is non-trivial so even though others have written about this (extensively), steps are consolidated below.

#### Install `tmux-256color`

(Via [bbqtd](https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95#the-right-way))

First, ensure ncurses `tic` is installed.

```
$ which tic
/usr/bin/tic
```

Download and unpack the latest nucurses terminal descriptions:

```
$ curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz
```

And compile `tmux-256color` terminal info. (This will place its result into `~/.terminfo`):

```
$ /usr/bin/tic -xe tmux-256color terminfo.src
```

Then verify

```
$ infocmp tmux-256color
```

Settings in `.zshrc` / `tmux.conf` will now work as intended.

### Enable RGB colors

(Via [Niing](https://unix.stackexchange.com/a/678901), self-proclaimed _"Neovim master"_ but hey this is helpful so maybe the proclamation is valid.)

Assuming _alacritty_ was installed using Homebrew, clone [`alacritty/alacritty`](https://github.com/alacritty/alacritty) and place it anywhere. Then...

```
$ cd path/to/cloned-alacritty-repo
$ sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
```

Again, `TERM` settings in `.zshrc` will now work as intended.
