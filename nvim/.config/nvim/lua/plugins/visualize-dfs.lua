return {
	"nelnn/bear.nvim",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("bear").setup()
	end,
}
