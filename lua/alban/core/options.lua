local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true
opt.scrolloff = 5

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- disable mouse
opt.mouse = ""

-- Disable arrow keys in insert
vim.api.nvim_set_keymap("i", "<up>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<down>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<left>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<right>", "<nop>", { noremap = true })
