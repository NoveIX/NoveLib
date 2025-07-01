# File: NoveLib\Private\Function\Write-Log.ps1

function Write-Log {
    [CmdletBinding()]
    param (
        # Log Parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$LogSetting,

        # Force console print
        [ValidateSet("None", "MessageOnly", "MessageAndTimestamp")]
        [string]$ForceConsoleOutput = "None"
    )

    # Definition
    [string]$logPath = $LogSetting.FilePath
    [string]$logMinLevel = $LogSetting.LogMinLevel
    [string]$enableConsoleOutput = $LogSetting.EnableConsoleOutput
    [bool]$useMilliseconds = $LogSetting.UseMilliseconds
    [bool]$useDotNET = $LogSetting.UseDotNET

    # Validate Level Log definition
    $levelOrder = @("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")
    $currentIndex = $levelOrder.IndexOf($Level)
    $minIndex = $levelOrder.IndexOf($logMinLevel)

    # Skip this log if its level is below the minimum
    if ($currentIndex -lt $minIndex) {
        return
    }



    # Console output configuration recovery
    $settingMap = Get-ConsoleOutputMap -ConsoleOutputMode $enableConsoleOutput
    $forceMap = Get-ConsoleOutputMap -ConsoleOutputMode $ForceConsoleOutput

    # Final values with OR logic (config + override)
    $ConfirmPrint = $settingMap.Print -or $forceMap.Print
    $ConfirmPrintTime = $settingMap.PrintTime -or $forceMap.PrintTime



    # Prepare log message with timestamp (full date and time)
    if ($useMilliseconds) {
        $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    }
    else {
        $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    # Log output format
    $logFormat = "[$timeStamp] [$Level]"

    if (-not [string]::IsNullOrWhiteSpace($Message)) {
        $logFormat += " - $Message"
    }

    # Print messages in Console
    if ($ConfirmPrint) {
        if ($ConfirmPrintTime) {
            Write-Host "[$timeStamp] " -NoNewline
        }

        # Retrieves color for level, defaulting to no color
        $color = Get-ColorLogMap -Level $Level

        Write-Host "[" -NoNewline
        Write-Host "$Level" -ForegroundColor $color -NoNewline
        Write-Host "]" -NoNewline

        if (-not [string]::IsNullOrWhiteSpace($Message)) {
            Write-Host " - $Message"
        }
    }



    # Writes and adds the message to the log file using .NET to enable file sharing
    $fs = $null
    $sw = $null

    try {
        if ($useDotNET) {
            $fs = [System.IO.File]::Open($logPath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
            $sw = New-Object System.IO.StreamWriter($fs)
            $sw.WriteLine($logFormat)
            $sw.Flush()
        }
        else {
            Add-Content -Path $logPath -Value $logFormat
        }
    }
    catch {
        Write-Error "Error while writing to log file: $_"
    }
    finally {
        if ($fs) {
            $fs.Close()
        }
        if ($sw) {
            $sw.Close()
        }
    }
}