# ---
# Author:    Keith Marshall
# Domain:    Private
# Role:      Credentials
# Platform:  Windows (Tested: Windows)
# Edition:   Windows
# PSVersion: 5.1
# ---

function Read-CredentialWindows {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [pscredential] $Credential
    )

    try {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        return $Credential.UserName, [System.String][Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)   
    } finally {
        # zero out $bstr to prevent sensitive data from lingering in memory
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}
