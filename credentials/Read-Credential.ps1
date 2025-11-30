# ---
# Author:    Keith Marshall
# Domain:    Public
# Role:      credentials
# Platform:  crossplatform (Tested: Linux)
# Edition:   core
# PSVersion: 5.1
# ---

<#
.SYNOPSIS
platform agnostic method to decrypt and read a SecureString from a credential object

.DESCRIPTION
On Windows, credentials are protected using DPAPI.
On Linux, credentials are stored using local environment variables.

This function automatically detects the operating system and calls the
appropriate private implementation.

.PARAMETER Platform
(Optional) Override automatic OS detection. Valid values: Windows, Linux, MacOS.

.EXAMPLE
Read-Credential
Stores credentials using the default method for the current OS.

.EXAMPLE
New-CredentialToFile -Platform Windows
Forces use of the Windows-specific implementation.
#>

function Read-Credential {
    [CmdletBinding()]
    param(
        [ValidateSet("Windows", "Linux", "MacOS")]
        [string] $Platform,

        [pscredential] $Credential
    )

    if ($Platform) {
        switch ($Platform) {
            "Windows" { return Read-CredentialWindows -Credential $Credential }
            "Linux"   { return Read-CredentialCore -Credential $Credential }
        }
    } else {
        if ($IsWindows) {
            return Read-CredentialWindows 
        } elseif ($IsLinux -or $IsMacOS) {
            return Read-CredentialCore -Credential $Credential 
        } else {
            throw "Unsupported OS: $($_)"
        }
    }
}
