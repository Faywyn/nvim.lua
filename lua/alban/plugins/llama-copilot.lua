-- import plugin safely
local setup, llama = pcall(require, "llama-copilot")
if not setup then
  return
end

-- configure
llama.setup({
  model = "codellama:13b-code"
})
