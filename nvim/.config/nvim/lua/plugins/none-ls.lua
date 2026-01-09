
return {
	"nvimtools/none-ls.nvim",
	config = function()
    local null_ls = require("null-ls")
    local methods = require("null-ls.methods")
    local helpers = require("null-ls.helpers")
    local function ruff_fix()
      return helpers.make_builtin({
        name = "ruff",
        meta = {
          url = "https://github.com/charliermarsh/ruff/",
          description = "An extremely fast Python linter, written in Rust.",
        },
        method = methods.internal.FORMATTING,
        filetypes = { "python" },
        generator_opts = {
          command = "uv",
          args = {"run", "ruff", "--fix", "-e", "-n", "--stdin-filename", "$FILENAME", "-" },
          to_stdin = true,
        },
        factory = helpers.formatter_factory,
      })
    end
      null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.mypy.with({
					command = "uv",
					args = { "run", "--env-file", ".env", "mypy", "$FILENAME" },
				}),
        ruff_fix(),
				null_ls.builtins.code_actions.refactoring,
				null_ls.builtins.formatting.gofumpt,
				null_ls.builtins.formatting.goimports,
				null_ls.builtins.formatting.golines,
        null_ls.builtins.formatting.dockerfile_format,
        null_ls.builtins.diagnostics.hadoolint,
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format buffer" })
	end
}
