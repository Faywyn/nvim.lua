vim.opt.background = "light"
local status, _ = pcall(vim.cmd, "colorscheme monokai-nightasty")

if not status then
  print("Colorscheme not found !")
  return
end
