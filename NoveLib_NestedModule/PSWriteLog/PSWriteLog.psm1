#region LogSetting
function New-LogSetting {
    [CmdletBinding()]
    param (
        # Log Definition
        [string]$Filename,
        [string]$Extension,
        [string]$Path,
        [string]$Temp,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$LogMinLevel = "INFO",

        # log User
        [switch]$LogUser,
        [switch]$LogUserDir,

        # Insert date in the name
        [switch]$DateInLogFile,
        [switch]$UseRecentLogFile,
        [int]$RecentLogFileDelayMinute = 30,
        [switch]$UseMilliseconds,

        # Print in console
        [switch]$ConsolePrint,
        [switch]$ConsolePrintTime,

        # use .NET to write in the file
        [bool]$UseDotNET = $true
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Begin - Parameter validation
    if ($UseRecentLogFile -and -not $DateInLogFile) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'UseRecentLogFile' requires 'DateInLogFile'."
    }

    if (($RecentLogFileDelayMinute -ne 30) -and -not $UseRecentLogFile) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'RecentLogFileDelayMinute' requires 'UseRecentLogFile'."
    }

    if ($ConsolePrint -and $ConsolePrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'ConsolePrintTime' includes the effects of 'ConsolePrint' and also adds the timestamp to the output. Use one of them."
    }



    # Retrieve the current user name
    $userName = $env:USERNAME

    # Handle Log Path
    if (-not $Path) {
        $Path = if (-not $MyInvocation.ScriptName) {
            Join-Path -Path $PWD -ChildPath "Log"
        }
        else {
            Join-Path -Path $PSScriptRoot -ChildPath "Log"
        }
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        $fullPath = Join-Path -Path $PWD -ChildPath $Path
        $Path = (Resolve-Path -Path $fullPath).Path
    }

    # Handle Temp Path
    if (-not $Temp) {
        $Temp = Join-Path -Path $Path -ChildPath "Temp"
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Temp))) {
        $fullPath = Join-Path -Path $PWD -ChildPath $Temp
        $Temp = (Resolve-Path -Path $fullPath).Path
    }

    # Ensure log directory exists
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    # Ensure temp directory exists (only if recent log file is used)
    if ($UseRecentLogFile -and -not (Test-Path $Temp)) {
        New-Item -ItemType Directory -Path $Temp -Force | Out-Null
    }

    # Optional: create a subdirectory based on current user
    if ($LogUserDir) {
        $logUserPath = Join-Path -Path $Path -ChildPath $userName
        if (-not (Test-Path -Path $logUserPath)) {
            New-Item -ItemType Directory -Path $logUserPath -Force | Out-Null
        }
    }

    # Define default log name if missing
    if (-not $Filename) {
        $scriptName = $MyInvocation.MyCommand.Path
        $Filename = if ($scriptName) {
            [System.IO.Path]::GetFileNameWithoutExtension($scriptName)
        }
        else {
            "Log"
        }
    }

    # Define default log extension if missing
    if (-not $Extension) {
        $Extension = "log"
    }
    if ($Extension.StartsWith(".")) {
        $Extension = $Extension.TrimStart(".")
    }



    # Start dialing the filename
    $file = $Filename

    # Add username if required
    if ($LogUser) {
        $file += "_$userName"
    }

    # Date management in file name
    if ($DateInLogFile) {
        $currentDate = Get-Date -Format "yyyy-MM-dd_HH-mm"

        # Keeps the same file if started within $RecentLogFileDelayMinute
        if ($UseRecentLogFile) {
            $dateTempFile = Join-Path -Path $Temp -ChildPath "Datetemp.tmp"
            $writeDate = $true

            # Reads the date from the file
            if (Test-Path $dateTempFile) {
                $fileCurrentDate = Get-Content $dateTempFile

                $fileDateTime = [DateTime]::ParseExact($fileCurrentDate, "yyyy-MM-dd_HH-mm", $null)
                $currentDateTime = [DateTime]::ParseExact($currentDate, "yyyy-MM-dd_HH-mm", $null)

                if ($fileDateTime.AddMinutes($RecentLogFileDelayMinute) -ge $currentDateTime) {
                    $currentDate = $fileCurrentDate
                    $writeDate = $false
                }
                else {
                    Remove-Item $dateTempFile -Force
                }
            }
            if ($writeDate) {
                $currentDate | Out-File -FilePath $dateTempFile -Encoding UTF8
            }
        }

        $file += "_$currentDate"
    }

    # Add extension to file
    $file += ".$Extension"

    # Construct the full path to the file
    if ($LogUserDir) {
        $logPath = Join-Path -Path $logUserPath -ChildPath $file
    }
    else {
        $logPath = Join-Path -Path $Path -ChildPath $file
    }



    # Create and return the configuration object
    $logSettingObject = [PSCustomObject]@{
        LogPath          = $logPath
        LogMinLevel      = $LogMinLevel
        ConsolePrint     = $ConsolePrint
        ConsolePrintTime = $ConsolePrintTime
        UseMilliseconds  = $UseMilliseconds
        UseDotNET        = $UseDotNET
    }

    return $logSettingObject
}
#endregion

