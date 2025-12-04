# File: NoveLib\Public\Utility\Invoke-CipherDecrypt.ps1
function Invoke-CipherDecrypt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [System.Object]$KeyPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [System.Object]$FilePath
    )

    # ====================================================[ Validate parameter ]==================================================== #


        try {
            if ($KeyPath -is [System.IO.FileInfo]) { $KeyPath = $KeyPath.FullName }
            else { $KeyPath = (Resolve-Path -Path $KeyPath -ErrorAction Stop).Path }
        }
        catch {
            $sysThrMsg = "Key file not found. $_"
            throw [System.IO.FileNotFoundException]::new($sysThrMsg)
        }

        try {
            if ($FilePath -is [System.IO.FileInfo]) { $FilePath = $FilePath.FullName }
            else { $FilePath = (Resolve-Path -Path $FilePath -ErrorAction Stop).Path }
        }
        catch {
            $sysMsg = "String file not found. $($_.Exception.Message)"
            throw [System.IO.FileNotFoundException]::new($sysMsg)
        }
    

    # =====================================================[ Decript passoword ]==================================================== #

    # Get the key and encrypted string and decrypt in a secure string
    try {
        $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        [string]$EncryptedString = Get-Content -Path $FilePath -Raw
        [securestring]$SecureString = ConvertTo-SecureString -String $EncryptedString -Key $KeyBytes -ErrorAction Stop
    }
    catch {
        $sysThrMsg = "Decryption failed. $($_.Exception.Message)"
        throw [System.Security.Cryptography.CryptographicException]::new($sysThrMsg)
    }

    return $SecureString
}