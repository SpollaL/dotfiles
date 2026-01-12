# AGENTS.md - Development Guide for Agentic Coding

This guide provides instructions for agentic coding agents (like OpenCode) operating within this dotfiles repository. This is primarily a configuration/dotfiles repository for Linux development tools.

## Repository Overview

- **Type**: Dotfiles configuration repository
- **Languages**: Lua (Neovim), Bash, YAML (configuration)
- **Main Components**: 
  - `nvim/`: Neovim editor configuration
  - `bash/`: Bash shell configuration
  - `i3/`: i3 window manager configuration
  - `polybar/`, `rofi/`, `tmux/`, `zellij/`: Other tool configurations

## Build, Lint & Test Commands

### Setup & Installation
```bash
# Deploy configuration using GNU stow
cd ~/dotfiles
stow nvim       # Install Neovim configuration
stow bash       # Install bash configuration
stow i3         # Install i3 window manager
stow polybar    # Install polybar
stow rofi       # Install rofi
stow tmux       # Install tmux configuration
stow zellij     # Install zellij configuration

# Full setup (see setup.sh for details)
./setup.sh all      # Install everything
./setup.sh nvim     # Install Neovim and deps
./setup.sh i3       # Install i3 and related tools
```

### Lua Linting
```bash
# Lint Lua files (requires lua_ls from Mason)
lua-language-server --check ./nvim/.config/nvim/lua/

# Format Lua files (use stylua if available)
stylua nvim/.config/nvim/lua/
```

### Shell Linting
```bash
# Lint bash files
shellcheck bash/.bashrc bash/.profile
```

## Code Style Guidelines

### Lua (Neovim Configuration)

**Formatting & Indentation**
- Use 2 spaces for indentation (set in vim-options.lua)
- No tabs; use spaces only
- Line length: aim for 80-120 characters

**Imports & Module Loading**
```lua
-- Use require() to load modules
require("vim-options")
require("config.lazy")

-- For plugin configurations, return a table
return {
  {
    "plugin/name",
    config = function()
      require("plugin-module").setup()
    end,
  },
}
```

**Naming Conventions**
- Local variables: `snake_case`
- Functions: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Module names: `snake_case` or `hyphenated-names`
- Plugin specs: Use tables with string keys

**Types & Comments**
- Add `desc` field to keymaps for documentation
- Use inline comments with `--` for explanations
- Use `-- NOTE:` for important context
- Comment out unused code with `-- ` prefix, don't delete

**Error Handling**
```lua
-- Use vim.notify() for user messages
vim.notify("Error message", vim.log.levels.ERROR)
vim.notify("Warning message", vim.log.levels.WARN)

-- Check file existence
if vim.fn.filereadable(filepath) == 0 then
  vim.notify("File does not exist", vim.log.levels.ERROR)
  return
end

-- Use pcall() for safe function calls
local ok, result = pcall(function()
  return require("module").dangerous_function()
end)
if not ok then
  vim.notify("Error: " .. result, vim.log.levels.ERROR)
end
```

### Bash/Shell

**Formatting & Indentation**
- Use 2 spaces for indentation
- Quote variables: `"$VAR"` not `$VAR`
- Use `[[ ]]` for conditions (bash-specific, safer than `[ ]`)

**Naming Conventions**
- Variables: `UPPER_CASE` for environment variables, `lowercase` for locals
- Functions: `function_name()` format
- File names: `lowercase-with-dashes` or `lowercase_underscores`

**Error Handling**
```bash
# Check command existence
if ! command -v nvim &>/dev/null; then
  echo "Error: nvim not found"
  exit 1
fi

# Use set -e for early exit on error (with care)
# Check exit codes explicitly
if [ $? -ne 0 ]; then
  echo "Error message"
  exit 1
fi
```

### YAML/JSON Configuration Files

- Use 2 spaces for indentation
- Keep keys consistent with their original format
- Document complex configuration sections with comments

## File Organization

```
dotfiles/
├── nvim/                       # Neovim config (primary coding tool)
│   └── .config/nvim/
│       ├── init.lua           # Main entry point
│       ├── lazy-lock.json     # Plugin lock file
│       └── lua/
│           ├── vim-options.lua
│           ├── config/        # Core configuration
│           └── plugins/       # Plugin specifications
├── bash/                       # Bash shell config
├── i3/                        # i3 window manager
├── polybar/                   # Status bar
├── rofi/                      # Application launcher
├── tmux/                      # Tmux multiplexer
├── zellij/                    # Zellij multiplexer
├── setup.sh                   # Installation script
└── AGENTS.md                  # This file
```

## Key Development Patterns

**Plugin Configuration Pattern**
```lua
return {
  {
    "plugin/namespace",
    config = function()
      require("plugin-module").setup()
    end,
    keys = {
      { "<leader>key", function() ... end, desc = "Description" },
    },
    dependencies = { "dependency/plugin" },
  },
}
```

**Keymap Pattern**
```lua
vim.keymap.set("n", "<leader>key", function()
  -- Implementation
end, { desc = "Human-readable description" })
```

**Autocmd Pattern**
```lua
vim.api.nvim_create_autocmd("EventName", {
  group = vim.api.nvim_create_augroup("GroupName", {}),
  callback = function(ev)
    -- Implementation
  end,
})
```

## Notes for Agents

- This is a **personal configuration repository**, not a library or application
- Changes should follow existing patterns in each file
- Always use `stow` to manage deployment; don't manually copy files
- Test configuration changes by sourcing files or restarting the editor
- Preserve comments and documentation about dependencies and alternatives
- Keep setup.sh updated if adding new package dependencies
