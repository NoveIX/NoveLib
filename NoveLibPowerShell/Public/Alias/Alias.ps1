# File: NoveLib\Public\Alias\Alias.ps1

$aliases = @{
    ByteToSize          = "Convert-ByteToSize"
    ByteToSizeString    = "Convert-ByteToSizeString"
    CIDRToMask          = "Convert-CIDRToMask"
    MaskToCIDR          = "Convert-MaskToCIDR"
    PathToUNC           = "Convert-PathToUNC"
    StringToMacAddress  = "Convert-StringToMacAddress"
    NonAsciiCharacters  = "Find-NonAsciiCharacters"
    ComputerUptime      = "Get-ComputerUptime"
    CipherDecrypt       = "Invoke-CipherDecrypt"
    CipherEncrypt       = "Invoke-CipherEncrypt"
    DecryptSecureString = "Invoke-DecryptSecureString"
    CipherKey           = "New-CipherKey"
    LogSetting          = "New-LogSetting"
    DefaultLogSetting   = "Set-DefaultLogSetting"
    LogDebug            = "Write-LogDebug"
    LogDone             = "Write-LogDone"
    LogError            = "Write-LogError"
    LogFatal            = "Write-LogFatal"
    LogHost             = "Write-LogHost"
    LogInfo             = "Write-LogInfo"
    LogTrace            = "Write-LogTrace"
    LogWarn             = "Write-LogWarn"
    NoveAsciiArt        = "Write-NoveAsciiArt"
}

foreach ($alias in $aliases.Keys) {
    Set-Alias -Name $alias -Value $aliases[$alias]
}