# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Linux (Tested: Linux)
# Edition:   Linux
# PSVersion: >=7.2
# ---

function Export-CredentialToFileCore {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $KeyPath,

        [Parameter(Position = 1, Mandatory = $true)]
        [string] $KeyName
    )

    [pscredential] $credential = Get-Credential
    [byte[]]       $key        = Get-UserMachineKey

    [string]       $secureText = ConvertFrom-SecureString -SecureString $credential.Password -Key $key

    $object = [PSCustomObject]@{
        UserName = $credential.UserName
        Password = $secureText
    }

    $fullpath = Join-Path -Path $KeyPath -ChildPath $KeyName
    $object | ConvertTo-Json | Set-Content -Path $fullpath -Encoding UTF8
}
