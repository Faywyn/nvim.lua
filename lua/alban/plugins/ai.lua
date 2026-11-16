local has_ollama = function()
  return vim.fn.executable("ollama") == 1
end

return {
  -- GitHub Copilot (needs Node.js; run :Copilot setup once)
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = "Copilot",
  },

  -- Ollama chat/prompt plugin (only when Ollama is installed)
  {
    "David-Kunz/gen.nvim",
    cond = has_ollama,
    cmd = "Gen",
    opts = {
      model = "codellama:13b",
      host = "localhost",
      port = "11434",
      display_mode = "float",
      show_prompt = false,
      show_model = false,
      quit_map = "q",
      no_auto_close = false,
      debug = false,
    },
  },

  -- Ollama code completion (own plugin)
  {
    "Faywyn/llama-copilot.nvim",
    cond = has_ollama,
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      host = "localhost",
      port = "11434",
      model = "codellama:13b-code",
      max_completion_size = 20, -- use -1 for limitless
      debug = false,
    },
  },
}
