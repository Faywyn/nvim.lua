return {
  -- snippet engine (VS Code snippets from friendly-snippets + personal Lua snippets)
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    lazy = true,
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local luasnip = require("luasnip")
      luasnip.config.set_config({ enable_autosnippets = true })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/alban/snippets" },
      })
    end,
  },

  -- completion menu (replaces nvim-cmp; same keys)
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tags ship a prebuilt fuzzy matcher
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        -- <C-j>/<C-k>: move in the menu, otherwise jump between snippet fields
        ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
        ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        -- <Tab> is left to Copilot (see ai.lua)
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = { lua = { "lazydev", "lsp", "path", "snippets", "buffer" } },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      cmdline = {
        keymap = { preset = "cmdline", ["<C-j>"] = { "select_next" }, ["<C-k>"] = { "select_prev" } },
        -- menu pops up for : commands, not while searching with / or ?
        completion = { menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end } },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
