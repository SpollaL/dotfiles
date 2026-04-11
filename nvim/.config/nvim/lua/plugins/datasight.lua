return {
  "SpollaL/datasight.nvim",
  keys = {
    { "<leader>da", desc = "Open datasight for current file" },
    { "<leader>dv", desc = "Visualize DataFrame under cursor" },
  },
  cmd = { "Datasight", "DatasightVar" },
  config = function()
    require("datasight").setup({
      keymaps = {
        open = "<leader>da",
        visualize = "<leader>dv",
      },
    })
  end,
}
