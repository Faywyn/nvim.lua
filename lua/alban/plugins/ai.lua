-- AI: GitHub Copilot (native Neovim 0.12 inline completion), Claude Code, Ollama
--
-- Copilot runs as an LSP server (copilot-language-server, installed by Mason and
-- enabled with the other servers in lsp/lsp.lua). Neovim 0.12 shows its suggestions
-- as ghost text, no copilot.vim needed. Sign in once with :Copilot auth
-- (same GitHub token file as copilot.vim, so an existing login is reused).

-- Copilot keymaps and the :Copilot command, set once the server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("alban_copilot", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "copilot" then
      return
    end
    vim.lsp.inline_completion.enable(true, { bufnr = event.buf })

    local map = function(lhs, rhs, desc)
      vim.keymap.set("i", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    -- <Tab> accepts the suggestion (like copilot.vim), otherwise inserts a tab
    vim.keymap.set("i", "<Tab>", function()
      if not vim.lsp.inline_completion.get() then
        return "<Tab>"
      end
    end, { buffer = event.buf, expr = true, desc = "Copilot: accept suggestion" })
    map("<M-]>", function() vim.lsp.inline_completion.select({ count = 1 }) end, "Copilot: next suggestion")
    map("<M-[>", function() vim.lsp.inline_completion.select({ count = -1 }) end, "Copilot: previous suggestion")
  end,
})

-- :Copilot auth | signout | enable | disable | status (same names as copilot.vim)
vim.api.nvim_create_user_command("Copilot", function(opts)
  local sub = opts.fargs[1] or "status"
  local ic = vim.lsp.inline_completion
  if sub == "auth" or sub == "setup" then
    vim.cmd("LspCopilotSignIn")
  elseif sub == "signout" then
    vim.cmd("LspCopilotSignOut")
  elseif sub == "enable" then
    ic.enable(true)
  elseif sub == "disable" then
    ic.enable(false)
  else
    local running = #vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) > 0
    vim.notify(("Copilot: server %s, suggestions %s"):format(
      running and "attached" or "not attached",
      ic.is_enabled() and "on" or "off"
    ))
  end
end, {
  nargs = "?",
  complete = function() return { "auth", "signout", "enable", "disable", "status" } end,
  desc = "Copilot (native LSP)",
})

local has_ollama = function()
  return vim.fn.executable("ollama") == 1
end

return {
  -- Claude Code inside Neovim: opens `claude` in a split and connects to it like the
  -- VS Code extension (it sees the current file/selection and shows diffs here)
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd",
      "ClaudeCodeSend", "ClaudeCodeTreeAdd", "ClaudeCodeStatus", "ClaudeCodeStart",
      "ClaudeCodeStop", "ClaudeCodeOpen", "ClaudeCodeClose", "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny", "ClaudeCodeCloseAllDiffs",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<CR>", desc = "Resume a Claude session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<CR>", desc = "Continue last Claude session" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Add current file to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<CR>",
        desc = "Add file to Claude",
        ft = { "NvimTree", "oil", "snacks_picker_list" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept Claude's diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Reject Claude's diff" },
    },
    opts = {
      terminal = { split_side = "left", split_width_percentage = 0.35 },
    },
  },

  -- Ollama code completion (own plugin, only when Ollama is installed)
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
