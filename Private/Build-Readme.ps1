# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Helper
# Platform:  CrossPlatform
# PSVersion: >=7.2
# ---

function Build-Readme {
    param (
        [string] $RootPath = $(Get-Item -Path $PsScriptRoot).Parent.FullName,
        [string] $RepoRoot = 'https://github.com/clarityoverclever/libClarity/blob/main'
    )

    $groupedByDomain = (Get-FunctionMap).GetEnumerator() | Group-Object { $_.Value.Domain }

    $markdown  = @()
    $markdown += "# Module Manifest`n"
    $markdown += "This document lists all functions in the module, grouped by domain and annotated with metadata.`n"
    $markdown += "Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n`n"
    $markdown += "## Table of Contents`n"

    foreach ($domainGroup in $groupedByDomain) {
        $domain = $domainGroup.Name
        $markdown += "- [$domain](#$($domain.ToLower()))`n"
    }

    $markdown += "`n"

    foreach ($domainGroup in $groupedByDomain) {
        $domain = $domainGroup.Name
        $markdown += "## $domain`n"
        $markdown += "| Function | Role | Platform | PSVersion | Link |"
        $markdown += "|:---------|:-----|:---------|:----------|:-----|"

        foreach ($function in $($domainGroup.Group) | Sort-Object Key) {
            $info = $function.Value
            $functionPath = (Resolve-Path -Relative $info.Path) -replace '^[.\\\/]+', '' -replace '\\', '/'
            $githubLink   = ($RepoRoot, $functionPath -join '/')
            $markdown += "| $($function.Key) | $($info.Role) | $($info.Platform) | $($info.PSVersion) | [$($function.Key).ps1]($githubLink) |"
        }

        $markdown += "`n"
    }

    $markdown -join "`n" | Set-Content -Path (Join-Path -Path $RootPath -ChildPath README.md)
}
