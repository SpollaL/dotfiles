-- Markdown viewing: render-markdown.nvim in the buffer, glow in a float (`:Glow`).
-- Colours are GitHub Primer, mapped onto the plugin's own highlight groups.

--- Primer functional tokens: { light, dark }.
local PRIMER = {
    accent    = { "#0969da", "#4493f7" },
    done      = { "#8250df", "#ab7df8" },
    sponsors  = { "#bf3989", "#db61a2" },
    success   = { "#1a7f37", "#3fb950" },
    attention = { "#9a6700", "#d29922" },
    danger    = { "#cf222e", "#f85149" },
    muted     = { "#59636e", "#9198a1" },
    border    = { "#d1d9e0", "#3d444d" },
    subtle    = { "#f6f8fa", "#151b23" },
}

--- Heading level 1-6 -> Primer token.
local HEADINGS = { "accent", "done", "sponsors", "success", "attention", "muted" }

local function pick(token)
    return PRIMER[token][vim.o.background == "dark" and 2 or 1]
end

--- Blend `hex` over the current `Normal` background at `alpha`, as a 24-bit int.
local function tint(hex, alpha)
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local bg = normal.bg or (vim.o.background == "dark" and 0x000000 or 0xffffff)
    local fg, out = tonumber(hex:sub(2), 16), 0
    for shift = 16, 0, -8 do
        local a = math.floor(fg / 2 ^ shift) % 256
        local b = math.floor(bg / 2 ^ shift) % 256
        out = out * 256 + math.floor(a * alpha + b * (1 - alpha) + 0.5)
    end
    return out
end

--- render-markdown declares its groups with `default = true`, so a plain
--- `nvim_set_hl` wins. Re-pinned on `ColorScheme` because catppuccin's
--- render_markdown integration rewrites the same groups on reload.
local function github_palette()
    local function set(name, value)
        vim.api.nvim_set_hl(0, "RenderMarkdown" .. name, value)
    end

    for level, token in ipairs(HEADINGS) do
        local fg = pick(token)
        set("H" .. level, { fg = fg, bold = true })
        set("H" .. level .. "Bg", { fg = fg, bg = tint(fg, 0.13), bold = true })
    end

    local subtle = pick("subtle")
    set("Code", { bg = subtle })
    set("CodeBorder", { fg = subtle }) -- `border = "thick"` draws ▄/▀ in this colour
    set("CodeInline", { bg = subtle })
    set("CodeInfo", { fg = pick("muted"), italic = true })

    -- Callouts: these are the colours GitHub itself uses for each alert.
    set("Info", { fg = pick("accent") })      -- NOTE
    set("Success", { fg = pick("success") })  -- TIP
    set("Hint", { fg = pick("done") })        -- IMPORTANT
    set("Warn", { fg = pick("attention") })   -- WARNING
    set("Error", { fg = pick("danger") })     -- CAUTION

    set("Link", { fg = pick("accent") })
    set("WikiLink", { fg = pick("accent") })
    set("LinkTitle", { fg = pick("accent"), underline = true })

    set("Checked", { fg = pick("success") })
    set("Unchecked", { fg = pick("muted") })
    set("Todo", { fg = pick("attention") })
    set("InlineHighlight", { fg = pick("attention") })
    set("Math", { fg = pick("sponsors") })
    set("HtmlComment", { fg = pick("muted"), italic = true })

    local border = pick("border")
    set("Bullet", { fg = pick("muted") })
    set("Quote", { fg = border })
    set("Dash", { fg = border })
    set("Indent", { fg = border })
    set("TableHead", { fg = border, bold = true })
    set("TableRow", { fg = border })
end

--- Read the current file with glow, in a centred terminal float.
local function glow_open()
    if vim.fn.executable("glow") == 0 then
        return vim.notify("glow is not on $PATH", vim.log.levels.ERROR)
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or not vim.uv.fs_stat(file) then
        return vim.notify("glow: buffer is not a file on disk", vim.log.levels.WARN)
    end

    local function geometry()
        local width = math.min(120, math.floor(vim.o.columns * 0.9))
        local height = math.floor(vim.o.lines * 0.85)
        return {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2) - 1,
            col = math.floor((vim.o.columns - width) / 2),
            style = "minimal",
            border = "rounded",
            title = " " .. vim.fs.basename(file) .. " ",
            title_pos = "center",
        }
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, geometry())

    -- `--style dark|light` because glow's `auto` cannot query a terminal it is nested in.
    vim.fn.jobstart({ "glow", "--pager", "--style", vim.o.background, file }, {
        term = true,
        on_exit = vim.schedule_wrap(function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end),
    })

    -- glow's pager repaints on SIGWINCH, so resizing the float is all it needs.
    vim.api.nvim_create_autocmd("VimResized", {
        desc = "Keep the glow float centred",
        callback = function()
            if not vim.api.nvim_win_is_valid(win) then
                return true -- window is gone; drop this autocmd
            end
            vim.api.nvim_win_set_config(win, geometry())
        end,
    })

    vim.cmd.startinsert()
end

return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = "markdown",

    -- glow needs nothing from the plugin, so wire it up at startup.
    init = function()
        vim.api.nvim_create_user_command("Glow", glow_open, { desc = "Read the current file with glow" })
        vim.keymap.set("n", "<leader>mg", glow_open, { desc = "Markdown: read with glow" })
    end,

    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        completions = { blink = { enabled = true } },
        -- Needs `utftex`/`latex2text` and the latex parser; neither is installed.
        latex = { enabled = false },
        heading = {
            sign = false,
            width = "block",
            min_width = 60,
            left_pad = 1,
            right_pad = 4,
            border = { true, true, false, false, false, false }, -- GitHub rules h1/h2 only
        },
        code = {
            sign = false,
            width = "block",
            min_width = 60,
            left_pad = 2,
            right_pad = 4,
            border = "thick",
        },
        pipe_table = { preset = "round" },
        quote = { repeat_linebreak = true },
    },

    config = function(_, opts)
        require("render-markdown").setup(opts)
        github_palette()
        vim.api.nvim_create_autocmd("ColorScheme", {
            desc = "Re-pin the Primer palette; catppuccin rewrites the same groups",
            callback = github_palette,
        })
        vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "Markdown: toggle rendering" })
        vim.keymap.set("n", "<leader>me", "<cmd>RenderMarkdown expand<cr>", { desc = "Markdown: expand raw window" })
        vim.keymap.set("n", "<leader>mc", "<cmd>RenderMarkdown contract<cr>", { desc = "Markdown: contract raw window" })
    end,
}
