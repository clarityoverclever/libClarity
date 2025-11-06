# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Helper
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: >=7.2
# ---

<#
.SYNOPSIS
Installs local Git hooks for the repository.

.DESCRIPTION
Copies version-controlled Git hook templates from the .githooks directory
into the active .git/hooks directory. Makes them executable and ready for use.

.EXAMPLE
PS> ./Install-GitHooks.ps1

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/Private/Install-GitHooks.ps1
https://github.com/clarityoverclever/libClarity/blob/main/.githooks
#>

[CmdletBinding()]
param (
    [string] $RepoRoot = (Get-Location).Path
)

# enforce strict behaviors
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Detect .git and .githooks directories
$gitDir     = Join-Path -Path $RepoRoot -ChildPath ".git"
$hookSrcDir = Join-Path -Path $RepoRoot -ChildPath ".githooks"
$hookDstDir = Join-Path -Path $gitDir   -ChildPath "hooks"

if (-not (Test-Path -Path $gitDir)) {
    Write-Error "This script must be run from within a cloned Git repository."
    exit 1
}

if (-not (Test-Path -Path $hookSrcDir)) {
    Write-Error "No .githooks directory found in $RepoRoot"
    exit 1
}

Write-Host "Installing Git hooks from '$hookSrcDir' to '$hookDstDir'..."

# copy hooks over
Get-ChildItem -Path $hookSrcDir -File | ForEach-Object {
    $dest = Join-Path -Path $hookDstDir -ChildPath $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Force

    # make executable on non-Windows platforms
    if ($IsLinux -or $IsMacOS) {
        chmod +x $dest 2>$null
    }

    Write-Host "✔ Installed hook: $($_.Name)"
}

Write-Host "`n✅ Git hooks installed successfully."
