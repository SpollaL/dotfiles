return {
	"fasterius/simple-zoom.nvim",
	opts = {
		hide_tabline = true,
	},
	config = function()
    require("simple-zoom").setup()
		vim.keymap.set("n", "<Leader>z", ":SimpleZoomToggle<CR>", { desc = "Zoom Toggle" })
	end,
}
