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
Imports a secure credentials from a local file created by Export-CredntialToFile.

.DESCRIPTION
On Windows, credentials are protected using DPAPI.
On Linux, credentials are stored using local environment variables.

This function automatically detects the operating system and calls the
appropriate private implementation.

.PARAMETER Platform
(Optional) Override automatic OS detection. Valid values: Windows, Linux, MacOS.

.EXAMPLE
Import-CredentialFromFile -Platform Windows
Forces use of the Windows-specific implementation.
#>

function Import-CredentialFromFile {
    [CmdletBinding()]
    param(
        [ValidateSet("Windows", "Linux", "MacOS")]
        [string] $Platform
    )

    if ($Platform) {
        switch ($Platform) {
            "Windows" { return Import-CredentialFromFileWindows }
            "Linux"   { return Import-CredentialFromFileCore }
        }
    } else {
        if ($IsWindows) {
            return Import-CredentialFromFileWindows 
        } elseif ($IsLinux -or $IsMacOS) {
            return Import-CredentialFromFileCore
        } else {
            throw "Unsupported OS: $($_)"
        }
    }
}
