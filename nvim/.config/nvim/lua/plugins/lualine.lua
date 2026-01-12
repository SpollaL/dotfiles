return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'dracula'
        },
        sections = {
          lualine_x = {
            -- Add snacks profiler status when available
            function()
              local ok, Snacks = pcall(require, "snacks")
              if ok and Snacks.profiler and Snacks.profiler.status then
                return Snacks.profiler.status()
              end
              return ""
            end,
          },
        },
      })
    end
  }
}
