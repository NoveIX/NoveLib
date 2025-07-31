# File: NoveLib\Public\Utility\Invoke-CipherDecrypt.ps1
function Invoke-CipherDecrypt {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$KeyPath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$PWFilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'CipherCredObject', ValueFromPipeline = $true)]
        [PSCustomObject]$CipherObject
    )

    # Resolve path key
    if ($CipherObject) {
        $KeyPath = $CipherObject.KeyPath
        $PWFilePath = $CipherObject.PWFilePath
    }else {
        $KeyPath = Resolve-Path -Path $KeyPath
        $PWFilePath = Resolve-Path -Path $PWFilePath
    }

    # Decript passoword
    try {
        $EncryptedString = Get-Content -Path $PWFilePath -Raw
        $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        $SecurePassword = ConvertTo-SecureString -String $EncryptedString -Key $KeyBytes
    }
    catch {
        throw "Decryption failed. Possibly due to an invalid key or a corrupted password file. $_"
    }

    return $SecurePassword
}