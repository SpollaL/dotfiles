return {
  "SpollaL/datasight.nvim",
  keys = {
    { "<leader>da", desc = "Open datasight for current file" },
  },
  config = function()
    require("datasight").setup({
      keymaps = { open = "<leader>da" },
    })
  end,
}
