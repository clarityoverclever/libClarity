# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Linux (Tested: Linux)
# Edition:   Linux
# PSVersion: >=7.2
# ---

function Import-CredentialFromFileCore {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    # wihtout DPAPI PS can't deserialize Clixml to a credential directly
    $object = Get-Content -Path $Path -Raw | ConvertFrom-Json

    if (-not $object.UserName -or -not $object.Password) {
        throw "File at '$Path' does not contain expected credential fields."
    }

    # extract PsCredential fields from the imported hashtable
    $user      = $object.UserName
    $encrypted = $object.Password

    # calculate the machine key
    [byte[]] $key = Get-UserMachineKey

    # build a SecureString for the credential password
    [securestring] $secureString = ConvertTo-SecureString $encrypted -Key $key

    return New-Object System.Management.Automation.PSCredential($user, $secureString)
}
