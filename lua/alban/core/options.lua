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
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard (Neovim on Windows ships win32yank, macOS uses pbcopy)
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- persistent undo across sessions
opt.undofile = true

-- disable mouse
opt.mouse = ""

-- which-key popup delay
opt.timeout = true
opt.timeoutlen = 300

-- remote plugin providers are not used by this config (faster startup, clean :checkhealth)
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- netrw is replaced by nvim-tree (must be disabled before it loads)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- rounded borders on every floating window (hover, signature, diagnostics...)
vim.o.winborder = "rounded"

-- Neovim 0.11+ maps grn/gra/grr/gri/grt to LSP actions; they make `gr` (ReplaceWithRegister)
-- wait for a second key. The same actions are on <leader>rn, <leader>ca, gf, gi, gy.
for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grx" }) do
  pcall(vim.keymap.del, "n", lhs)
  pcall(vim.keymap.del, "x", lhs)
end

-- Diagnostics: signs in the gutter (replaces the deprecated sign_define)
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

-- Disable arrow keys in insert mode
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set("i", key, "<Nop>")
end
