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
Scans a PowerShell module folder and returns metadata about each function.

.DESCRIPTION
This function recursively scans `.ps1` files in a module directory, extracts function names,
and reads metadata tags from comments. It returns a hashtable
mapping each function to its file path and metadata.

.PARAMETER RootPath
The root path of the module to scan. Defaults to the parent of the current script's location.

.EXAMPLE
Get-FunctionMap -RootPath "C:\MyModule"

.NOTES
If script has no declared functions, the name will default to the file name.
Metadata must be declared at the top of the file betweem two lines containing only # ---

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/Private/Get-FunctionMap.ps1
#>

function Get-FunctionMap {
    param (
        [string] $RootPath = (Get-Item -Path $PsScriptRoot).Parent.FullName
    )

    # enforce strict behaviors
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    [hashtable] $functionMap = @{}

    Get-ChildItem -Path $RootPath -Filter *.ps1 -Recurse | ForEach-Object {
        [hashtable] $metadata    = @{}
        [string]    $file        = $_.FullName
        [string[]]  $contents    = Get-Content -Path $file
        [bool]      $inMetadata  = $false

        foreach ($line in $contents) {
            # toggle in and out of metadata
            if ($line -match '^# ---') {
                $inMetadata = -not $inMetadata
                if (-not $inMetadata) {
                    break
                }
                continue
            }

            # load metadata into a hashtable
            if ($inMetadata -and $line -match '^#\s*(\w+)\s*:\s*(.+)$') {
                $key            = $Matches[1].Trim().ToLower()
                $value          = $Matches[2].Trim().ToLower()
                $metadata[$key] = $value
            }
        }

        # test script file for valid metadata structure
        $requiredKeys = 'Domain','Role','Platform','Edition','PSVersion','Author'
        foreach ($key in $requiredKeys) {
            if (-not $metadata.ContainsKey($key)) {
                Write-Warning "$file missing required metadata key: $key"
                return
            }
        }

        # get function name and skip files where no function is declared
        $name = ($contents | Where-Object {
                $_ -match '^\s*function\s+\w+' -and ($_ -notmatch '^\s*#')
            }) -replace '.*function\s+([^\s{]+).*', '$1'
        
        if (-not $name) {
            return
        }

        if ($metadata) {
            if ($functionMap.ContainsKey($name)) {
                Write-Warning "Duplicate function '$name' found in $file"
            } else {
                $functionMap[$name] = @{
                    Path      = $file
                    Author    = $metadata.Author.Trim()
                    Domain    = $metadata.Domain.Trim()
                    Role      = $metadata.Role.Trim()
                    Platform  = $metadata.Platform.Trim()
                    Edition   = $metadata.Edition.Trim()
                    PSVersion = $metadata.PSVersion.Trim()
                }
            }
        }
    }

    return $functionMap
}
