return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
		  "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
      "folke/which-key.nvim",
		},
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    require("mason-nvim-dap").setup({
      ensure_installed = { "python", "delve" }
    })
    require("dapui").setup()
    require("dap-go").setup()
    dap.configurations.go = {
      {
        type = "go",
        name = "Debug Interactive CLI (scanner)",
        request = "launch",
        program = "${workspaceFolder}",
        console = "externalTerminal",
      },
    }
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
    vim.keymap.set("n", "<Leader>dc", function()
      dap.continue()
    end, { desc = "DAP: Continue" })
    vim.keymap.set("n", "<Leader>do", function()
      dap.step_over()
    end, { desc = "DAP: Step Over" })
    vim.keymap.set("n", "<Leader>di", function()
      dap.step_into()
    end, { desc = "DAP: Step Into" })
    vim.keymap.set("n", "<Leader>dO", function()
      dap.step_out()
    end, { desc = "DAP: Step Out" })
    vim.keymap.set("n", "<Leader>dt", function()
      dap.toggle_breakpoint()
    end, { desc = "DAP: Toggle Breakpoint" })
    vim.keymap.set("n", "<Leader>ds", function()
      dap.terminate()
    end, { desc = "DAP: Stop Debugger" })
    local wk = require("which-key")
    wk.add({
      { "<leader>d", group = "Debugger" }, -- group
    })
  end,
	}
}
