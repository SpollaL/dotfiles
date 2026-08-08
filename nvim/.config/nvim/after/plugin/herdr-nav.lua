-- Editor half of vim-herdr-navigation (paulbkim-dev/vim-herdr-navigation v0.1.0),
-- vendored so this config stays portable: it does not depend on herdr's plugin
-- checkout path, and degrades to plain wincmd where herdr is not installed.
--
-- <C-h/j/k/l> moves between Neovim splits; at a split edge it hands off to the
-- surrounding multiplexer so focus crosses into the neighbouring pane. herdr
-- first, tmux second, otherwise the wincmd above is all that happens.
--
-- Lives in after/plugin so it loads last and wins over vim-tmux-navigator.
-- The herdr half is the ctrl+h/j/k/l plugin_action bindings in
-- herdr/.config/herdr/config.toml.

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return -- moved within Neovim
  end
  -- At a split edge: cross into the surrounding multiplexer.
  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    -- Target this pane explicitly: --current resolves to the server's globally
    -- focused pane, which is not necessarily the one we are in.
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then
      herdr = "herdr"
    end
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID })
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
  end
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set("n", lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
