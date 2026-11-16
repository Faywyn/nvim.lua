# nvim.lua

My personal Neovim configuration. Works on **macOS** and **Windows**.
Requires **Neovim 0.12+**.

## Layout

```
init.lua                    leader key, then core/ and lazy.nvim
lua/alban/core/             options and general keymaps
lua/alban/lazy.lua          lazy.nvim bootstrap
lua/alban/plugins/          one file per area (ui, editor, telescope, treesitter, completion, lang, ai)
lua/alban/plugins/lsp/      LSP (mason + native vim.lsp.config) and formatting (conform)
lua/alban/snippets/         personal LuaSnip snippets
scripts/setup-windows.ps1   Windows bootstrap
lazy-lock.json              pinned plugin versions (commit it after :Lazy update)
```

## Install

### macOS

```sh
xcode-select --install                     # clang, for Treesitter parsers and fzf-native
brew install neovim git node ripgrep fd
brew install --cask font-jetbrains-mono-nerd-font   # then select it in your terminal
git clone git@github.com:Faywyn/nvim.lua.git ~/.config/nvim
nvim                                       # plugins, parsers and LSP servers install on first start
```

### Windows

```powershell
git clone git@github.com:Faywyn/nvim.lua.git $HOME\.config\nvim
powershell -ExecutionPolicy Bypass -File $HOME\.config\nvim\scripts\setup-windows.ps1
```

The script installs Neovim, Node, ripgrep, fd, zig, the MSVC Build Tools and the
JetBrainsMono Nerd Font with winget. It links `%LOCALAPPDATA%\nvim` to the repo,
sets the Windows Terminal font and installs the plugins.

## Language servers

Mason installs these on every machine: lua_ls, vtsls (TypeScript/JS), vue_ls, html, cssls,
tailwindcss, emmet_language_server, clangd, pyright and texlab.
jdtls is added when `java` is on PATH. ocamllsp is enabled when it is installed via opam.
Use `:Mason` to see what is installed and `:checkhealth` to diagnose problems.

## Main keymaps (leader = Space)

| Keys | Action |
| --- | --- |
| `<leader>e` | file explorer |
| `<leader>ff` / `fs` / `fc` / `fb` | find files / live grep / grep word / buffers |
| `gd` / `gf` / `K` | peek definition / LSP finder / hover |
| `<leader>ca` / `<leader>rn` | code action / rename |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>cf` | format buffer (also runs on save) |
| `<leader>oi` / `<leader>ru` | TS: organize imports / remove unused |
| `<leader>sv` / `sh` / `sm` / `sx` | split vertical / horizontal / maximize / close |
