# bootstrap.ps1 — Set up core-utils on Windows (native).
# Run from PowerShell (Admin required for symlinks).
#
# Usage:
#   iwr -useb <raw-url>/bootstrap.ps1 | iex
#   .\bootstrap.ps1 [-Force] [-NoPackages] [-NoLink]
param(
  [switch]$Force,
  [switch]$NoPackages,
  [switch]$NoLink
)

$ErrorActionPreference = "Stop"
$RepoUrl    = "https://github.com/deeedob/core-utils"
$InstallDir = if ($env:CORE_UTILS_DIR) { $env:CORE_UTILS_DIR } else { "$env:USERPROFILE\.local\share\core-utils" }

function Info($msg)    { Write-Host "[core-utils] $msg" -ForegroundColor Blue }
function Success($msg) { Write-Host "[core-utils] $msg" -ForegroundColor Green }
function Warn($msg)    { Write-Host "[core-utils] $msg" -ForegroundColor Yellow }

# ---------------------------------------------------------------------------
# Scoop
# ---------------------------------------------------------------------------
function Install-Scoop {
  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Info "Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
  }
}

function Install-ScoopPackages {
  $PkgFile = Join-Path $InstallDir "packages\scoop.txt"
  if (-not (Test-Path $PkgFile)) { return }

  # Add buckets first
  $buckets = @("extras", "nerd-fonts", "versions")
  foreach ($b in $buckets) {
    scoop bucket add $b 2>$null | Out-Null
  }

  $packages = Get-Content $PkgFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }
  if ($packages.Count -eq 0) { return }

  Info "Installing Scoop packages..."
  foreach ($pkg in $packages) {
    scoop install $pkg 2>&1 | Where-Object { $_ -notmatch 'already installed' }
  }
}

# ---------------------------------------------------------------------------
# Repo
# ---------------------------------------------------------------------------
function Clone-OrUpdate {
  if (Test-Path (Join-Path $InstallDir ".git")) {
    Info "Updating existing repo..."
    git -C $InstallDir pull --ff-only
    git -C $InstallDir submodule update --remote --merge
  } else {
    Info "Cloning core-utils to $InstallDir..."
    git clone --recurse-submodules $RepoUrl $InstallDir
  }
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
Clone-OrUpdate

if (-not $NoPackages) {
  Install-Scoop
  Install-ScoopPackages
}

if (-not $NoLink) {
  $LinkScript = Join-Path $InstallDir "link.ps1"
  $linkArgs = @()
  if ($Force) { $linkArgs += "-Force" }
  & $LinkScript @linkArgs
}

Success "Done. Restart your terminal."
