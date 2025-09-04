# File: NoveLib\Public\Utility\Invoke-Cipher.ps1

function Invoke-Cipher {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$KeyName,
        [ValidateSet("key", "bin")]
        [string]$Extension,

        [switch]$WriteClearString,
        [switch]$OpenInExplorer
    )

    # Invoke function to encript string
    $opStatus = New-CipherKey -Path $Path | Invoke-CipherEncrypt

    # Show string in console
    if ($WriteClearString) { $opStatus | Invoke-CipherDecrypt | Invoke-DecryptSecureString }

    if ($OpenInExplorer) { explorer.exe -Path $Path }
}