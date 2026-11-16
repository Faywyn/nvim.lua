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

  -- git signs in the gutter + hunk navigation and blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
        end
        map("]h", function() gs.nav_hunk("next") end, "Next git hunk")
        map("[h", function() gs.nav_hunk("prev") end, "Previous git hunk")
        map("<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("<leader>gB", function() gs.blame_line({ full = true }) end, "Blame line (full commit)")
        map("<leader>gl", gs.toggle_current_line_blame, "Toggle inline blame")
        map("<leader>gD", gs.diffthis, "Diff file against index")
      end,
    },
  },

  -- review diffs, branches and file history in a tab
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diff view (working tree)" },
      { "<leader>gm", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", desc = "Diff view (branch vs default branch)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repository history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
    },
    opts = {},
  },

  -- jump anywhere on screen: s + 2 chars + label; S selects a treesitter node.
  -- While searching with / or ?, <C-s> toggles jump labels on the matches.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } }, -- keep f/t/F/T as usual
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "o" }, desc = "Flash treesitter select" },
      { "r", function() require("flash").remote() end, mode = "o", desc = "Remote flash" },
      { "<C-s>", function() require("flash").toggle() end, mode = "c", desc = "Toggle flash in search" },
    },
  },

  -- edit directories like a buffer: - opens the parent directory of the current file
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" } },
    opts = {
      default_file_explorer = false, -- nvim-tree stays the explorer for `nvim .`
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
  },
}
