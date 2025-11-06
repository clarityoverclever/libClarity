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
Automatically rebuilds README.md before pushing code.

.DESCRIPTION
Compares the current README.md hash before and after running Build-Readme.ps1.
If changes are detected, the updated README.md is staged and optionally
amended into the last commit.

Intended for use in a pre-push hook.

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/Private/Update-ReadmeOnPush.ps1
#>

function Update-ReadmeOnPush {
    param (
        [string] $RootPath    = (Get-Item -Path $PsScriptRoot).Parent.FullName,
        [string] $PrivatePath = (Join-Path -Path $RootPath -ChildPath 'Private')
    )

    # enforce strict behaviors
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # source helpers
    . (Join-Path -Path $PrivatePath -ChildPath 'Build-Readme.ps1')

    [string] $readmePath  = (Join-Path -Path $RootPath -ChildPath 'README.md')
    [string] $readmeHash  = (Get-FileHash -Algorithm MD5 -Path $readmePath).Hash

    & Build-Readme

    [string] $updatedHash = (Get-FileHash -Algorithm MD5 -Path $readmePath).Hash

    if ($readmeHash -ne $updatedHash) {
        [string] $lastCommitMessage = git log -1 --pretty=%B
        [string] $newCommitMessage  = "$lastCommitMessage`n`nIncludes auto-updated README.md"

        Write-Host "README.md has been updated automatically; staging changes..."
        git add $readmePath

        Write-Host "squashing the README update into last commit"
        git commit --amend -m $newCommitMessage
    } else {
        Write-Host "README unchanged since last commit"
    }

    Write-Host "exiting pre-push checks"
}

Update-ReadmeOnPush
