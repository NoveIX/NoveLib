# File: NoveLib\Public\Logging\New-LogSetting.ps1

function New-LogSetting {
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

        # Insert log format
        [ValidateSet('None', 'Date', 'Datetime')]
        [string]$DateLogName = "None",
        [ValidateSet('Time', 'Datetime')]
        [string]$LogFormat = "Time",
        [switch]$UseMillisecond,

        # Console mode
        [ValidateSet("None", "Message", "Timestamp")]
        [string]$ConsoleOutput = "None",

        # Write with .net
        [bool]$UseDotNET = $true
    )

    # ========================================[ Handle path ]========================================= #

    # Log Path
    if (-not $Path) {
        # If the script was not started from a file, use the current folder.
        $basePath = if ($MyInvocation.ScriptName) { $PSScriptRoot } else { $PWD }
        $Path = Join-Path -Path $basePath -ChildPath "logs"
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        # Converts to absolute path if relative
        $Path = (Resolve-Path -Path (Join-Path -Path $PWD -ChildPath $Path)).Path
    }

    # ======================================[ Handle Filename ]======================================= #

    # Defines a log file name if missing
    if (-not $Filename) {
        $Filename = if ($MyInvocation.ScriptName) {
            [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
        }
        else { "log" }
    }
    else { $Filename = [System.IO.Path]::GetFileNameWithoutExtension($Filename) }

    # =====================================[ Construct log path ]===================================== #

    # Start dialing the filename
    $file = $Filename

    # Add username if required
    if ($LogUser) { $file += "_$env:USERNAME" }

    # Date management in file name
    if ($DateLogName -eq "Date") { $file += "_$(Get-Date -Format "yyyy-MM-dd")" }
    elseif ($DateLogName -eq "Datetime") { $file += "_$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss")" }

    # Add extension to file
    $file += ".log"

    # Construct the full path to the file
    if ($LogUserSubPath) { $FilePath = Join-Path -Path $LogUserSubPath -ChildPath $file }
    else { $FilePath = Join-Path -Path $Path -ChildPath $file }

    # =================================[ Return NoveLib.LogSetting ]================================== #

    # Create and return an instance of the NoveLib.LogSetting class with the provided configuration parameters
    $logSettingObject = [LogSetting]::new(
        $FilePath,
        $LogMinLevel,
        $LogFormat,
        $ConsoleOutput,
        $useMillisecond,
        $UseDotNET
    )

    return $logSettingObject
}
