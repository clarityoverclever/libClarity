# ---
# Author:    Keith Marshall
# Domain:    Public
# Role:      Logging
# Platform:  CrossPlatform (Tested: Linux)
# Edition:   Core
# PSVersion: >=7.2
# ---

<#
.SYNOPSIS
Writes a timestamped log entry to a specified file, optionally formatted as JSON.

.DESCRIPTION
The Write-Log function generates a structured log entry with a timestamp and log level, 
then writes it to a file. It supports plain text or JSON output formats and helps 
standardize logging across automation scripts.

.PARAMETER LogLevel
Specifies the severity level of the log entry. Valid options are INFO, WARN, ERROR, and DEBUG.
Defaults to INFO.

.PARAMETER Message
The content of the log entry. This should be a descriptive string about the event or status.

.PARAMETER Path
The full file path where the log entry will be written. If the file does not exist, it will be created.

.PARAMETER ToJson
Switch to output the log entry in JSON format. If specified, the log will be serialized and written as JSON.

.EXAMPLE
Write-Log -Message "Process started" -Path "C:\Logs\automation.log"

Writes a plain text log entry with default INFO level to the specified file.

.EXAMPLE
Write-Log -Message "Connection failed" -LogLevel ERROR -Path "C:\Logs\automation.log" -ToJson

Writes a JSON-formatted log entry with ERROR level to the specified file.

.LINK
https://github.com/clarityoverclever/libClarity/blob/main/Logging/Write-Log.ps1
https://clarityoverclever.github.io/posts/logging-how-automations-communicate/
#>


function Write-Log {
    param (
        [ValidateSet("INFO","WARN","ERROR","DEBUG")]
        [string] $LogLevel = 'INFO',

        [string] $Message,
        [string] $Path,
        [switch] $ToJson
    )
    
    [string] $time = Get-Date -Format yyyy-MM-ddTHH:mm:ss # ISO 8601 format

    if ($ToJson) {
        $logObject = [PSCustomObject]@{
            Time     = $time
            LogLevel = $LogLevel
            Message  = $Message
        }
        $json = $logObject | ConvertTo-Json -Depth 3
        $json | Out-File -Path $Path -Encoding UTF8 -Append
        return
    }

    Write-Output -InputObject "$time :: [$LogLevel] :: $Message" | Out-File -Path $Path -Encoding UTF8 -Append
}
