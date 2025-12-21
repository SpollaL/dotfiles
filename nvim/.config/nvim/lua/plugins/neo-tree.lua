return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		lazy = false, -- neo-tree will lazily load itself
		config = function()
			vim.keymap.set("n", "<leader>e", function()
				local neo_tree_buf = vim.bo.filetype == "neo-tree"
				if neo_tree_buf then
					vim.cmd("Neotree toggle")
				else
					vim.cmd("Neotree filesystem reveal left")
				end
			end, { desc = "Toggle Neo-tree or reveal filesystem" })
		end,
	},
}