# ================================================================================================================================ #

#region Log
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
        [switch]$Print,
        [switch]$PrintTime,

        # Redundant parameter warning
        [Parameter(Mandatory = $true)]
        [string]$FunctionName,
        [Parameter(Mandatory = $true)]
        [int]$LineNumber
    )

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }



    # Definition
    [string]$logPath = $LogSetting.LogPath
    [string]$logMinLevel = $LogSetting.LogMinLevel
    [bool]$consolePrint = $LogSetting.ConsolePrint
    [bool]$consolePrintTime = $LogSetting.ConsolePrintTime
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

    # Determines whether to print or not
    $shouldPrint = $Print -or $PrintTime -or $consolePrint -or $consolePrintTime
    $shouldPrintTime = $PrintTime -or $consolePrintTime

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
    if ($shouldPrint) {

        if ($shouldPrintTime) {
            Write-Host "[$timeStamp] " -NoNewline
        }

        # Map colors to log levels
        $colorMap = @{
            TRACE = 'DarkGray'
            DEBUG = 'Gray'
            INFO  = 'DarkCyan'
            WARN  = 'Yellow'
            FAIL  = 'Red'
            DONE  = 'Green'
        }

        # Retrieves color for level, defaulting to no color
        $color = $colorMap[$Level]

        Write-Host "[" -NoNewline
        Write-Host "$Level" -ForegroundColor $color -NoNewline
        Write-Host "]" -NoNewline

        if (-not [string]::IsNullOrWhiteSpace($Message)) {
            Write-Host " - " -NoNewline
            Write-Host "$Message"
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
        Write-Error "$($FunctionName): Error while writing to log file: $_"
    }
    finally {
        if ($sw) {
            $sw.Close()
        }
        if ($fs) {
            $fs.Close()
        }
    }

}
#endregion

# ================================================================================================================================ #

#region Trace
function Write-LogTrace {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    Write-Log -Message $Message -Level TRACE -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Debug
function Write-LogDebug {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    Write-Log -Message $Message -Level DEBUG -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Info
function Write-LogInfo {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    Write-Log -Message $Message -Level INFO -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Warn
function Write-LogWarn {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    Write-Log -Message $Message -Level WARN -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Fail
function Write-LogFail {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$SysErr,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    $systemMsg = if ($SysErr -and $SysErr -ne "") { ". System: $SysErr" } else { "" }
    Write-Log -Message "$Message$systemMsg" -Level FAIL -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

#region Done
function Write-LogDone {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Use the script variable if not passed as a parameter
    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw "$($functionName) line $($LineNumber) error: LogSetting is not defined as a script variable"
        }
    }

    Write-Log -Message $Message -Level DONE -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #
#region Exception
function Write-LogException {
    [CmdletBinding()]
    param (
        # Log parameter
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [string]$Prefix = '',

        # Force console print
        [switch]$Print,
        [switch]$PrintTime
    )

    $functionName = $MyInvocation.MyCommand.Name

    $exception = $ErrorRecord.Exception

    if (-not [string]::IsNullOrWhiteSpace($Prefix)) {
        $Prefix = "[$Prefix] - "
    }

    Write-LogDebug -Message "Log from: $functionName"
    Write-LogDebug -Message "$($Prefix)Exception type: $($exception.GetType().FullName)" -Print:$Print -PrintTime:$PrintTime
    Write-LogDebug -Message "$($Prefix)Exception message: $($exception.Message)" -Print:$Print -PrintTime:$PrintTime

    if ($exception.InnerException) {
        Write-LogDebug -Message "$($Prefix)Inner exception: $($exception.InnerException.Message)" -Print:$Print -PrintTime:$PrintTime
    }

    Write-LogDebug -Message "$($Prefix)Stack trace: $($ErrorRecord.ScriptStackTrace)" -Print:$Print -PrintTime:$PrintTime
}
#endregion

# ================================================================================================================================ #

# Set Alias
Set-Alias -Name "LogSetting" -Value Invoke-LogSetting
Set-Alias -Name "Log" -Value Write-Log
Set-Alias -Name "LogTrace" -Value Write-LogTrace
Set-Alias -Name "LogDebug" -Value Write-LogDebug
Set-Alias -Name "LogInfo" -Value Write-LogInfo
Set-Alias -Name "LogWarn" -Value Write-LogWarn
Set-Alias -Name "LogFail" -Value Write-LogFail
Set-Alias -Name "LogDone" -Value Write-LogDone
Set-Alias -Name "LogException" -Value Write-LogException

# ================================================================================================================================ #

# Export functions and aliases
Export-ModuleMember -Function @(
    "Invoke-LogSetting",
    "Write-Log",
    "Write-LogTrace",
    "Write-LogDebug",
    "Write-LogInfo",
    "Write-LogWarn",
    "Write-LogFail",
    "Write-LogDone",
    "Write-LogException"
) -Alias @(
    "LogSetting",
    "Log",
    "LogTrace",
    "LogDebug",
    "LogInfo",
    "LogWarn",
    "LogFail",
    "LogDone",
    "LogException"
)