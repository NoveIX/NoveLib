# File: NoveLib\Public\Logging\Write-LogDebug.ps1

function Write-LogDebug {
    [CmdletBinding()]
    param(
        # Log parameter
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # Force console print
        [switch]$Print,
        [switch]$PrintTime,

        # Force use another log setting
        [LogSetting]$LogSetting = $null
    )

    # self-defined parameters
    [string]$functionName = $MyInvocation.MyCommand.Name
    [int]$scriptLine = $MyInvocation.ScriptLineNumber

    Write-Log -Message $Message -Level DEBUG -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime -FunctionName $functionName -ScriptLine $scriptLine
}