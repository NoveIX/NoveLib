# File: NoveLib\Public\Wrapper\WinUptime.ps1

function WinUptime {
    Get-ComputerUptime -Mode Unix
}
