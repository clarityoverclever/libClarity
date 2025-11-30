# ---
# Author:    Keith Marshall
# Domain:    Public
# Role:      Module Loader
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: >=7.2
# ---

# enforce strict behaviors in the module
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Define root path
[string] $RootPath    = Split-Path -Path $PSScriptRoot -Parent
[string] $PrivatePath = Join-Path -Path $RootPath -ChildPath 'private'

# source function parser
. (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')

try {
    # load all private functions first to ensure that helpers are available when public functons load
    foreach ($function in (Get-FunctionMap).GetEnumerator() | Where-Object { $_.Value.Domain -eq 'private' }) {
        $name = $function.Key
        $file = $function.Value.Path

        try {
            . $file
            Write-Verbose "Loaded Private function: $name"
        } catch {
            Write-Error -Message "Failed to load $($name): $($_.Exception.Message)" -Category ResourceUnavailable
        }
    }
   
    # export public functions    
    foreach ($function in (Get-FunctionMap).GetEnumerator() | Where-Object { $_.Value.Domain -eq 'public' }) {
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
} catch {
    Write-Error "Module load failed: $($_.Exception.Message)"
}
