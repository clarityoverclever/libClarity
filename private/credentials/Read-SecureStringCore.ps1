# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: 7.2
# ---

function Read-SecureStringCore {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [securestring] $SecureString
    )

    # NetworkCredential unwraps a SecureString consistently across Windows, Linux, macOS
    return [System.String][System.Net.NetworkCredential]::new('', $SecureString)
}