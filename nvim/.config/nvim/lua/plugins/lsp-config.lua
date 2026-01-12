return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls", "postgres_lsp", "ruff", "pyright" , "dockerls", "gopls"},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
					vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Show hover documentation" })
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
					vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, { desc = "Show signature help" })
					vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "List references" })
				end,
			})
		end,
	},
}
