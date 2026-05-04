return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    local plugin = require("claude-code")
    plugin.setup({ window = { position = "vertical" } })

    -- Workaround: claude-code.nvim's TermClose handler calls nvim_buf_get_name on the
    -- closing buffer before checking validity. When snacks terminal closes, it deletes
    -- the buffer first, so the handler crashes with "Invalid buffer id".
    vim.api.nvim_clear_autocmds({ group = "ClaudeCodeFileRefresh", event = "TermClose" })
    vim.api.nvim_create_autocmd("TermClose", {
      group = "ClaudeCodeFileRefresh",
      pattern = "*",
      desc = "Restore updatetime and clean up when Claude Code closes",
      callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        local buf_name = vim.api.nvim_buf_get_name(args.buf)
        if not buf_name:match("claude%-code") then return end
        vim.o.updatetime = plugin.claude_code.saved_updatetime
        for instance_id, bufnr in pairs(plugin.claude_code.instances) do
          if bufnr == args.buf then
            plugin.claude_code.instances[instance_id] = nil
            break
          end
        end
        vim.schedule(function()
          for _, win_id in ipairs(vim.fn.win_findbuf(args.buf)) do
            pcall(vim.api.nvim_win_close, win_id, true)
          end
          pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
        end)
      end,
    })

    vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })
  end
}
