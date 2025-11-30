# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Windows (Tested: Windows)
# Edition:   Windows
# PSVersion: 5.1
# ---

function Export-CredentialToFileWindows {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $KeyPath,

        [Parameter(Position = 1, Mandatory = $true)]
        [string] $KeyName
    )

    [pscredential] $credential = Get-Credential

    $credential | Export-Clixml $(Join-Path -Path $KeyPath -ChildPath $KeyName)
}
