# File: NoveLib\Private\Core\Test-LogSetting.ps1

function Test-LogSetting {
    [CmdletBinding()]
    param (
        [pscustomobject]$LogSetting,
        [string]$FunctionName,
        [int]$ScriptLine
    )

    if (-not $LogSetting) {
        $LogSetting = $script:LogSetting

        if (-not $LogSetting) {
            throw [System.InvalidOperationException]::new(
                "$($FunctionName) line $($ScriptLine) error: LogSetting is not defined as a script variable"
            )
        }
    }

    $LogSetting
}
