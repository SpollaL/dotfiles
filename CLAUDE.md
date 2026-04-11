# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Type

Personal dotfiles configuration repository for Linux development tools. Uses GNU stow for symlink-based deployment.

## Commands

### Deploy configurations
```bash
cd ~/dotfiles
stow <tool>  # e.g., stow nvim, stow bash, stow i3
```

### Setup (install dependencies)
```bash
./setup.sh all      # Install everything
./setup.sh nvim     # Install Neovim and deps
./setup.sh i3       # Install i3 and related tools
```

### Linting
```bash
lua-language-server --check ./nvim/.config/nvim/lua/   # Lua
stylua nvim/.config/nvim/lua/                          # Lua formatting
shellcheck bash/.bashrc bash/.profile                  # Bash
```

## Architecture

### Directory Structure
Each top-level directory is a stow package that mirrors the user's home directory:
- `nvim/.config/nvim/` → `~/.config/nvim`
- `bash/.bashrc` → `~/.bashrc`
- `tmux/.tmux.conf` → `~/.tmux.conf`

### Neovim Configuration
- **Entry point**: `nvim/.config/nvim/init.lua` loads `vim-options.lua` and `config/lazy.lua`
- **Plugin manager**: Lazy.nvim (plugins defined in `lua/plugins/` as individual files)
- **Plugin pattern**: Each file returns a table of plugin specs

### Theming
Catppuccin Mocha theme is used consistently across Neovim, polybar, rofi, and tmux.

## Code Style

See `AGENTS.md` for detailed style guidelines. Key points:
- **Lua**: 2 spaces, snake_case, `desc` field in keymaps
- **Bash**: 2 spaces, quote variables, use `[[ ]]` for conditions
