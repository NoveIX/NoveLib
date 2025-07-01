function Convert-ByteToReadableString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Byte,

        # Log
        [pscustomobject]$LogSetting = $ByteToReadableSize,
        [switch]$Print,
        [switch]$PrintTime
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Start
    Write-LogTrace -Message "[$FunctionName] started with input: $Byte" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    if ($Byte -ge 1TB) {
        $result = "{0:N3} TB" -f ($Byte / 1TB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1GB) {
        $result = "{0:N3} GB" -f ($Byte / 1GB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1MB) {
        $result = "{0:N3} MB" -f ($Byte / 1MB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1KB) {
        $result = "{0:N3} KB" -f ($Byte / 1KB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    else {
        $result = "$Byte Byte$(if ($Byte -ne 1) { 's' } else { '' })"
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to bytes string: $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    Write-LogTrace -Message "[$FunctionName] finished with result: $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    return $result
}


# ================================================================================================================================ #

function Convert-ByteToReadableSizeDouble {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Byte,

        # Log
        [pscustomobject]$LogSetting = $ByteToReadableSizeValueLogSetting,
        [switch]$Print,
        [switch]$PrintTime
    )

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Log start
    Write-LogTrace -Message "[$FunctionName] started with input: $Byte" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    if ($Byte -ge 1TB) {
        $result = ($Byte / 1TB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to TB = $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1GB) {
        $result = ($Byte / 1GB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to GB = $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1MB) {
        $result = ($Byte / 1MB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to MB = $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    elseif ($Byte -ge 1KB) {
        $result = ($Byte / 1KB)
        Write-LogDebug -Message "[$FunctionName] Converted $Byte bytes to KB = $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }
    else {
        $result = $Byte
        Write-LogDebug -Message "[$FunctionName] Returned raw byte value: $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    }

    # Log end
    Write-LogTrace -Message "[$FunctionName] finished with result: $result" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
    return $result
}


# ================================================================================================================================ #

function Convert-PathToUNC {
    param(
        # Path UNC
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [string]$Path,

        # Log
        [pscustomobject]$LogSetting = $PathToUNCLogSetting,
        [switch]$print,
        [switch]$PrintTime
    )

    # Begin - Validate required functions
    $requiredFunctions = @{
        "Write-LogTrace" = "PSWriteLog"
        "Write-LogDebug" = "PSWriteLog"
        "Write-LogFail"  = "PSWriteLog"
    }

    foreach ($func in $requiredFunctions.Keys) {
        if (-not (Get-Command -Name $func -CommandType Function -ErrorAction SilentlyContinue)) {
            throw "Error: the function '$func' was not found in the current session. Make sure that the module '$($requiredFunctions[$func])' is present in the NoveLib library."
        }
    }

    # self-defined parameters
    $FunctionName = $MyInvocation.MyCommand.Name
    $LineNumber = $MyInvocation.ScriptLineNumber

    # Redundant parameter warning
    if ($Print -and $PrintTime) {
        Write-Warning "[$FunctionName] line ${LineNumber}: Parameter 'PrintTime' includes the effects of 'Print' and also adds the timestamp to the output. Use one of them."
        $Print = $false
    }

    # Log start
    Write-LogTrace -Message "[$FunctionName] started - ComputerName: '$ComputerName', Path: '$Path'" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    # Function Script
    Write-LogDebug -Message "[$FunctionName] Checking if path '$Path' matches drive letter format." -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

    if ($Path -match '^([A-Za-z]):\\(.+)$') {
        $drive = $matches[1]
        $rest = $matches[2]

        Write-LogDebug -Message "[$FunctionName] Extracted drive: '$drive', rest of path: '$rest'" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime

        $result = "\\$ComputerName\$drive`$\$rest"

        Write-LogTrace -Message "[$FunctionName] finished with result: '$result'" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        return $result
    }
    else {
        Write-LogFail -Message "[$FunctionName] The path '$Path' is not a valid absolute local path" -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
        $message = "The path '$Path' is not a valid absolute local path (e.g., 'C:\Folder\File.txt')."
        $exception = New-Object System.Management.Automation.ParentContainsErrorRecordException($message)
        throw $exception
    }
}
