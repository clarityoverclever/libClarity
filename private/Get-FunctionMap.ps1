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
Metadata must be declared at the top of the file betweem two lines containing only # ---

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/private/Get-FunctionMap.ps1
#>

function Get-FunctionMap {
    param (
        [string] $RootPath = (Split-Path -Path $PSScriptRoot -Parent)
    )

    # enforce strict behaviors
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # define metadata schema for key validation
    [hashtable] $metadataSchema = @{
        author    = @{ required = $false }
        domain    = @{ required = $true }
        role      = @{ required = $true }
        platform  = @{ required = $false }
        edition   = @{ required = $false }
        psversion = @{ required = $false }
    }

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
                $value          = $Matches[2].Trim()

                # values are normalized lowercase and trimmed
                $metadata[$key] = $value
            }
        }

        # test script file for valid metadata structure
        foreach ($key in $metadataSchema.Keys) {
            # test for required keys and stop processing if found
            if ($metadataSchema[$key].required -and -not $metadata.ContainsKey($key)) {
                Write-Warning "[REQUIRED] $file missing required metadata key: $key"
                return
            }

            # test for recommended keys and warn if found
            if (-not $metadataSchema[$key].required -and -not $metadata.ContainsKey($key)) {
                Write-Warning "[RECOMMENDED] $file missing recommended metadata key: $key"
                $metadata[$key] = 'unknown'
            }
        }

        # get function(s) name and skip files where no function is declared
        $names = @(
            $contents | Where-Object { $_ -match '^\s*function\s+\w+' -and ($_ -notmatch '^\s*#') } |
            ForEach-Object { ($_ -replace '.*function\s+([^\s{]+).*', '$1').Trim() }
        )

        # ensure $names even if no functions are found
        if (-not $names) {
            $names = @()
        }

        # add functions to function map
        foreach ($name in $names) {
            if ($metadata) {
                if ($functionMap.ContainsKey($name)) {
                    Write-Warning "Duplicate function '$name' found in $file"
                } else {
                    $functionMap[$name] = @{
                        path      = $file
                        author    = $metadata.author
                        domain    = $metadata.domain.ToLower()
                        role      = $metadata.role.ToLower()
                        platform  = $metadata.platform.ToLower()
                        edition   = $metadata.edition.ToLower()
                        psversion = $metadata.psversion
                    }
                }
            }
        }
    }

    return $functionMap
}
