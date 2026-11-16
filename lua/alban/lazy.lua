-- Bootstrap lazy.nvim (plugin manager, replaces the archived packer.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "alban.plugins" },
    { import = "alban.plugins.lsp" },
  },
  install = { colorscheme = { "monokai-nightasty", "habamax" } },
  checker = { enabled = true, notify = false }, -- check for plugin updates in the background
  change_detection = { notify = false },
  rocks = { enabled = false },                  -- no plugin here needs luarocks
})
