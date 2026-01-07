return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			{ "folke/which-key.nvim" },
		},
		build = "make tiktoken",
		opts = {
			model = "claude-haiku-4.5", -- AI model to use
			temperature = 0.1, -- Lower = focused, higher = creative
			window = {
				layout = "vertical", -- 'vertical', 'horizontal', 'float'
				width = 0.4, -- 40% of screen width
			},
			prompts = {
				PRMessage = {
					prompt = "Run git commands to spot the differences between the current branch and the main and summarized the changes. \nCreate a PR message to merge the current branch into the main branch.",
				},
			},
		},
		config = function(_, opts)
      require("CopilotChat").setup(opts)
			vim.keymap.set("n", "<leader>cc", ":CopilotChatOpen<CR>", { desc = "Open copilot chat" })
			vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", { desc = "Review selection" })
			vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain selection" })
			vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix selection" })
			vim.keymap.set("v", "<leader>co", ":CopilotChatOptimize<CR>", { desc = "Optimize selection" })
			vim.keymap.set("v", "<leader>cd", ":CopilotChatDocs<CR>", { desc = "Generate docs" })
			vim.keymap.set("v", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests" })
			vim.keymap.set("n", "<leader>cm", ":CopilotChatCommit<CR>", { desc = "Generate commit message" })
			local wk = require("which-key")
			wk.add({
				{ "<leader>c", group = "Copilot" }, -- group
			})
		end,
	},
}
