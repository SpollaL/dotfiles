return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
			provider = {
				enabled = "snacks",
			},
		}
		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Unified leader-based interface
		vim.keymap.set({ "n", "x" }, "<leader>oa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask OpenCode" })
		vim.keymap.set({ "n", "x" }, "<leader>oc", function()
			require("opencode").select()
		end, { desc = "OpenCode actions" })
		vim.keymap.set({ "n", "t" }, "<leader>ot", function()
			require("opencode").toggle()
		end, { desc = "Toggle OpenCode" })

		-- Context-aware operators with clearer intent
		vim.keymap.set({ "n", "x" }, "<leader>or", function()
			return require("opencode").operator("@this ")
		end, { expr = true, desc = "Add selection/range to OpenCode" })
		vim.keymap.set("n", "<leader>ol", function()
			return require("opencode").operator("@this ") .. "_"
		end, { expr = true, desc = "Add line to OpenCode" })

		-- Safer scroll keymaps (avoid terminal conflicts)
		vim.keymap.set("n", "<leader>ou", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "OpenCode scroll up" })
		vim.keymap.set("n", "<leader>od", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "OpenCode scroll down" })

		-- Which-key group name
		if require("which-key").is_available ~= false then
			require("which-key").add({
				{ "<leader>o", group = "OpenCode" },
			})
		end

		-- Optional: only remap if you actively use these
		-- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
		-- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
	end,
}
