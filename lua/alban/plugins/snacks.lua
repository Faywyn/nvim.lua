-- snacks.nvim: fuzzy picker (replaces Telescope, same <leader>f / <leader>g keys)
-- plus small quality-of-life modules for reading code.
local function pick(source, opts)
  return function() Snacks.picker[source](opts) end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    picker = {
      -- <C-j>/<C-k> move in the list, <C-q> sends to the quickfix list (defaults)
      layout = { preset = "telescope" },
      matcher = { frecency = true },
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
      },
    },
    input = {}, -- nicer vim.ui.input (rename symbol, rename file...)
    notifier = {}, -- notifications in the corner (:lua Snacks.notifier.show_history())
    words = {}, -- highlight other uses of the word under cursor; ]] / [[ jump between them
    indent = { animate = { enabled = false } }, -- indent guides + current scope
    scope = {}, -- ii / ai text objects, [i / ]i jump to scope edges
    bigfile = {}, -- disable heavy features on huge files
    quickfile = {}, -- render the file before plugins load (nvim somefile)
  },
  keys = {
    -- find (same keys as before)
    { "<leader>ff", pick("files"), desc = "Find files" },
    { "<leader>fs", pick("grep"), desc = "Find string (live grep)" },
    { "<leader>fc", pick("grep_word"), mode = { "n", "x" }, desc = "Find string under cursor / selection" },
    { "<leader>fb", pick("buffers"), desc = "Find buffers" },
    { "<leader>fh", pick("help"), desc = "Find help" },
    -- find (new)
    { "<leader>fr", pick("recent", { filter = { cwd = true } }), desc = "Recent files (this project)" },
    { "<leader>fl", pick("lines"), desc = "Lines in current buffer" },
    { "<leader>fo", pick("grep_buffers"), desc = "Grep in open buffers" },
    { "<leader>fd", pick("diagnostics"), desc = "Diagnostics" },
    { "<leader>fS", pick("lsp_workspace_symbols"), desc = "Symbols (workspace)" },
    { "<leader>fy", pick("lsp_symbols"), desc = "Symbols (file)" },
    { "<leader>fj", pick("jumps"), desc = "Jump list" },
    { "<leader>fm", pick("marks"), desc = "Marks" },
    { "<leader>fk", pick("keymaps"), desc = "Keymaps" },
    { "<leader>f/", pick("search_history"), desc = "Search history" },
    { "<leader>fR", pick("resume"), desc = "Resume last picker" },
    { "<leader>fp", pick("pickers"), desc = "All pickers" },

    -- git (same keys as before)
    { "<leader>gc", pick("git_log"), desc = "Git commits" },
    { "<leader>gfc", pick("git_log_file"), desc = "Git commits (file)" },
    { "<leader>gb", pick("git_branches"), desc = "Git branches" },
    { "<leader>gs", pick("git_status"), desc = "Git status" },
    -- git (new)
    { "<leader>gd", pick("git_diff"), desc = "Git diff hunks" },
    { "<leader>gL", pick("git_log_line"), desc = "Git log of current line" },
    { "<leader>go", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Open on GitHub" },
    {
      "<leader>gg",
      function()
        if vim.fn.executable("lazygit") == 1 then
          Snacks.lazygit()
        else
          vim.notify("lazygit is not installed", vim.log.levels.WARN)
        end
      end,
      desc = "Lazygit",
    },

    -- references of the word under cursor
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous reference" },
  },
}
