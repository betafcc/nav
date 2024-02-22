<div align="center">

<h1>
nav
</h1>

zsh navigation at the speed of thought with `alt` + `arrow`


<picture>
  <source srcset="./demo/demo-rec.svg">
  <img alt="Screencast" src="./demo/demo-rec.svg">
</picture>

</div>

Usage
-----

The shortcuts can be customized, see [config](#config). By default they are inspired by the ones you already use on file explorer and browser:

`alt` + `↑` - go up a directory

`alt` + `↓` - fuzzy find directory below current one

`alt` + `←` - go back in directory history

`alt` + `→` - go forward in directory history

Installation
------------

The following command installs all dependencies, nav itself, adds sourcing command to "~/.zshrc" and reset the shell

<table>
<tbody>
<tr><th>Linux</th></tr>
<tr>
<td>
<pre>
apt install fzf bfs exa &&
  cd ~ &&
  git clone https://github.com/betafcc/nav &&
  echo -e '\nsource "${HOME}/nav/nav.zsh" && nav bindkeys\n' >> .zshrc &&
  exec $SHELL
</pre>
</td>
</tr>

<tr><th>Mac</th></tr>
<tr>
<td>
<pre>
brew install fzf bfs exa &&
  cd ~ &&
  git clone https://github.com/betafcc/nav &&
  echo -e '\nsource "${HOME}/nav/nav.zsh" && nav bindkeys\n' >> .zshrc &&
  exec $SHELL
</pre>
</td>
</tr>
</tbody>
</table>


Custom Installation
------------


### Install dependencies

#### [fzf](https://github.com/junegunn/fzf) `required`

> A command-line fuzzy finder

`nav` uses it to fuzzy find directories with the `alt` + `down` command

<table>
<tbody>
<tr><th>Linux</th><th>Mac</th></tr>
<tr><td><pre>apt install fzf</pre></td><td><pre>brew install fzf</pre></td></tr>
</tbody>
</table>

#### [bfs](https://github.com/tavianator/bfs) `recommended`

> A breadth-first version of the UNIX find command

Dramatically increases the speed of fuzzy finding directories, `nav` will use the standard `find` if `bfs` is not available

<table>
<tbody>
<tr><th>Linux</th><th>Mac</th></tr>
<tr><td><pre>apt install bfs</pre></td><td><pre>brew install bfs</pre></td></tr>
</tbody>
</table>

#### [exa](https://github.com/ogham/exa) `optional`

> A modern replacement for ‘ls’.

Improves the preview of folders, `nav` will use `ls` if `exa` is not available

<table>
<tbody>
<tr><th>Linux</th><th>Mac</th></tr>
<tr><td><pre>apt install exa</pre></td><td><pre>brew install exa</pre></td></tr>
</tbody>
</table>


### Install nav

Just clone this repository:

```sh
cd ~
git clone https://github.com/betafcc/nav
```

Add the following to your `.zshrc` file:

```sh
source "${HOME}/nav/nav.zsh"
nav bindkeys
```

Note the last line `nav bindkeys`, that will set the default keyboard shortcuts for nav, if you prefer to bind custom ones, delete that line and see [config section](#config).

Config
------

### Custom keybindings

The command `nav bindkeys` will set the following keybindings:

```sh
bindkey '^[[1;9A' nav-up      # alt + up
bindkey '^[[1;9B' nav-down    # alt + down
bindkey '^[[1;9C' nav-forward # alt + right
bindkey '^[[1;9D' nav-back    # alt + left
```

If you wish to set custom ones just delete `nav bindkeys` from your `.zshrc` file and copy the above with the desired changes.

#### Hint: Using `⌘ Command` instead of `⌥ Option` on Mac

To set the the command key as the leading key, unfortunately there is no automated way to do it as it depends on your terminal emulator translating that key to be interpreted by zsh.

On my setup I've set the unused sequence of `^[[1;5` to represent the command key. If you are using iterm2, you can go to

Settings -> Profiles -> Keys -> Key Mappings

Then add new items with action "Send Escape Sequence".
In the end you should have the following on the list:

```
Send ^[ [1;5A    ⌘↑
Send ^[ [1;5B    ⌘↓
Send ^[ [1;5C    ⌘→
Send ^[ [1;5D    ⌘←
```

Note you should ignore the `^[ ` prefix when copying the code from above, as it's implied by the `Esc` label.


After that, delete `nav bindkeys` from your `.zshrc` file and add the following:

```sh
bindkey '^[[1;5A' nav-up      # cmd + up
bindkey '^[[1;5B' nav-down    # cmd + down
bindkey '^[[1;5C' nav-forward # cmd + right
bindkey '^[[1;5D' nav-back    # cmd + left
```


### `NAV_FIND_COMMAND` environment variable

`nav` will use this command to list directories to be fuzzy matched when you `alt` + `↓`.

You can change based on what is used by default:


```sh
# If `bfs` is available:
NAV_FIND_COMMAND="bfs -x -type d -exclude -name '.git' -exclude -name 'node_modules' 2>/dev/null"

# otherwise:
NAV_FIND_COMMAND="find . -type d \( ! -name '.git' -a ! -name 'node_modules' \) 2>/dev/null"
```

### `NAV_PREVIEW_COMMAND` environment variable

`nav` will use this command to preview directories contents when you `alt` + `↓`.

You can change based on what is used by default:

```sh
# If `exa` is available:
NAV_PREVIEW_COMMAND="exa --color=always --group-directories-first --all --icons --oneline {}"

# otherwise:
NAV_PREVIEW_COMMAND="ls -1A {}"
```
