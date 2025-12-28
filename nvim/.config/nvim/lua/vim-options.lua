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
