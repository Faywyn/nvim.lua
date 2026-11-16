-- nvim-treesitter `main` branch (the old `master` branch is frozen).
-- Requirements: tree-sitter CLI (installed by Mason, see lsp/lsp.lua) and a C compiler
--   macOS: Xcode Command Line Tools (clang)
--   Windows: Visual Studio Build Tools, "Desktop development with C++" (MSVC)
local parsers = {
  "json", "javascript", "typescript", "tsx", "yaml", "html", "css", "vue",
  "markdown", "markdown_inline", "svelte", "graphql", "bash", "lua", "luadoc", "vim",
  "vimdoc", "query", "dockerfile", "gitignore", "c", "cpp", "python",
  "java", "dart", "ocaml", "latex", "rust", "regex", "diff",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- the main branch does not support lazy-loading
  build = ":TSUpdate",
  dependencies = { "mason-org/mason.nvim" }, -- puts the tree-sitter CLI on PATH
  config = function()
    local ts = require("nvim-treesitter")
    ts.install(parsers) -- async, no-op for parsers already installed

    -- blocking variant, usable headless: nvim --headless "+TSInstallAll" +qa
    vim.api.nvim_create_user_command("TSInstallAll", function()
      ts.install(parsers):wait(600000)
    end, { desc = "Install all configured Treesitter parsers and wait" })

    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end

    local function attach(buf, lang)
      if not pcall(vim.treesitter.start, buf, lang) then
        return false
      end
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      return true
    end

    -- highlight + indent for every filetype with a parser; install missing parsers on the fly
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("alban_treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang or attach(args.buf, lang) or not available[lang] then
          return
        end
        ts.install(lang):await(function()
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              attach(args.buf, lang)
            end
          end)
        end)
      end,
    })
  end,
}
