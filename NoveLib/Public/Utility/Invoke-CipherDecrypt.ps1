# File: NoveLib\Public\Utility\Invoke-CipherDecrypt.ps1
function Invoke-CipherDecrypt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$KeyPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$FilePath,

        [Parameter(Mandatory = $true, ParameterSetName = 'CipherObject', ValueFromPipeline = $true)]
        [Cipher]$CipherObject
    )

    # =================================================================================================== #

    #### Handle path

    # Resolve path key
    if ($CipherObject) {
        $KeyPath = $CipherObject.KeyPath
        $FilePath = $CipherObject.FilePath
    }
    else {
        # Handle key path
        try { $KeyPath = Resolve-Path -Path $KeyPath -ErrorAction Stop }
        catch {
            $sysThrMsg = "String file not found. $_"
            throw [System.IO.FileNotFoundException]::new($sysThrMsg)
        }

        # Handle file path
        try { $FilePath = Resolve-Path -Path $FilePath -ErrorAction Stop }
        catch {
            $sysThrMsg = "Key file not found. $_"
            throw [System.IO.FileNotFoundException]::new($sysThrMsg)
        }
    }

    # =================================================================================================== #

    #### Decript passoword

    # Get the key and encrypted string and decrypt in a secure string
    try {
        $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        [string]$EncryptedString = Get-Content -Path $FilePath -Raw
        [securestring]$SecureString = ConvertTo-SecureString -String $EncryptedString -Key $KeyBytes -ErrorAction Stop
    }
    catch {
        $sysThrMsg = "Decryption failed. $_"
        throw [System.Security.Cryptography.CryptographicException]::new($sysThrMsg)
    }

    return $SecureString
}