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
Creates a local file to store secure credentials in a cross-platform way.

.DESCRIPTION
On Windows, credentials are protected using DPAPI.
On Linux, credentials are stored using local environment variables.

This function automatically detects the operating system and calls the
appropriate private implementation.

.PARAMETER Platform
(Optional) Override automatic OS detection. Valid values: Windows, Linux, MacOS.

.EXAMPLE
New-CredentialToFile
Stores credentials using the default method for the current OS.

.EXAMPLE
New-CredentialToFile -Platform Windows
Forces use of the Windows-specific implementation.
#>

function Read-Credential {
    [CmdletBinding()]
    param(
        [ValidateSet("Windows", "Linux", "MacOS")]
        [string] $Platform
    )

    if ($Platform) {
        switch ($Platform) {
            "Windows" { return Read-CredentialWindows }
            "Linux"   { return Read-CredentialCore }
        }
    } else {
        if ($IsWindows) {
            return Read-CredentialWindows 
        } elseif ($IsLinux -or $IsMacOS) {
            return Read-CredentialCore
        } else {
            throw "Unsupported OS: $($_)"
        }
    }
}
