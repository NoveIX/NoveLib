# File: NoveLib\Public\Logging\Write-LogDone.ps1

function Write-LogDone {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

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

    Write-Log -Message $Message -Level DONE -LogSetting $LogSetting -ForceConsoleOutput $PrintMode
}