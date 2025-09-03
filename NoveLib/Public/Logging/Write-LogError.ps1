# File: NoveLib\Public\Logging\Write-LogError.ps1

function Write-LogError {
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

    Write-Log -Message $Message -Level ERROR -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime -FunctionName $functionName -ScriptLine $scriptLine
}