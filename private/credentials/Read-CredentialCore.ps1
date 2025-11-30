# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: 7.2
# ---

function Read-CredentialLinux {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [pscredential] $Credential
    )

    # validate the credential object
    if (-not ($Credential -is [System.Management.Automation.PSCredential])) {
        throw "Parameter must be a PSCredential object."
    }
    
    # NetworkCredential unwraps a SecureString consistently across Windows, Linux, macOS
    $plain = [system.String][System.Net.NetworkCredential]::new('', $Credential.Password).Password

    return $Credential.UserName, $plain
}
