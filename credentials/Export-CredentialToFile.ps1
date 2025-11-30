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
Export-CredentialToFile
Stores credentials using the default method for the current OS.

.EXAMPLE
Export-CredentialToFile -Platform Windows
Forces use of the Windows-specific implementation.
#>

function Export-CredentialToFile {
    [CmdletBinding()]
    param(
        [ValidateSet("Windows", "Linux", "MacOS")]
        [string] $Platform
    )

    if ($Platform) {
        switch ($Platform) {
            "Windows" { return Export-CredentialToFileWindows }
            "Linux"   { return Export-CredentialToFileCore }
        }
    } else {
        if ($IsWindows) {
            return Export-CredentialToFileWindows 
        } elseif ($IsLinux -or $IsMacOS) {
            return Export-CredentialToFileCore
        } else {
            throw "Unsupported OS: $($_)"
        }
    }
}
