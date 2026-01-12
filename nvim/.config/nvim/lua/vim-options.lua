vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set splitright")
vim.cmd("set clipboard+=unnamedplus")
vim.opt.swapfile = false
vim.wo.number = true

vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")

-- Exit terminal mode with Escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.diagnostic.config({
	float = { source = true },
})

vim.g.mapleader = " "

-- -- NOTE: Ensures that when exiting NeoVim, Zellij returns to normal mode
-- vim.api.nvim_create_autocmd("VimLeave", {
--     pattern = "*",
--     command = "silent !zellij action switch-mode normal"
-- })

vim.keymap.set("n", "<leader>vo",
  function()
    local file = vim.fn.expand("%:p")
    vim.fn.jobstart({ "code", file }, { detach = true })
  end,
  { desc = "Open current file in VS Code" }
)

-- Open CSV in VisiData in floating window
vim.keymap.set("n", "<leader>vd", function()
  local filepath = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t")

  -- Check if file exists
  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("File does not exist or is not readable", vim.log.levels.ERROR)
    return
  end

  local supported_formats = { "csv", "tsv", "json", "xlsx" }
  local ext = filepath:match("%.([^.]+)$")

  if not vim.tbl_contains(supported_formats, ext) then
    vim.notify("File format not supported. Use csv, tsv, json, or xlsx", vim.log.levels.WARN)
    return
  end

  -- Create floating window
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = filename,
    title_pos = "center",
  })

  -- Open VisiData in terminal
  vim.fn.termopen({ "visidata", filepath }, {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })

  vim.cmd.startinsert()

  -- Exit keymaps
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:q<CR>", opts)
  vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:q<CR>", opts)
end, { noremap = true, silent = true, desc = "Open CSV in VisiData" })
