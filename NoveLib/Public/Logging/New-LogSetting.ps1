# File: NoveLib\Public\Logging\New-LogSetting.ps1

function New-LogSetting {
    [CmdletBinding()]
    param (
        # Log Definition
        [string]$Filename,
        [string]$Extension,
        [string]$Path,
        [string]$Temp,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
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
        [ValidateSet("None", "Message", "Timestamp")]
        [string]$EnableConsoleOutput = "None",

        # use .NET to write in the file
        [bool]$UseDotNET = $true
    )

    # =================================================================================================== #

    #### Begin

    # self-defined parameters
    $userName = $env:USERNAME
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Parameter validation
    if ($UseRecentLogFile -and -not $DateInLogFile) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'UseRecentLogFile' requires 'DateInLogFile'."
    }

    if (($RecentLogFileDelayMinute -ne 30) -and -not $UseRecentLogFile) {
        Write-Warning "$($FunctionName) line $($LineNumber): Parameter 'RecentLogFileDelayMinute' requires 'UseRecentLogFile'."
    }

    # =================================================================================================== #

    #### Handle Path

    # Log Path
    if (-not $Path) {
        # If the script was not started from a file, use the current folder.
        $basePath = if ($MyInvocation.ScriptName) { $PSScriptRoot } else { $PWD }
        $Path = Join-Path -Path $basePath -ChildPath "log"
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Path))) {
        # Converts to absolute path if relative
        $Path = (Resolve-Path -Path (Join-Path -Path $PWD -ChildPath $Path)).Path
    }

    # Temp Path
    if (-not $Temp) {
        $Temp = Join-Path -Path $Path -ChildPath "temp"
    }
    elseif (-not ([System.IO.Path]::IsPathRooted($Temp))) {
        # Converts to absolute path if relative
        $Temp = (Resolve-Path -Path (Join-Path -Path $PWD -ChildPath $Temp)).Path
    }

    # =================================================================================================== #

    #### Ensure Directory

    # Ensure log directory exists
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }

    # Ensure temp directory exists (only if recent log file is used)
    if ($UseRecentLogFile -and -not (Test-Path $Temp)) {
        New-Item -Path $Temp -ItemType Directory -Force | Out-Null
    }

    # Optional: create a subdirectory based on current user
    if ($LogUserDir) {
        $logUserPath = Join-Path -Path $Path -ChildPath $userName
        if (-not (Test-Path -Path $logUserPath)) {
            New-Item -Path $logUserPath -ItemType Directory -Force | Out-Null
        }
    }

    # =================================================================================================== #

    #### Handle Filename

    # Defines a log file name if missing
    if (-not $Filename) {
        $Filename = if ($MyInvocation.MyCommand.Path) {
            [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
        }
        else { "log" }
    }

    # Define default log extension if missing
    if (-not $Extension -or [string]::IsNullOrWhiteSpace($Extension) -or $Extension -eq ".") {
        $Extension = "log"
    }
    else {
        $Extension = $Extension.TrimStart(".").ToLower()
        if (-not $Extension) { $Extension = "log" }
    }

    # =================================================================================================== #

    #### Build log path

    # Start dialing the filename
    $file = $Filename

    # Add username if required
    if ($LogUser) { $file += "_$userName" }

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

                # Convert data
                $fileDateTime = [DateTime]::ParseExact($fileCurrentDate, "yyyy-MM-dd_HH-mm", $null)
                $currentDateTime = [DateTime]::ParseExact($currentDate, "yyyy-MM-dd_HH-mm", $null)

                # Validate if bigger than current data. if yes use existing file
                if ($fileDateTime.AddMinutes($RecentLogFileDelayMinute) -ge $currentDateTime) {
                    $currentDate = $fileCurrentDate
                    $writeDate = $false
                }
                else { Remove-Item -Path $dateTempFile -Force }
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
        $filePath = Join-Path -Path $logUserPath -ChildPath $file
    }
    else {
        $filePath = Join-Path -Path $Path -ChildPath $file
    }

    # =================================================================================================== #

    #### Return setting object with class NoveLib.LogSetting

    # Create and return an instance of the NoveLib.LogSetting class with the provided configuration parameters
    $logSettingObject = [LogSetting]::new(
        $filePath,
        $LogMinLevel,
        $EnableConsoleOutput,
        $UseMilliseconds,
        $UseDotNET
    )

    return $logSettingObject
}
