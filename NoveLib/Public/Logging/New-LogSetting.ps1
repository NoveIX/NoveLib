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
        [switch]$LogUserDir,

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

    # =======================================================[ Self defined ]======================================================= #

    $userName = $env:USERNAME

    # =======================================================[ Handle path ]======================================================== #

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

    # =====================================================[ Handle Filename ]====================================================== #

    # Defines a log file name if missing
    if (-not $Filename) {
        $Filename = if ($MyInvocation.MyCommand.Path) {
            [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
        }
        else { "log" }
    }

    $Filename = $Filename.TrimEnd('.')

    # Force the extension change
    $Filename = [System.IO.Path]::ChangeExtension($Filename, ".log")

    # ====================================================[ Construct log path ]==================================================== #

    # Start dialing the filename
    $file = $Filename

    # Add username if required
    if ($LogUser) { $file += "_$userName" }

    # Date management in file name
    if ($DateLogName -eq "Date") {$file += Get-Date -Format "yyyy-MM-dd"}
    elseif ($DateLogName -eq "Datetime") {$file += Get-Date -Format "yyyy-MM-dd_hh-mm-ss"}

    # Add extension to file
    $file += ".$Extension"

    # Construct the full path to the file
    if ($LogUserDir) { $FilePath = Join-Path -Path $logUserPath -ChildPath $file }
    else { $FilePath = Join-Path -Path $Path -ChildPath $file }

    # =================================================================================================== #

    #### Return setting object with class NoveLib.LogSetting

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
