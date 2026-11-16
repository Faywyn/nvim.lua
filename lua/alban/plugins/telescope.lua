return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      -- native sorter: built with `make` on macOS/Linux, with zig on Windows
      "nvim-telescope/telescope-fzf-native.nvim",
      build = vim.fn.has("win32") == 1 and function(plugin)
        vim.fn.mkdir(plugin.dir .. "/build", "p")
        local res = vim.system(
          { "zig", "cc", "-O3", "-Wall", "-std=gnu99", "-shared", "src/fzf.c", "-o", "build/libfzf.dll" },
          { cwd = plugin.dir }
        ):wait()
        assert(res.code == 0, "telescope-fzf-native build failed: " .. (res.stderr or ""))
      end or "make",
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fs", "<cmd>Telescope live_grep<CR>", desc = "Find string (live grep)" },
    { "<leader>fc", "<cmd>Telescope grep_string<CR>", desc = "Find string under cursor" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find help" },
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    { "<leader>gfc", "<cmd>Telescope git_bcommits<CR>", desc = "Git commits (file)" },
    { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
    { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
