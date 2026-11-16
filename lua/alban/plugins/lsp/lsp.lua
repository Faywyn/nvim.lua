-- LSP: mason v2 installs the servers, nvim-lspconfig provides their default
-- configs, and Neovim's native vim.lsp.config / vim.lsp.enable wires them up.

-- Servers installed by Mason on every machine
local servers = {
  "lua_ls",
  "vtsls",                 -- TypeScript/JavaScript (replaces ts_ls + typescript.nvim)
  "vue_ls",                -- Vue (works together with vtsls)
  "html",
  "cssls",
  "tailwindcss",
  "emmet_language_server",
  "clangd",
  "pyright",
  "texlab",
  "copilot",               -- GitHub Copilot (inline suggestions, see ai.lua)
}
-- Other tools installed by Mason
local tools = {
  "tree-sitter-cli", -- needed by nvim-treesitter (main branch) to build parsers
}

-- Java server only where a JDK is installed
if vim.fn.executable("java") == 1 then
  table.insert(servers, "jdtls")
end

local function on_attach(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  local map = function(lhs, rhs, desc, mode)
    vim.keymap.set(mode or "n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
  end
  local jump = function(count)
    return function() vim.diagnostic.jump({ count = count, float = true }) end
  end

  -- same keys as with lspsaga; peeks open in a Glance window (<CR> opens, q closes)
  map("gf", "<cmd>Glance references<CR>", "Peek references")
  map("gd", "<cmd>Glance definitions<CR>", "Peek definition")
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gi", "<cmd>Glance implementations<CR>", "Peek implementations")
  map("gy", "<cmd>Glance type_definitions<CR>", "Peek type definition")
  map("K", vim.lsp.buf.hover, "Hover documentation")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
  map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>D", function() vim.diagnostic.open_float({ scope = "line" }) end, "Line diagnostics")
  map("<leader>d", function() vim.diagnostic.open_float({ scope = "cursor" }) end, "Cursor diagnostics")
  map("[d", jump(-1), "Previous diagnostic")
  map("]d", jump(1), "Next diagnostic")
  map("<leader>ci", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
  end, "Toggle inlay hints")

  -- TypeScript helpers (were provided by the archived typescript.nvim)
  if client and client.name == "vtsls" then
    local action = function(kind)
      return function()
        vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
      end
    end
    map("<leader>oi", action("source.organizeImports"), "Organize imports")
    map("<leader>ru", action("source.removeUnused.ts"), "Remove unused")
    map("<leader>rf", function()
      local old = vim.api.nvim_buf_get_name(0)
      vim.ui.input({ prompt = "New path: ", default = old, completion = "file" }, function(new)
        if not new or new == "" or new == old then
          return
        end
        -- Neovim does not send LSP file-operation events itself, so do it here:
        -- willRenameFiles (edits returned before the move) then didRenameFiles (vtsls updates imports)
        local files = { { oldUri = vim.uri_from_fname(old), newUri = vim.uri_from_fname(new) } }
        for _, c in ipairs(vim.lsp.get_clients()) do
          if c:supports_method("workspace/willRenameFiles") then
            local res = c:request_sync("workspace/willRenameFiles", { files = files }, 2000, event.buf)
            if res and res.result then
              vim.lsp.util.apply_workspace_edit(res.result, c.offset_encoding)
            end
          end
        end
        vim.lsp.util.rename(old, new)
        for _, c in ipairs(vim.lsp.get_clients()) do
          if c:supports_method("workspace/didRenameFiles") then
            c:notify("workspace/didRenameFiles", { files = files })
          end
        end
      end)
    end, "Rename file (update imports)")
  end
end

return {
  {
    "mason-org/mason.nvim",
    lazy = false, -- cheap, and puts Mason's bin folder on PATH (tree-sitter CLI)
    opts = { ui = { border = "rounded" } },
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")

      -- install a list of Mason packages; returns a function telling if all are done
      local function install(names)
        local pending = {}
        registry.refresh(function()
          for _, name in ipairs(names) do
            local ok, pkg = pcall(registry.get_package, name)
            if ok and not pkg:is_installed() and not pkg:is_installing() then
              pending[name] = true
              pkg:install({}, function() pending[name] = nil end)
            end
          end
        end)
        return function() return vim.tbl_isempty(pending) end
      end

      -- non-LSP tools on every start (LSP servers: mason-lspconfig below)
      install(tools)

      -- :MasonInstallAll installs tools + LSP servers and waits; also works headless:
      --   nvim --headless "+MasonInstallAll" +qa
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        require("lazy").load({ plugins = { "mason-lspconfig.nvim" } })
        local map = require("mason-lspconfig").get_mappings().lspconfig_to_package
        local names = vim.deepcopy(tools)
        for _, server in ipairs(servers) do
          table.insert(names, map[server] or server)
        end
        local done = install(names)
        vim.wait(600000, function()
          return done() and #vim.tbl_filter(function(n) return not registry.is_installed(n) end, names) == 0
        end, 1000)
        for _, n in ipairs(names) do
          print(("%-30s %s"):format(n, registry.is_installed(n) and "installed" or "MISSING"))
        end
      end, { desc = "Install all Mason tools and LSP servers" })
    end,
  },

  -- Lua LSP knows about the Neovim API and installed plugins
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- defaults for every server: completion capabilities from blink.cmp
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Vue: vtsls loads the Vue TypeScript plugin shipped with vue-language-server
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
        languages = { "vue" },
        configNamespace = "typescript",
      }
      vim.lsp.config("vtsls", {
        settings = {
          vtsls = { tsserver = { globalPlugins = { vue_plugin } } },
          typescript = { updateImportsOnFileMove = { enabled = "always" } },
          javascript = { updateImportsOnFileMove = { enabled = "always" } },
        },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte", "vue" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("alban_lsp_attach", { clear = true }),
        callback = on_attach,
      })

      -- installs missing servers and enables every installed one
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })

      -- OCaml: installed through opam (not Mason), enabled only if present
      if vim.fn.executable("ocamllsp") == 1 then
        vim.lsp.enable("ocamllsp")
      end
    end,
  },

  -- peek definitions / references / implementations in a floating window
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    opts = {
      border = { enable = true },
      list = { position = "left" },
    },
  },

  -- code outline sidebar (LSP or Treesitter symbols)
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialNavToggle" },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<CR>", desc = "Toggle outline" },
      { "<leader>O", "<cmd>AerialNavToggle<CR>", desc = "Outline navigation popup" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
      layout = { default_direction = "prefer_left" },
      show_guides = true,
    },
  },
}
