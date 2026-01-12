return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup()
    -- Keep gitsigns preview, but also have snacks picker for git diff
    vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "GitSigns Preview Hunk" })
  end
}
