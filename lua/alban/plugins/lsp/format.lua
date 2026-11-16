-- Format on save (replaces lsp-format.nvim).
-- Uses a dedicated formatter when one is configured below, otherwise the LSP.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      -- e.g. javascript = { "prettierd", "prettier", stop_after_first = true },
    },
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  },
}
