# File: NoveLib\Public\Utility\Invoke-CipherEncrypt.ps1

function Invoke-CipherEncrypt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$KeyPath,
        [string]$FileName,

        [switch]$OutNull
    )

    # =================================================================================================== #

    #### Validate Pipeline

    if ($MyInvocation.ExpectingInput -and $OutNull) {
        Write-Warning "Warning: -OutNull cannot be used when receiving input from the pipeline. Ignoring -OutNull to allow pipeline processing."
        $OutNull = $false
    }

    # =================================================================================================== #

    #### Validate Parameter

    # Key path
    try { Test-Path -Path $KeyPath -PathType Leaf -ErrorAction Stop | Out-Null }
    catch {
        $sysThrMsg = "Key file not found. $_"
        throw [System.IO.FileNotFoundException]::new($sysThrMsg)
    }

    # =================================================================================================== #

    #### Handle file name

    # Resolve path
    if (-not $FileName) { $FileName = "EncryptedText" }
    $basePath = Split-Path -Path $(Resolve-Path -Path $KeyPath) -Parent
    $FilePath = Join-Path -Path $basePath -ChildPath $FileName

    # =================================================================================================== #

    #### Encrypt secure string

    # Get key byte and encrypt
    try {
        [byte[]]$KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        Read-Host "Text to encrypt" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -Key $KeyBytes | Out-File -FilePath $FilePath -Encoding UTF8
    }
    catch {
        $sysThrMsg = "Encryption failed. $_"
        throw [System.Security.Cryptography.CryptographicException]::new($sysThrMsg)
    }

    # Silence function output
    if ($OutNull) { return }

    $CipherObject = [Cipher]::new(
        $KeyPath,
        $FilePath
    )

    return $CipherObject
}