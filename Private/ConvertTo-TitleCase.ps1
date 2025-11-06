# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Strings
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: >=7.2
# ---

<#
.SYNOPSIS
Converts a string into Title Case

.DESCRIPTION
This function returns a supplied string in Title Case (capitalizes the first character)

.PARAMETER String
a string to be converted into Title Case

.EXAMPLE
ConvertTo-TitleCase -String "hello"

output: Hello

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/Private/ConvertTo-TitleCase.ps1
#>

function ConvertTo-TitleCase ([string] $String) {
    return ($String -replace '^(.)', { $_.Value.ToUpper() })
}