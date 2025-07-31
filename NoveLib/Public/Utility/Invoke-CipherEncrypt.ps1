# File: NoveLib\Public\Utility\Invoke-CipherEncrypt.ps1

function Invoke-CipherEncrypt {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$KeyPath,
        [string]$PWFilePath
    )

    # Validate
    if (-not (Test-Path -Path $KeyPath -PathType Leaf)) {
        throw "Encryption key file not found: $KeyPath"
    }

    if ([string]::IsNullOrWhiteSpace($PWFilePath)) {
        $PWFileName = "Password"
    }

    # Resolve path Key and Passowrd File
    $KeyPath = Resolve-Path -Path $KeyPath
    $credDir = Split-Path -Path $KeyPath -Parent
    $PWFilePath = Join-Path -Path $credDir -ChildPath $PWFileName

    # Validate key length
    $KeyBytes = [System.IO.File]::ReadAllBytes($KeyPath)
    if ($KeyBytes.Length -notin 32) {
        throw "AES key must be 32 bytes in length. Found $($KeyBytes.Length)."
    }

    try {
        Read-Host "Password" |
        ConvertTo-SecureString -AsPlainText -Force |
        ConvertFrom-SecureString -Key $KeyBytes |
        Out-File -FilePath $PWFilePath -Encoding UTF8
    }
    catch {
        throw "Encryption error: $_"
    }
}