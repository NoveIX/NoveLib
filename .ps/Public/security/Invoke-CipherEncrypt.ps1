# File: NoveLib\Public\Utility\Invoke-CipherEncrypt.ps1

function Invoke-CipherEncrypt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]$KeyPath,
        [string]$FileName
    )

    # ====================================================[ Validate parameter ]==================================================== #


    if ($KeyPath -is [System.IO.FileInfo]) { $KeyPath = $KeyPath.FullName }
    else { $KeyPath = (Resolve-Path -Path $KeyPath).Path }

    # =====================================================[ Handle Filename ]====================================================== #

    # Resolve path
    if (-not $FileName) { $FileName = "EncryptedText" }
    $basePath = Split-Path -Path $(Resolve-Path -Path $KeyPath) -Parent
    $FilePath = Join-Path -Path $basePath -ChildPath $FileName

    # ===================================================[ Encrypt secure string ]================================================== #

    # Get key byte and encrypt
    try {
        [byte[]]$KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
        Read-Host "Text to encrypt" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -Key $KeyBytes | Out-File -FilePath $FilePath -Encoding UTF8
    }
    catch {
        $sysMsg = "Encryption failed. $($_.Exception.Message)"
        throw [System.Security.Cryptography.CryptographicException]::new($sysMsg)
    }
}