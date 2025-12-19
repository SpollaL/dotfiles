return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
      {"folke/which-key.nvim"  },
		},
		build = "make tiktoken",
		opts = {},
		config = function()
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
