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
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
  end

  map("gf", "<cmd>Lspsaga finder<CR>", "LSP finder (definition, references)")
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gd", "<cmd>Lspsaga peek_definition<CR>", "Peek definition")
  map("gi", vim.lsp.buf.implementation, "Go to implementation")
  map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code action")
  map("<leader>rn", "<cmd>Lspsaga rename<CR>", "Rename symbol")
  map("<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", "Line diagnostics")
  map("<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Cursor diagnostics")
  map("[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Previous diagnostic")
  map("]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next diagnostic")
  map("K", "<cmd>Lspsaga hover_doc<CR>", "Hover documentation")
  map("<leader>o", "<cmd>Lspsaga outline<CR>", "Toggle outline")

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
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- defaults for every server: completion capabilities from nvim-cmp
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
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

  -- LSP UI (finder, peek definition, outline, code actions...)
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
    opts = {
      scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
      definition = { keys = { edit = "<CR>" } },
      lightbulb = { enable = false },
    },
  },
}
