# link.ps1 — Symlink core-utils configs to $USERPROFILE on Windows (native).
# Run from an elevated PowerShell prompt (Admin required for symlinks).
param(
  [switch]$Force,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotDir     = Join-Path $ScriptDir "dot"
$HomeDir    = $env:USERPROFILE

function New-Symlink($Source, $Target) {
  if (Test-Path $Target) {
    if (-not $Force) {
      Write-Host "SKIP (exists):  $Target" -ForegroundColor Yellow
      return
    }
    Remove-Item $Target -Recurse -Force
  }
  $Parent = Split-Path $Target -Parent
  if (-not (Test-Path $Parent)) {
    if (-not $DryRun) { New-Item -ItemType Directory -Path $Parent -Force | Out-Null }
  }
  if ($DryRun) {
    Write-Host "LINK (dry-run): $Target -> $Source" -ForegroundColor Cyan
  } else {
    New-Item -ItemType SymbolicLink -Path $Target -Value $Source | Out-Null
    Write-Host "LINKED:         $Target" -ForegroundColor Green
  }
}

# .zshenv (for Git Bash / MSYS2 on Windows)
New-Symlink (Join-Path $DotDir ".zshenv") (Join-Path $HomeDir ".zshenv")

# Tool configs that work natively on Windows: git, ripgrep, tig, atuin, lazygit
$NativeConfigs = @("git", "ripgrep", "atuin", "tig", "lazygit")
$ConfigSource  = Join-Path $DotDir ".config"
$ConfigTarget  = Join-Path $HomeDir ".config"

foreach ($name in $NativeConfigs) {
  $src = Join-Path $ConfigSource $name
  $tgt = Join-Path $ConfigTarget $name
  if (Test-Path $src) { New-Symlink $src $tgt }
}


Write-Host ""
Write-Host "Done." -ForegroundColor Cyan
Write-Host "Zsh configs linked for Git Bash / MSYS2 use." -ForegroundColor Cyan
