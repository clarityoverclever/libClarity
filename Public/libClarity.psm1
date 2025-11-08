# ---
# Author:    Keith Marshall
# Domain:    Public
# Role:      Module Loader
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: >=7.2
# ---

# Define root path
[string] $RootPath    = Split-Path -Path $PSScriptRoot -Parent
[string] $PrivatePath = Join-Path -Path $RootPath -ChildPath 'Private'

# source function parser
. (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')

try {
    # categorize functions
    [object] $groupedByDomain = (Get-FunctionMap).GetEnumerator() | Group-Object { $_.Value.Domain }

    foreach ($domainGroup in $groupedByDomain) {
        switch -Regex ($domainGroup.Name) {
        
            'private' { # load private functions
                foreach ($function in $domainGroup.Group) {
                    $name = $function.Key
                    $file = $function.Value.Path

                    try {
                        . $file
                        Write-Verbose "Loaded Private function: $name"
                    } catch {
                        Write-Error -Message "Failed to load $($name): $($_.Exception.Message)" -Category ResourceUnavailable
                    }
                }
            }

            'public' { # export public functions
                foreach ($function in $domainGroup.Group) {
                    $name = $function.Key
                    $file = $function.Value.Path

                    try {
                        . $file
                        Export-ModuleMember -Function $name
                        Write-Verbose "Exported Public function: $name"
                    } catch {
                        Write-Error -Message "Failed to load $($name): $($_.Exception.Message)" -Category ResourceUnavailable

                    }
                }
            }

            default {
                Write-Verbose "Skipped unrecognized domain: $($domainGroup.Name)"
            }
        }
    }
} catch {
    Write-Error "Module load failed: $($_.Exception.Message)"
}
