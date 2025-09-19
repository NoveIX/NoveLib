Import-Module C:\Users\FERRIST1\Source\Repos\NoveLib\NoveLib\NoveLib.psd1 -Force

$Script:LogSetting = New-LogSetting -Path $env:TEMP
Set-LogSetting

Write-LogInfo -Message "ciao"
."C:\Users\FERRIST1\Source\Repos\NoveLib\NoveLib\Public\Logging\Write-LogInfo.ps1"
Write-LogInfo -Message "ciao"
