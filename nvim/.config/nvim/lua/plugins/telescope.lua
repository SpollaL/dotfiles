return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/which-key.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "kiyoon/telescope-insert-path.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local wk = require("which-key")
      local path_actions = require("telescope_insert_path")

      telescope.setup({
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({}),
        },
        defaults = {
          mappings = {
            n = {
              ["["] = path_actions.insert_reltobufpath_visual,
              ["]"] = path_actions.insert_abspath_visual,
              ["{"] = path_actions.insert_reltobufpath_insert,
              ["}"] = path_actions.insert_abspath_insert,
              ["-"] = path_actions.insert_reltobufpath_normal,
              ["="] = path_actions.insert_abspath_normal,
            },
          },
        },
      })

      telescope.load_extension("ui-select")

      -- Keymaps
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

      -- Which-key group
      wk.add({
        ["<leader>f"] = { name = "+telescope" },
      })
    end,
  },
}
