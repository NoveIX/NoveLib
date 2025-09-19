function Set-DefaultLogSetting {
    param(
        [string]$Path = $env:TEMP
    )
    $Script:LogSetting = New-LogSetting -Path $Path
}