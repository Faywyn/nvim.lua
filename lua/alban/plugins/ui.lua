return {
  -- color theme (light)
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.cmd.colorscheme("monokai-nightasty")
    end,
  },

  -- icons (needs a Nerd Font in the terminal)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto", globalstatus = true },
    },
  },

  -- file explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
    opts = {
      -- disable window_picker so the explorer works well with splits
      actions = { open_file = { window_picker = { enable = false } } },
      view = { side = "right" },
      filters = { custom = { "^.git$", "^.DS_Store$" } },
    },
  },

  -- keymap hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "split" },
        { "<leader>t", group = "tab" },
        { "<leader>c", group = "code" },
        { "<leader>a", group = "AI (Claude Code)" },
        { "<leader>u", group = "toggle" },
        { "<leader>gf", group = "file" },
      },
    },
  },
}
