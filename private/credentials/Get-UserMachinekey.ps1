# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Linux (Tested: Linux)
# Edition:   Linux
# PSVersion: >=7.2
# ---

function Get-UserMachineKey {
    # Collect and compbine identifiers
    [string] $user = $env:USER ?? $env:USERNAME
    [string] $machine = $env:HOSTNAME ?? $env:COMPUTERNAME ?? (& hostname)
    [string] $raw = "$user@$machine"

    # Hash to fixed length (32 bytes for AES)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
    $hash = $sha256.ComputeHash($bytes)

    # Return first 32 bytes as key
    return $hash[0..31]
}
