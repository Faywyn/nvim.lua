return {
  -- lua functions that many plugins use
  { "nvim-lua/plenary.nvim", lazy = true },

  -- split window navigation with <C-h/j/k/l> (also works across tmux panes on macOS)
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>" },
    },
  },

  -- maximize / restore the current split
  {
    "szw/vim-maximizer",
    keys = { { "<leader>sm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/restore split" } },
  },

  -- add, delete, change surroundings
  { "tpope/vim-surround", event = { "BufReadPost", "BufNewFile" } },

  -- replace with register contents using motion (gr + motion)
  { "inkarkat/vim-ReplaceWithRegister", event = { "BufReadPost", "BufNewFile" } },

  -- note: commenting with gc / gcc is built into Neovim since 0.10 (Comment.nvim removed)

  -- autoclose parens, brackets, quotes...
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        java = false,
      },
    },
  },

  -- autoclose and autorename html/jsx/vue tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
