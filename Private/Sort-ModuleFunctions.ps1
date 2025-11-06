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
Sorts and organizes PowerShell module function scripts into their appropriate
locations based on metadata extracted from each file.

.DESCRIPTION
The Sort-ModuleFunctions function enforces a consistent directory structure
within a PowerShell module by analyzing function metadata (Domain and Role)
and automatically relocating function script files to their proper folders.

Functions with a 'Private' domain are moved to the module's /Private directory.
Functions with a 'Public' domain are moved to role-specific folders under the
module root (e.g., /Network, /Security, /Filesystem).

This helps maintain a clear separation between internal and exported functions
while keeping the module layout in sync with each script’s metadata.

.PARAMETER RootPath
Specifies the root directory of the PowerShell module.
Defaults to the parent of the script’s location.

.PARAMETER PrivatePath
Specifies the path to the Private function directory within the module.
Defaults to '<RootPath>\Private'.

.EXAMPLE
PS C:\> Sort-ModuleFunctions

Analyzes all module scripts, then moves Private functions into the /Private
folder and Public functions into their respective Role folders under the root.

.EXAMPLE
PS C:\> Sort-ModuleFunctions -Verbose

Runs the sorter in verbose mode to display detailed information about file
movements, created directories, and detected function metadata.

.INPUTS
None.  
You cannot pipe objects to this function.

.OUTPUTS
None.  
This function performs file system operations and does not return output.

.LINK
Export-ModuleMember
https://github.com/clarityoverclever/libClarity/blob/main/Private/Sort-ModuleFunctions.ps1
https://github.com/clarityoverclever/libClarity/blob/main/Private/Get-FunctionMap.ps1
https://github.com/clarityoverclever/libClarity/blob/main/Private/ConvertTo-TitleCase
#>


function Sort-ModuleFunctions {
    param (
        [string] $RootPath    = $(Get-Item -Path $PsScriptRoot).Parent.FullName,
        [string] $PrivatePath = (Join-Path -Path $RootPath -ChildPath 'Private')
    )

    # source function parser
    . (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')
    . (Join-Path -Path $PrivatePath -ChildPath 'ConvertTo-TitleCase.ps1')

    [hashtable] $functionMap = Get-FunctionMap

    ($functionMap.GetEnumerator()) | ForEach-Object {
        $name   = $_.Name
        $path   = $_.Value.Path
        $domain = $_.Value.Domain
        $role   = $_.Value.Role

        # skip files missing domain metadata to prevent $null exceptions on $domain.ToLower()
        if (-not $domain) {
            Write-Warning "Function '$name' has no Domain metadata — skipping."
            return
        }

        switch -Regex ($domain.ToLower()) {
            'private' { # move private functions to /Private
                if ((Split-Path -Path $path -Parent) -ne $PrivatePath) {
                    try {
                        Move-Item -Path $path -Destination $PrivatePath

                        Write-Verbose -Message "Moved $name to $PrivatePath"
                    } catch {
                        Write-Warning -Message "Could not move private function $name"
                    }
                }
            }
            'public'  { # move Public functions to role named folders
                [string] $RolePath = Join-Path -Path $RootPath -ChildPath (ConvertTo-TitleCase -String $Role)

                if ((Split-Path -Path $path -Parent) -ne $RolePath) {
                    try {
                        if (-not (Test-path -Path $RolePath)) {
                            New-Item -ItemType Directory -Path $RolePath | Out-Null
                        }

                        Move-Item -Path $path -Destination $RolePath

                        Write-Verbose -Message "Moved $name to $RolePath"
                    } catch {
                        Write-Warning -Message "Could not move public function $name"
                    }
                }
            }
        }
    }
}
Sort-ModuleFunctions