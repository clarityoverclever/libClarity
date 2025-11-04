# ---
# Author:    Keith Marshall
# Domain:    Public
# Role:      Helper
# Platform:  CrossPlatform
# PSVersion: >=7.2
# ---

# Define root path
[string] $RootPath    = (Get-Item -Path $PSScriptRoot).Parent.FullName
[string] $PrivatePath = (Join-Path -Path $RootPath -ChildPath 'Private')

# source function parser
. (Join-Path -Path $PrivatePath -ChildPath 'Get-FunctionMap.ps1')

# scan for public functions and source them
try {
    [object] $groupedByDomain = (Get-FunctionMap).GetEnumerator() | Group-Object { $_.Value.Domain }
    foreach ($domainGroup in $groupedByDomain) {
        if ($domainGroup.Name.ToLower() -eq 'private') {
            foreach ($function in $domainGroup.Group) {
                $name = $function.Key
                $file = $function.Value.Path

                try {
                    . $file
                } catch {
                    Write-Error -Message "Failed to load $($name): $($_.Exception.Message)"
                }
            }
        }

        if ($domainGroup.Name.ToLower()-eq 'public') {
            foreach ($function in $domainGroup.Group) {
                $name = $function.Key
                $file = $function.Value.Path

                try {
                    Write-Host "exporting $name"
                    . $file
                    Export-ModuleMember -Function $name
                } catch {
                    Write-Error -Message "Failed to load $($name): $($_.Exception.Message)"
                }
            }
        }
    }
} catch {
    Write-Error "Module load failed: $($_.Exception.Message)"
}
