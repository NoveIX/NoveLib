# File: NoveLib\Private\Class\NoveLib.LogSetting.ps1

class LogSetting {
    # Class properties (e.g., [string]$LogPath, [bool]$UseMilliseconds, etc.)
    [string]$LogPath
    [string]$LogMinLevel
    [string]$EnableConsoleOutput
    [bool]$UseMilliseconds
    [bool]$UseDotNET

    # Constructor to initialize the log setting object
    LogSetting(
        [string]$LogPath,
        [string]$LogMinLevel,
        [string]$EnableConsoleOutput,
        [bool]$UseMilliseconds,
        [bool]$UseDotNET
    ) {
        $this.LogPath = $LogPath
        $this.LogMinLevel = $LogMinLevel
        $this.EnableConsoleOutput = $EnableConsoleOutput
        $this.UseMilliseconds = $UseMilliseconds
        $this.UseDotNET = $UseDotNET
    }

    # Additional constructors or methods can be added here
}
