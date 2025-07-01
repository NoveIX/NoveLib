# File: NoveLib\Private\Function\Write-Log.ps1

function Write-Log {
    [CmdletBinding()]
    param (
        # Log Parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'DONE')]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [LogSetting]$LogSetting,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime
    )

    # ========================================================[ Definition ]======================================================== #

    # Separate LogSetting
    [string]$FilePath = $LogSetting.FilePath
    [string]$LogFormat = $LogSetting.LogFormat
    [string]$ConsoleOutput = $LogSetting.ConsoleOutput
    [bool]$useMilliseconds = $LogSetting.useMilliseconds
    [bool]$useDotNET = $LogSetting.useDotNET

    # =======================================================[ Console mode ]======================================================= #

    # Console output configuration
    [hashtable]$outMap = @{
        "None"      = @{ msg = $false; time = $false }
        "Message"   = @{ msg = $true; time = $false }
        "Timestamp" = @{ msg = $true; time = $true }
    }

    # Return the corresponding mapping if the mode is valid
    [hashtable]$consoleConfig = $outMap[$ConsoleOutput]

    # Prepare time output
    $format = switch ($LogFormat) {
        "Time" { if ($useMilliseconds) { "HH:mm:ss.fff" } else { "HH:mm:ss" } }
        "Datetime" { if ($useMilliseconds) { "yyyy-MM-dd HH:mm:ss.fff" } else { "yyyy-MM-dd HH:mm:ss" } }
    }

    $timeStamp = Get-Date -Format $format

    # ======================================================[ Write console ]======================================================= #

    # Print messages in Console
    if ($consoleConfig.msg -or $Print) {

        # Print Time
        if ($consoleConfig.time -or $PrintTime) { Write-Host "[$timeStamp] " -NoNewline }

        # Retrieves color for level, defaulting to no color
        [string]$color = Write-LogColorMap -Level $Level

        Write-Host "[" -NoNewline
        Write-Host "$Level" -ForegroundColor $color -NoNewline
        Write-Host "]" -NoNewline
        Write-Host " - $Message"
    }

    # ======================================================[ Write log file ]====================================================== #

    # Create file if not exist
    if (-not (Test-Path -Path $FilePath)) { New-Item -Path $FilePath -ItemType File -Force | Out-Null }

    # Log file output format
    [string]$logFormat = "[$timeStamp] [$Level] - $Message"

    # Write log format level and message to the log file, using .NET to enable file sharing
    $fs = $null
    $sw = $null

    try {
        if ($useDotNET) {
            $fs = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
            $sw = New-Object System.IO.StreamWriter($fs, [System.Text.Encoding]::UTF8)
            $sw.WriteLine($logFormat)
            $sw.Flush()
        }

        # Use Powershell Add-Content
        else { Add-Content -Path $FilePath -Value $logFormat }
    }
    catch { Write-Error "Error while writing to log file: $($_.Exception.Message)" }
    finally {
        if ($sw) { $sw.Close() }
        if ($fs) { $fs.Close() }
    }
}