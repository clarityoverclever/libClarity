# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Windows (Tested: Windows)
# Edition:   Windows
# PSVersion: 5.1
# ---

function Import-CredentialFromFileWindows {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $Path
    )

    # verify the file exist
    if (-not (Test-Path -Path $Path)) {
         throw "Supplied path cannot be found: $Path"
    }

    [pscredential] $credential = Import-Clixml -Path $Path

    # validate the credential object
    if (-not ($Credential -is [System.Management.Automation.PSCredential])) {
        throw "Parameter must be a PSCredential object."
    }

    return $credential
}
