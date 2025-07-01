# File: NoveLib\Public\Logging\Write-LogFail.ps1

function Write-LogFail {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$SysErr,

        # Force console print
        [ValidateSet("None", "MessageOnly", "MessageAndTimestamp")]
        [string]$PrintMode = "None",

        # self-defined parameters
        [pscustomobject]$LogSetting = $null
    )

    # self-defined parameters
    $functionName = $MyInvocation.MyCommand.Name
    $scriptLine = $MyInvocation.ScriptLineNumber

    # Use the script variable if not passed as a parameter
    $LogSetting = Test-LogSetting -LogSetting $LogSetting -FunctionName $functionName -ScriptLine $scriptLine

    $systemMsg = if ($SysErr -and $SysErr -ne "") { ". System: $SysErr" } else { "" }
    Write-Log -Message"$Message$systemMsg" -Level FAIL -LogSetting $LogSetting -ForceConsoleOutput $PrintMode
}