# nvim.lua

My personal Neovim configuration. Works on **macOS** and **Windows**.
Requires **Neovim 0.12+**.

## Layout

```
init.lua                    leader key, then core/ and lazy.nvim
lua/alban/core/             options and general keymaps
lua/alban/lazy.lua          lazy.nvim bootstrap
lua/alban/plugins/          one file per area (ui, editor, snacks, treesitter, completion, lang, ai)
lua/alban/plugins/lsp/      LSP (mason + native vim.lsp.config) and formatting (conform)
lua/alban/snippets/         personal LuaSnip snippets
scripts/setup-windows.ps1   Windows bootstrap
lazy-lock.json              pinned plugin versions (commit it after :Lazy update)
```

## Install

### macOS

```sh
xcode-select --install                     # clang, for Treesitter parsers
brew install neovim git node ripgrep fd lazygit
brew install --cask font-jetbrains-mono-nerd-font   # then select it in your terminal
git clone git@github.com:Faywyn/nvim.lua.git ~/.config/nvim
nvim                                       # plugins, parsers and LSP servers install on first start
```

### Windows

```powershell
git clone git@github.com:Faywyn/nvim.lua.git $HOME\.config\nvim
powershell -ExecutionPolicy Bypass -File $HOME\.config\nvim\scripts\setup-windows.ps1
```

The script installs Neovim, Node, ripgrep, fd, lazygit, Claude Code, the MSVC Build Tools and the
JetBrainsMono Nerd Font with winget. It links `%LOCALAPPDATA%\nvim` to the repo,
sets the Windows Terminal font and installs the plugins.

## Language servers

Mason installs these on every machine: lua_ls, vtsls (TypeScript/JS), vue_ls, html, cssls,
tailwindcss, emmet_language_server, clangd, pyright, texlab and copilot (GitHub Copilot).
jdtls is added when `java` is on PATH. ocamllsp is enabled when it is installed via opam.
Use `:Mason` to see what is installed and `:checkhealth` to diagnose problems.

## AI

- **Copilot** uses Neovim 0.12's native inline completion with `copilot-language-server`.
  Sign in once with `:Copilot auth` (an existing copilot.vim login is reused).
  `<Tab>` accepts, `<M-]>` / `<M-[>` cycle suggestions, `:Copilot disable|enable|status`.
- **Claude Code** ([claudecode.nvim](https://github.com/coder/claudecode.nvim)) needs the
  `claude` CLI on PATH. It opens Claude in a split and shares the current file/selection;
  Claude's edits appear as diffs to accept (`<leader>aa`) or reject (`<leader>ad`).
- **Ollama** completion (llama-copilot.nvim) loads only when `ollama` is installed.

## Main keymaps (leader = Space)

| Keys | Action |
| --- | --- |
| `<leader>e` / `-` | file explorer (nvim-tree) / parent directory as a buffer (oil) |
| `<leader>ff` / `fs` / `fc` / `fb` / `fh` | find files / live grep / grep word or selection / buffers / help |
| `<leader>fr` / `fl` / `fo` / `fy` / `fS` | recent files / buffer lines / grep open buffers / file symbols / workspace symbols |
| `<leader>fd` / `fj` / `fm` / `fk` / `fR` | diagnostics / jumps / marks / keymaps / resume last picker |
| `gd` / `gf` / `gi` / `gy` | peek definition / references / implementations / type definition (Glance) |
| `gD` / `K` | declaration / hover |
| `]]` / `[[` | next / previous use of the word under cursor |
| `<leader>o` / `<leader>O` | outline sidebar / outline popup (aerial) |
| `s` / `S` | jump anywhere (flash) / select a treesitter node; `<C-s>` while searching with `/` |
| `[x` / `<leader>uc` | go to sticky context / toggle sticky context |
| `<leader>ca` / `<leader>rn` / `<leader>ci` | code action / rename / toggle inlay hints |
| `[d` / `]d` / `<leader>d` / `<leader>D` | previous / next diagnostic / cursor / line diagnostics |
| `<leader>cf` | format buffer (also runs on save) |
| `<leader>oi` / `<leader>ru` / `<leader>rf` | TS: organize imports / remove unused / rename file |
| `]h` / `[h` / `<leader>gp` | next / previous git hunk / preview hunk |
| `<leader>gB` / `<leader>gl` / `<leader>gL` | blame line / toggle inline blame / log of current line |
| `<leader>gc` / `gfc` / `gb` / `gs` / `gd` | commits / file commits / branches / status / diff hunks |
| `<leader>gv` / `gm` / `gh` / `gH` / `gq` | diffview: working tree / branch vs default / file history / repo history / close |
| `<leader>go` / `<leader>gg` | open on GitHub / lazygit |
| `<leader>ac` / `af` / `ab` / `as` | Claude Code: toggle / focus / add file / send selection |
| `<leader>sv` / `sh` / `sm` / `sx` | split vertical / horizontal / maximize / close |
