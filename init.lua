-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("alban.core.options")
require("alban.core.keymaps")
require("alban.lazy")
