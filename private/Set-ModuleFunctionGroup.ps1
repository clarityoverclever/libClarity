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
The Set-ModuleFunctionGroupfunction enforces a consistent directory structure
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
PS C:\> Set-ModuleFunctionGroup

Analyzes all module scripts, then moves Private functions into the /Private
folder and Public functions into their respective Role folders under the root.

.EXAMPLE
PS C:\> Set-ModuleFunctionGroup -Verbose

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
https://github.com/clarityoverclever/libClarity/blob/main/private/Set-ModuleFunctionGroup.ps1
https://github.com/clarityoverclever/libClarity/blob/main/private/Get-FunctionMap.ps1
#>

function Set-ModuleFunctionGroup {
    param (
        [string] $RootPath    = (Split-Path -Path $PSScriptRoot -Parent),
        [string] $PrivatePath = (Join-Path -Path $RootPath -ChildPath 'private')
    )

    # source function parser
    . (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')

    [hashtable] $functionMap = Get-FunctionMap

    $functionMap.GetEnumerator() | ForEach-Object {
        $name   = $_.Name
        $path   = $_.Value.Path
        $domain = $_.Value.Domain.ToLower()
        $role   = $_.Value.Role.ToLower()

        # skip files missing domain metadata to prevent $null exceptions on $domain
        if (-not $domain) {
            Write-Warning "Function '$name' has no Domain metadata — skipping."
            return
        }

        switch -Regex ($domain) {
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
                [string] $RolePath = Join-Path -Path $RootPath -ChildPath $role

                if ((Split-Path -Path $path -Parent) -ne $RolePath) {
                    try {
                        if (-not (Test-Path -Path $RolePath)) {
                            New-Item -ItemType Directory -Path $RolePath -Force | Out-Null
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
