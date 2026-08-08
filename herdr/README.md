# herdr

[herdr](https://herdr.dev) is a terminal workspace manager for AI coding agents.
This package is a port of the `tmux` package, kept alongside it so both can be
stowed while herdr is on trial.

```bash
mv ~/.config/herdr/config.toml ~/.config/herdr/config.toml.bak  # if one exists
cd ~/dotfiles && stow herdr
```

herdr writes its sockets and logs into `~/.config/herdr/`, so stow folds the
package into that existing directory rather than replacing it.

Deploys `~/.config/herdr/config.toml` and `~/.local/bin/herdr-sessionizer`.
Validate the config with `herdr config check`; apply it to a running server with
`herdr server reload-config`.

## Sessionizer

`prefix+f` fuzzy-picks a project directory and focuses its workspace, or creates
one. New workspaces get nvim in the root pane at 65% and a shell in the smaller
split to its right. A `.venv` or `venv` in the project is activated before nvim
starts, so the LSP resolves the project interpreter and the shell nvim exits back
to stays activated. Existing workspaces are only focused, never relaid out.

The directories offered are read from `~/.config/sessionizer/roots`, one absolute
path per line, defaulting to `~/workspace` and `~/dotfiles`. A project that wants
a multi-tab layout instead of the default supplies an executable
`~/.config/herdr/layouts/<dir-name>.sh`, which receives the new workspace id as
`$1`. Both paths are machine-local and deliberately outside this repo, so private
project names and layouts never land in version control.

Workspaces are matched by label, not id — herdr recycles workspace ids as
workspaces close.

## Shell integration

herdr runs one shell per pane, so anything `~/.bashrc` auto-starts ends up
running *inside* herdr. The old tmux auto-attach did exactly that and produced
tmux-inside-herdr (`HERDR_PANE_ID` and `TMUX` both set, `TERM_PROGRAM=tmux`).

`~/.bashrc` now attaches herdr instead, guarded so it never nests:

```bash
# Auto-attach to herdr on terminal open.
# HERDR_PANE_ID skips this inside a herdr pane (herdr does not nest);
# TMUX skips it inside a tmux pane, if tmux is ever started by hand.
if command -v herdr &>/dev/null \
   && [ -z "$HERDR_PANE_ID" ] && [ -z "$TMUX" ]; then
  herdr
fi
```

Deliberately not `exec herdr` — detaching (`Ctrl-s d`) then drops back to a
shell instead of closing the terminal window, and a herdr that fails to start
leaves a usable shell rather than a window that dies on open.

This lives in the live `~/.bashrc` only — the `bash` package in this repo is not
stowed and still carries the old tmux auto-attach.

## Quitting

herdr's "session" is the persistent server (`default`), not the tmux-session
equivalent — that is a workspace.

| Intent                          | How                                        |
| ------------------------------- | ------------------------------------------ |
| Detach, leave everything running | `Ctrl-s d` (tmux `prefix d`; herdr's own default is `prefix+q`) |
| Close one workspace             | `Ctrl-s D`, or `herdr workspace close <id>` |
| Stop everything                 | `herdr server stop` (tmux `kill-server`)   |

## Concept map

| tmux    | herdr     |
| ------- | --------- |
| session | workspace |
| window  | tab       |
| pane    | pane      |

## Keybindings

Prefix is `C-s` in both.

| tmux                        | herdr                | Notes                                                       |
| --------------------------- | -------------------- | ----------------------------------------------------------- |
| `prefix r` reload           | `prefix r`           | Takes `prefix r` from `resize_mode`, which moves to `prefix R` |
| `prefix h/j/k/l`            | `prefix h/j/k/l`     | Same bindings, herdr defaults                                |
| `prefix T` session popup    | `prefix T`           | Native `workspace_picker` replaces the fzf popup             |
| `prefix f` tmux-sessionizer | `prefix f`           | Popup running `herdr-sessionizer`                            |
| `prefix d` detach           | `prefix d`           | herdr defaults to `prefix q`                                 |
| `prefix ,` rename window    | `prefix ,`           | herdr defaults to `prefix T`, which `workspace_picker` took  |
| `prefix c/n/p/1..9`         | same                 | herdr defaults already match                                 |
| `prefix x` / `prefix z`     | same                 | herdr defaults already match                                 |
| `prefix &` kill window      | `prefix X`           | tmux's `&` is shifted punctuation; herdr's default is safer  |
| `prefix %` / `prefix "`     | `prefix v` / `prefix -` | Same reason                                                  |
| `prefix [` copy mode        | `prefix [`           | `copy_mode`, undocumented in `--default-config` but valid    |

## Settings

| tmux                                    | herdr                                            |
| --------------------------------------- | ------------------------------------------------ |
| catppuccin macchiato                    | `theme.name = "catppuccin"` + macchiato `[theme.custom]` |
| `set -g set-clipboard on`               | `ui.copy_on_select`                              |
| `setw -g pane-border-lines single`      | `ui.pane_borders`                                |
| `set -wg automatic-rename on`           | `ui.prompt_new_tab_name = false`                 |
| `set -gq allow-passthrough on`          | `experimental.kitty_graphics` (for image.nvim)   |
| tmux-resurrect / tmux-continuum         | `session.resume_agents_on_restore`, `experimental.pane_history` |
| tmux-which-key                          | `keys.help` (`prefix ?`), built in               |
| status-left (session / command / path)  | `[ui.sidebar.spaces]` and `[ui.sidebar.agents]` rows |

herdr's built-in catppuccin is the mocha flavour, so `[theme.custom]` layers the
macchiato palette on top. Only the tokens herdr exposes are overridable —
`herdr config check` reports any that are not.

## Plugins

`herdr plugin` is a real subcommand even though `herdr --help` does not list it.
Plugins install from GitHub; the marketplace at <https://herdr.dev/plugins> is
populated automatically from the `herdr-plugin` topic.

```bash
herdr plugin install paulbkim-dev/vim-herdr-navigation
```

Replaces **vim-tmux-navigator**: prefix-less `ctrl+h/j/k/l` crosses nvim splits
and herdr panes as one surface. Two halves that have to agree —

- herdr side: the four `type = "plugin_action"` bindings in `config.toml`. The
  plugin checks the focused pane's foreground process and either forwards the
  chord into the pane (nvim) or moves herdr's focus (anything else).
- editor side: `nvim/.config/nvim/after/plugin/herdr-nav.lua`, vendored from the
  plugin rather than `dofile`'d out of herdr's checkout so the nvim package stays
  portable and degrades to plain `wincmd` where herdr is absent. `after/plugin`
  loads late enough to beat vim-tmux-navigator, whose own `<c-hjkl>` maps are
  removed from its lazy spec; its `TmuxNavigate*` commands stay as the `$TMUX`
  fallback.

Install unpinned. The `v0.1.0` tag detects and focuses with `herdr pane
process-info --current` / `pane focus --current`, which resolve to the server's
globally focused pane instead of the pane the key fired from — so it moves the
wrong pane. Fixed after the tag. `.plugins.lock` records the resolved commit, so
an unpinned install is still reproducible.

Trade-off inherited from tmux: `ctrl+l` and `ctrl+k` no longer reach readline
(clear screen, kill line) in non-nvim panes.

## Gaps

Things the tmux config did that herdr has no equivalent for:

- **tmux-battery / tmux-online-status / clock.** The sidebar has no status-bar
  segments for battery, connectivity, or the date.

Note that `herdr --default-config` does not list every bindable action —
`copy_mode` and `swap_pane_*` are real but undocumented. `herdr config check`
is the authority: it reports `unknown config key` for anything that is not.

Intentional divergences from tmux:

- **Mouse is on.** tmux ran with the default `mouse off`; herdr's UI is built
  around `ui.mouse_capture = true`, so it is left enabled.
- **New panes follow the source pane's cwd** (`terminal.new_cwd = "follow"`),
  where tmux used the session's start directory.
