# Windows setup for this Neovim config.
# Run from a regular PowerShell window (not from inside a sandboxed app):
#   powershell -ExecutionPolicy Bypass -File "$HOME\.config\nvim\scripts\setup-windows.ps1"
# Idempotent: safe to run again.
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot

function Install-Pkg($id, [string[]]$extra = @()) {
    Write-Host "==> $id" -ForegroundColor Cyan
    winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity @extra | Out-Null
}

# 1. Tools: Neovim, Git, Node (npm-based LSPs), ripgrep/fd (picker), lazygit, Claude Code CLI,
#    MSVC Build Tools (Treesitter parsers), Nerd Font (icons)
Install-Pkg 'Neovim.Neovim'
Install-Pkg 'Git.Git'
Install-Pkg 'OpenJS.NodeJS.LTS'
Install-Pkg 'BurntSushi.ripgrep.MSVC'
Install-Pkg 'sharkdp.fd'
Install-Pkg 'JesseDuffield.lazygit'
Install-Pkg 'Anthropic.ClaudeCode'
Install-Pkg 'DEVCOM.JetBrainsMonoNerdFont'
if (-not (Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\BuildTools\VC\Tools\MSVC" -ErrorAction SilentlyContinue)) {
    Install-Pkg 'Microsoft.VisualStudio.2022.BuildTools' @('--override', '--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
}

# 2. Neovim reads %LOCALAPPDATA%\nvim on Windows: link it to this repo
$target = Join-Path $env:LOCALAPPDATA 'nvim'
$item = Get-Item $target -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq 'Junction' -and $item.Target -contains $repo) {
    Write-Host "OK: $target -> $repo"
} elseif ($item) {
    Write-Warning "$target already exists and is not a link to $repo. Rename or delete it, then run this script again."
} else {
    New-Item -ItemType Junction -Path $target -Target $repo | Out-Null
    Write-Host "Created: $target -> $repo"
}

# 3. Windows Terminal: use the Nerd Font so icons render
$wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (Test-Path $wt) {
    try {
        $json = Get-Content $wt -Raw | ConvertFrom-Json
        if (-not $json.profiles.defaults) { $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force }
        $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{ face = 'JetBrainsMono Nerd Font' }) -Force
        Copy-Item $wt "$wt.bak" -Force
        $json | ConvertTo-Json -Depth 32 | Set-Content $wt -Encoding utf8
        Write-Host 'Windows Terminal font set to JetBrainsMono Nerd Font (backup: settings.json.bak)'
    } catch {
        Write-Warning "Could not edit Windows Terminal settings, set the font manually: $_"
    }
}

# 4. Install plugins, Treesitter parsers and LSP servers
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
Write-Host '==> Installing plugins (lazy.nvim)...' -ForegroundColor Cyan
nvim --headless '+Lazy! sync' +qa
Write-Host '==> Installing LSP servers (Mason)...' -ForegroundColor Cyan
nvim --headless '+MasonInstallAll' +qa
Write-Host '==> Installing Treesitter parsers...' -ForegroundColor Cyan
nvim --headless '+TSInstallAll' +qa
Write-Host 'Done. Check with :checkhealth inside nvim.' -ForegroundColor Green
