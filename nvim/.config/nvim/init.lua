-- Expose luarocks packages (e.g. magick for image.nvim) to Neovim's LuaJIT
local home = vim.fn.expand("$HOME")
package.path  = package.path  .. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua"
                              .. ";" .. home .. "/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.1/?.so"

require("vim-options")
require("config.lazy")

