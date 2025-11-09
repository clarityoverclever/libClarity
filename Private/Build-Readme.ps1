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
    Generates a README.md file for a module, listing all functions grouped by domain with metadata.

.DESCRIPTION
    The `Build-Readme` function automatically generates a README.md file for the module, 
    listing all functions defined within the module, grouped by their domain. It also annotates each function 
    with metadata such as role, platform, PowerShell edition, and version. 

    The generated README includes a table of contents with links to each domain section and a table for each domain 
    showing the function's name, role, platform, edition, PSVersion, and a link to its GitHub page.

.PARAMETER RootPath
    The root directory of the module. By default, it is the parent directory of the script being executed.
    This path is used to save the generated `README.md` file.

.PARAMETER PrivatePath
    The path to the `Private` folder within the module. By default, it is set to a subdirectory named `Private`
    inside the `RootPath`. This is where the `Get-FunctionMap.ps1` script is located, which is used to retrieve 
    metadata about the module's functions.

.PARAMETER RepoRoot
    The root URL of the GitHub repository. If provided, this is used to generate the links to each function's 
    script on GitHub. If left empty, it will be omitted from the table.

.EXAMPLE
    Build-Readme -RootPath 'C:\Modules\MyModule' -PrivatePath 'C:\Modules\MyModule\Private' -RepoRoot 'https://github.com/MyUser/MyModule'
    
    This example generates the `README.md` file for the `MyModule` located at 'C:\Modules\MyModule', 
    using the metadata and function mapping from the `Private` folder, and includes links to the GitHub repository.

.EXAMPLE
    Build-Readme
    
    This example uses the default values for `RootPath` and `PrivatePath` and generates the `README.md`
    in the module's root directory, based on the function map located in the `Private` folder.

.NOTES
    Author: Keith Marshall
    Version: 1.0.0
    Platform: CrossPlatform (Tested on Linux)
    PSVersion: >=7.2
    This function assumes the existence of a `Get-FunctionMap.ps1` script in the `Private` folder, which contains 
    the function metadata required to generate the README.

.LINK
    https://github.com/clarityoverclever/libClarity/blob/main/Private/Build-Readme.ps1
#>

function Build-Readme {
    param (
        [string] $RootPath    = (Split-Path -Path $PSScriptRoot -Parent),
        [string] $PrivatePath = (Join-Path -Path $RootPath -ChildPath 'Private'),
        [string] $RepoRoot    = 'https://github.com/clarityoverclever/libClarity/blob/main'
    )

    # enforce strict behaviors
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # source function parser
    . (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')

    $markdown  = @()
    $markdown += "Companion function library for https://clarityoverclever.github.io/`n"
    $markdown += "# Module Manifest`n"
    $markdown += "This document lists all functions in the module, grouped by domain and annotated with metadata.`n"
    $markdown += "`n"
    $markdown += "## Table of Contents`n"

    [object] $groupedByDomain = (Get-FunctionMap).GetEnumerator() | Group-Object { $_.Value.Domain }

    foreach ($domainGroup in $groupedByDomain) {
        $domain    = $domainGroup.Name
        $markdown += "- [$domain](#$($domain))`n"
    }

    $markdown += "`n"

    foreach ($domainGroup in $groupedByDomain) {
        $domain = $domainGroup.Name
        $markdown += "## $domain`n"
        $markdown += "| Function | Role | Platform | Edition | PSVersion | Link |"
        $markdown += "|:---------|:-----|:---------|:--------|:----------|:-----|"

        foreach ($function in $($domainGroup.Group) | Sort-Object Key) {
            $info          = $function.Value
            $functionPath  = (Resolve-Path -Relative $info.Path -RelativeBasePath $RootPath) -replace '^[.\\\/]+', '' -replace '\\', '/'
            $githubLink    = $RepoRoot, $functionPath -join '/'
            $markdown     += "| $($function.Key) | $($info.Role) | $($info.Platform) | $($info.Edition) | $($info.PSVersion) | [$($function.Key).ps1]($githubLink) |"
        }

        $markdown += "`n"
    }

    $markdown -join "`n" | Set-Content -Path (Join-Path -Path $RootPath -ChildPath README.md)
}
Build-Readme