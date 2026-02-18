-- import plugin safely
local setup, llama = pcall(require, "llama-copilot")
if not setup then
  print("Error while require(llama-copilot)")
  return
end

llama.setup({
  host = "localhost",
  port = "11434",
  model = "codellama:12b-code",
  max_completion_size = 20, -- use -1 for limitless
  debug = false
})
