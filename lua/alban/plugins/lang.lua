return {
  -- LaTeX (must not be lazy-loaded, see :h vimtex-lazy)
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      if vim.fn.has("mac") == 1 then
        vim.g.vimtex_view_method = "skim"
      elseif vim.fn.has("win32") == 1 then
        vim.g.vimtex_view_method = vim.fn.executable("SumatraPDF") == 1 and "sumatrapdf" or "general"
      else
        vim.g.vimtex_view_method = "zathura"
      end
    end,
  },

  -- Flutter / Dart (only loaded in dart files; needs the Flutter SDK)
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
