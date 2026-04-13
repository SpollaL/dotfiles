return {
  -- Image rendering backend (required by molten for plot output)
  {
    "3rd/image.nvim",
    version = "1.1.0",
    lazy = false, -- must be set up before molten tries to render images
    config = function()
      -- image.nvim checks TERM/TERM_PROGRAM for "kitty" to enable itself.
      -- Inside tmux those are overwritten, so spoof TERM_PROGRAM when we
      -- know the outer terminal is Kitty (TERMINAL=kitty or KITTY_WINDOW_ID set).
      local in_kitty = (os.getenv("KITTY_WINDOW_ID") ~= nil and os.getenv("KITTY_WINDOW_ID") ~= "")
        or os.getenv("TERM_PROGRAM") == "kitty"
        or os.getenv("TERMINAL") == "kitty"
      if in_kitty then
        vim.env.TERM_PROGRAM = "kitty"
      end

      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = { enabled = false },
          typst = { enabled = false },
          html = { enabled = false },
          css = { enabled = false },
        },
        -- Must be set to avoid terminal crashes on large images
        max_width = 100,
        max_height = 12,
        max_width_window_percentage = math.huge,
        max_height_window_percentage = math.huge,
        kitty_method = "normal",
        -- Hide images when the tmux window loses focus to prevent bleed into other panes
        tmux_show_only_in_active_window = true,
      })
    end,
  },

  -- Jupyter kernel execution with inline outputs
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      -- Use image.nvim when running inside Kitty (works in tmux too via passthrough)
      local in_kitty = (os.getenv("KITTY_WINDOW_ID") ~= nil and os.getenv("KITTY_WINDOW_ID") ~= "")
        or os.getenv("TERM_PROGRAM") == "kitty"
        or os.getenv("TERMINAL") == "kitty"
      vim.g.molten_image_provider = in_kitty and "image.nvim" or "none"
      -- Output display
      vim.g.molten_virt_text_output = true     -- show output as virtual text below cell
      vim.g.molten_output_virt_lines = true    -- use real line slots (pushes content down like Jupyter)
      vim.g.molten_virt_text_max_lines = 20
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_show_more = true
      vim.g.molten_output_show_exec_time = true
      -- Output float window (opened with <leader>jo)
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.molten_output_crop_border = true
    end,
    config = function()
      -- Auto-import outputs from .ipynb when molten initialises on a notebook buffer
      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          pcall(vim.cmd, "MoltenImportOutput")
        end,
      })

      -- Auto-export outputs back to .ipynb on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.py",
        callback = function()
          if #vim.fn.MoltenRunningKernels(true) > 0 then
            pcall(vim.cmd, "MoltenExportOutput!")
          end
        end,
      })

      -- Highlight groups (Catppuccin Mocha palette)
      vim.api.nvim_set_hl(0, "MoltenCell",                { bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "MoltenOutputWin",           { bg = "#181825" })
      vim.api.nvim_set_hl(0, "MoltenOutputWinNC",         { bg = "#181825" })
      vim.api.nvim_set_hl(0, "MoltenOutputBorder",        { fg = "#45475a", bg = "#181825" })
      vim.api.nvim_set_hl(0, "MoltenOutputBorderSuccess", { fg = "#a6e3a1", bg = "#181825", bold = true })
      vim.api.nvim_set_hl(0, "MoltenOutputBorderFail",    { fg = "#f38ba8", bg = "#181825", bold = true })
      vim.api.nvim_set_hl(0, "MoltenOutputFooter",        { fg = "#585b70", bg = "#181825", italic = true })
      vim.api.nvim_set_hl(0, "MoltenVirtualText",         { fg = "#a6adc8", italic = true })

      -- Parse all # %% cells in the buffer, returns list of {start, end} (1-indexed)
      local function get_cells(bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local n = #lines
        local cells = {}
        local cell_start = nil

        for i = 1, n do
          if lines[i]:match("^# %%%%") then
            if cell_start then
              local cell_end = i - 1
              while cell_end > cell_start and lines[cell_end]:match("^%s*$") do
                cell_end = cell_end - 1
              end
              if cell_start <= cell_end then
                table.insert(cells, { cell_start, cell_end })
              end
            end
            cell_start = i + 1
          end
        end

        if cell_start then
          local cell_end = n
          while cell_end >= cell_start and lines[cell_end]:match("^%s*$") do
            cell_end = cell_end - 1
          end
          if cell_start <= cell_end then
            table.insert(cells, { cell_start, cell_end })
          end
        end

        return cells, lines
      end

      local function eval_range(bufnr, lines, s, e)
        -- Pass kernel name directly to avoid async kernel_check dispatch,
        -- which causes marks to be overwritten before they are read.
        local kernels = vim.fn.MoltenRunningKernels(true)
        if #kernels == 0 then
          vim.notify("[molten] No kernel running", vim.log.levels.WARN)
          return
        end
        vim.api.nvim_buf_set_mark(bufnr, "<", s, 0, {})
        vim.api.nvim_buf_set_mark(bufnr, ">", e, #lines[e] - 1, {})
        vim.cmd("MoltenEvaluateVisual " .. kernels[1])
      end

      local function run_cell()
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
        local cells, lines = get_cells(bufnr)
        for _, cell in ipairs(cells) do
          if cursor_row >= cell[1] and cursor_row <= cell[2] then
            eval_range(bufnr, lines, cell[1], cell[2])
            return
          end
        end
        vim.notify("[molten] Not in a cell", vim.log.levels.WARN)
      end

      -- Run all cells strictly above the current cell
      local function run_cells_above()
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
        local cells, lines = get_cells(bufnr)
        local ran = 0
        for _, cell in ipairs(cells) do
          if cell[2] >= cursor_row then break end
          eval_range(bufnr, lines, cell[1], cell[2])
          ran = ran + 1
        end
        if ran == 0 then vim.notify("[molten] No cells above", vim.log.levels.WARN) end
      end

      -- Run the current cell and all cells below it
      local function run_cells_below()
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
        local cells, lines = get_cells(bufnr)
        local ran = 0
        for _, cell in ipairs(cells) do
          if cell[2] >= cursor_row then
            eval_range(bufnr, lines, cell[1], cell[2])
            ran = ran + 1
          end
        end
        if ran == 0 then vim.notify("[molten] No cells at or below cursor", vim.log.levels.WARN) end
      end

      local wk = require("which-key")
      wk.add({ { "<leader>j", group = "Jupyter" } })

      vim.keymap.set("n", "<leader>ji", ":MoltenInit<CR>",
        { desc = "Init kernel", silent = true })
      vim.keymap.set("n", "<leader>jb", run_cell,
        { desc = "Execute cell", silent = true })
      vim.keymap.set("n", "<leader>ja", run_cells_above,
        { desc = "Execute all cells above", silent = true })
      vim.keymap.set("n", "<leader>jB", run_cells_below,
        { desc = "Execute cell and all below", silent = true })
      vim.keymap.set("n", "<leader>jl", ":MoltenEvaluateLine<CR>",
        { desc = "Execute line", silent = true })
      vim.keymap.set("n", "<leader>je", ":MoltenEvaluateOperator<CR>",
        { desc = "Execute operator", silent = true })
      vim.keymap.set("v", "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv",
        { desc = "Execute selection", silent = true })
      vim.keymap.set("n", "<leader>jo", ":MoltenShowOutput<CR>",
        { desc = "Show output", silent = true })
      vim.keymap.set("n", "<leader>jO", ":MoltenHideOutput<CR>",
        { desc = "Hide output", silent = true })
      vim.keymap.set("n", "<leader>jd", ":MoltenDelete<CR>",
        { desc = "Delete cell output", silent = true })
      vim.keymap.set("n", "<leader>jr", ":MoltenReevaluateCell<CR>",
        { desc = "Re-run cell (already defined)", silent = true })
      vim.keymap.set("n", "<leader>jR", ":MoltenRestart!<CR>",
        { desc = "Restart kernel", silent = true })
      vim.keymap.set("n", "<leader>jk", ":MoltenInterrupt<CR>",
        { desc = "Interrupt kernel", silent = true })

      vim.keymap.set("n", "<leader>jK", function()
        local cwd = vim.fn.getcwd()
        local kernel_name = vim.fn.fnamemodify(cwd, ":t")

        -- Find venv: prefer .venv, fall back to venv
        local python
        for _, name in ipairs({ ".venv", "venv" }) do
          local candidate = cwd .. "/" .. name .. "/bin/python"
          if vim.fn.executable(candidate) == 1 then
            python = candidate
            break
          end
        end

        if not python then
          vim.notify("No venv found in project root (.venv or venv)", vim.log.levels.WARN)
          return
        end

        -- Check ipykernel is available
        vim.fn.jobstart({ python, "-c", "import ipykernel" }, {
          on_exit = function(_, code)
            if code ~= 0 then
              vim.notify(
                "ipykernel not installed. Run: uv pip install ipykernel",
                vim.log.levels.WARN
              )
              return
            end

            -- Register the kernel
            vim.fn.jobstart({
              python, "-m", "ipykernel", "install",
              "--user",
              "--name", kernel_name,
              "--display-name", kernel_name,
            }, {
              on_exit = function(_, exit_code)
                if exit_code == 0 then
                  vim.notify("Kernel '" .. kernel_name .. "' registered. Use <leader>ji to init.", vim.log.levels.INFO)
                else
                  vim.notify("Failed to register kernel '" .. kernel_name .. "'", vim.log.levels.ERROR)
                end
              end,
            })
          end,
        })
      end, { desc = "Register project venv as Jupyter kernel" })
    end,
  },

  -- .ipynb <-> percent-format Python (# %%) transparent conversion
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "percent",
      output_extension = "auto",
      force_ft = "python",
    },
  },

  -- Cell navigation, run-and-move, and text objects (dah/yih/vah)
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      "echasnovski/mini.hipatterns",
      "echasnovski/mini.ai",
    },
    event = "VeryLazy",
    config = function()
      local nn = require("notebook-navigator")
      nn.setup({
        repl_provider = "molten",
        syntax_highlight = false, -- handled by mini.hipatterns below
        cell_markers = { python = "# %%" },
      })

      -- Cell separator decoration: dim horizontal rule above each # %%
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          notebook_cell = nn.minihipatterns_spec,
        },
      })

      -- Text objects: `ih` = inner cell code, `ah` = whole cell with marker
      require("mini.ai").setup({
        custom_textobjects = {
          h = nn.miniai_spec,
        },
      })

      -- Cell navigation
      vim.keymap.set("n", "]j", function() nn.move_cell("d") end,
        { desc = "Next cell", silent = true })
      vim.keymap.set("n", "[j", function() nn.move_cell("u") end,
        { desc = "Prev cell", silent = true })

      -- Run cell and jump to the next one (Shift+Enter feel)
      vim.keymap.set("n", "<leader>jx", function() nn.run_and_move() end,
        { desc = "Execute cell and move to next", silent = true })
    end,
  },
}
