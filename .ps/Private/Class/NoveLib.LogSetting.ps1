# File: NoveLib\Private\Class\NoveLib.LogSetting.ps1

class LogSetting {
    # Class properties
    [string]$FilePath
    [string]$LogMinLevel
    [string]$LogFormat
    [string]$ConsoleOutput
    [bool]$useMillisecond
    [bool]$useDotNET

    # Constructor
    LogSetting(
        [string]$FilePath,
        [string]$LogMinLevel,
        [string]$LogFormat,
        [string]$ConsoleOutput,
        [bool]$useMillisecond,
        [bool]$useDotNET
    ) {
        $this.FilePath = $FilePath
        $this.LogMinLevel = $LogMinLevel
        $this.LogFormat = $LogFormat
        $this.ConsoleOutput = $ConsoleOutput
        $this.useMillisecond = $useMillisecond
        $this.useDotNET = $useDotNET
    }
}
