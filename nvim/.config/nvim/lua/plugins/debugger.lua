return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
      "folke/which-key.nvim",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "delve", "codelldb" }
      })
      require("dapui").setup()
      require("dap-go").setup()
      require("dap-python").setup("uv")
      require('dap-python').test_runner = "pytest"
      -- Rust
      local rust_dap = require("rust_dap")

      local mason_path = vim.fn.stdpath("data") .. "/mason"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason_path .. "/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Rust: Debug binary",
          type = "codelldb",
          request = "launch",
          program = rust_dap.debug_bin,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Rust: Debug example",
          type = "codelldb",
          request = "launch",
          program = rust_dap.debug_example,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Rust: Debug tests",
          type = "codelldb",
          request = "launch",
          program = rust_dap.debug_tests,
          cwd = "${workspaceFolder}",
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          vim.keymap.set(
            "n",
            "<Leader>dt",
            function()
              require("rust_test_debug").debug_current_test()
            end,
            { buffer = true, desc = "Debug Rust test under cursor" }
          )
        end,
      })

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
      vim.keymap.set("n", "<Leader>dt", function()
        require("dap-python").test_method()
      end, { desc = "DAP: Debug Closest Test" })
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
      vim.keymap.set("n", "<Leader>db", function()
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
