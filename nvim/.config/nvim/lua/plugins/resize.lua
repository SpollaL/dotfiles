return {
  '0xm4n/resize.nvim',
  config = function()
    require('resize').setup()
    vim.keymap.set("n", "<C-Left>", "<cmd>lua require('resize').ResizeLeft()<CR>", { silent = true })
    vim.keymap.set("n", "<C-Right>", "<cmd>lua require('resize').ResizeRight()<CR>", { silent = true })
    vim.keymap.set("n", "<C-Up>", "<cmd>lua require('resize').ResizeUp()<CR>", { silent = true })
    vim.keymap.set("n", "<C-Down>", "<cmd>lua require('resize').ResizeDown()<CR>", { silent = true })
  end,
}
