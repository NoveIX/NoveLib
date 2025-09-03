# File: NoveLib\Private\Function\Write-Log.ps1

function Write-Log {
    [CmdletBinding()]
    param (
        # Log Parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [LogSetting]$LogSetting,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        #Function
        [string]$FunctionName,
        [int]$ScriptLine
    )

    # Retrive LogSetting
    if (-not $LogSetting) {
        [LogSetting]$LogSetting = $Script:LogSetting

        if (-not $LogSetting) {
            $msg = "$FunctionName line $ScriptLine error: LogSetting is not defined as a script variable. " +
            "Unable to use the Write-Log function"
            throw [System.InvalidOperationException]::new($msg)
            Write-Host "Press a key to continue"
            Read-Host
        }
    }

    if ($Print -and $PrintTime) {
        [string]$msg = "$FunctionName line ${LineNumber}: 'PrintTime' is equivalent to 'Print' but includes a timestamp. " +
        "It is recommended to use only one to avoid redundancy."

        Write-LogHost -Message $msg -Level DEBUG
        $Print = $false
    }

    # =================================================================================================== #

    #### Definition

    # Definition
    [string]$FilePath = $LogSetting.FilePath
    [string]$LogMinLevel = $LogSetting.LogMinLevel
    [string]$ConsoleOutputMode = $LogSetting.ConsoleOutputMode
    [bool]$useMilliseconds = $LogSetting.useMilliseconds
    [bool]$useDotNET = $LogSetting.useDotNET

    # =================================================================================================== #

    #### Validate parameter

    # Validate Level Log definition
    [array]$levelOrder = @("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")
    [int]$curIndex = $levelOrder.IndexOf($Level)
    [int]$minIndex = $levelOrder.IndexOf($LogMinLevel)

    # Skip this log if its level is below the minimum
    if ($curIndex -lt $minIndex) { return }

    # Console output configuration
    [hashtable]$outMap = @{
        "None"      = @{ msg = $false; time = $false }
        "Message"   = @{ msg = $true; time = $false }
        "Timestamp" = @{ msg = $true; time = $true }
    }

    # Return the corresponding mapping if the mode is valid
    $clsConfig = $outMap[$ConsoleOutputMode]

    # Prepare log message with timestamp (full date and time)
    if ($useMilliseconds) { $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff" }
    else { $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" }

    # =================================================================================================== #

    #### Write console

    # Print messages in Console
    if ($clsConfig.msg -or $Print) {

        # Print Time
        if ($clsConfig.time -or $PrintTime) { Write-Host "[$timeStamp] " -NoNewline }

        # Retrieves color for level, defaulting to no color
        $color = Write-LogColorMap -Level $Level

        Write-Host "[" -NoNewline
        Write-Host "$Level" -ForegroundColor $color -NoNewline
        Write-Host "]" -NoNewline
        Write-Host " - $Message"
    }

    # =================================================================================================== #

    #### Write log file

    # Log file output format
    $logFormat = "[$timeStamp] [$Level] - $Message"

    # Writes and adds the message to the log file using .NET to enable file sharing
    $fs = $null
    $sw = $null

    try {
        if ($useDotNET) {
            $fs = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
            $sw = New-Object System.IO.StreamWriter($fs)
            $sw.WriteLine($logFormat)
            $sw.Flush()
        }
        else { Add-Content -Path $FilePath -Value $logFormat }
    }
    catch { Write-Error "Error while writing to log file: $_" }
    finally {
    if ($sw) { $sw.Close() }
    if ($fs) { $fs.Close() }
    }
}