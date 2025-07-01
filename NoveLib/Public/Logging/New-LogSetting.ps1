# File: NoveLib\Public\Logging\New-LogSetting.ps1

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
        [ValidateSet("None", "MessageOnly", "MessageAndTimestamp")]
        [string]$EnableConsoleOutput = "None",

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



    # Retrieve the current user name
    $userName = $env:USERNAME

    # Handle Log Path
    if (-not $Path) {
        if (-not $MyInvocation.ScriptName) {
            $Path = Join-Path -Path $PWD -ChildPath "Log"
        }
        else {
            $Path = Join-Path -Path $PSScriptRoot -ChildPath "Log"
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
        New-Directory -Path $Path
    }

    # Ensure temp directory exists (only if recent log file is used)
    if ($UseRecentLogFile -and -not (Test-Path $Temp)) {
        New-Directory -Path $Temp
    }

    # Optional: create a subdirectory based on current user
    if ($LogUserDir) {
        $logUserPath = Join-Path -Path $Path -ChildPath $userName
        if (-not (Test-Path -Path $logUserPath)) {
            New-Directory -Path $logUserPath
        }
    }

    # Define default log name if missing
    if (-not $Filename) {
        $scriptName = $MyInvocation.MyCommand.Path
        if ($scriptName) {
            $Filename = [System.IO.Path]::GetFileNameWithoutExtension($scriptName)
        }
        else {
            $Filename = "Log"
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
        $filePath = Join-Path -Path $logUserPath -ChildPath $file
    }
    else {
        $filePath = Join-Path -Path $Path -ChildPath $file
    }



    # Create and return an instance of the NoveLib_LogSetting class with the provided configuration parameters
    $logSettingObject = [NoveLibLogSetting]::new(
        $filePath,
        $LogMinLevel,
        $EnableConsoleOutput,
        $UseMilliseconds,
        $UseDotNET
    )

    return $logSettingObject
}
