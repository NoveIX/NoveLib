# File: NoveLib\Private\Class\NoveLib.LogSetting.ps1

class LogSetting {
    # Class properties (e.g., [string]$LogPath, [bool]$UseMilliseconds, etc.)
    [string]$FilePath
    [string]$LogMinLevel
    [string]$LogFormat
    [string]$ConsoleOutput
    [bool]$useMillisecond
    [bool]$useDotNET

    # Constructor to initialize the log setting object
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

    # Additional constructors or methods can be added here
}
