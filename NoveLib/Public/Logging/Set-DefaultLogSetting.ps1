# File: NoveLib\Public\Logging\Set-DefaultLogSetting.ps1

function Set-DefaultLogSetting {
    [CmdletBinding()]
    param (
        # Log Definition
        [string]$Filename,
        [string]$Path,
        [ValidateSet('TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'DONE')]
        [string]$LogMinLevel = "INFO",

        # log User
        [switch]$LogUser,
        [switch]$LogUserSubPath,

        # Insert date in the name
        [ValidateSet('None', 'Date', 'Datetime')]
        [string]$DateLogName = "None",
        [ValidateSet('Time', 'Datetime')]
        [string]$LogFormat = "Time",
        [switch]$UseMillisecond,

        # Print in console
        [ValidateSet("None", "Message", "Timestamp")]
        [string]$ConsoleOutput = "None",

        # use .NET to write in the file
        [bool]$UseDotNET = $true
    )

    # Set Module scope default log setting
    $Script:DefaultLogSetting = New-LogSetting -Filename $Filename -Path $Path -LogMinLevel $LogMinLevel -LogUser:$LogUser `
        -LogUserSubPath:$LogUserSubPath -DateLogName $DateLogName -LogFormat $LogFormat -UseMillisecond:$UseMillisecond `
        -ConsoleOutput $ConsoleOutput -UseDotNET:$UseDotNET

    return $DefaultLogSetting
}