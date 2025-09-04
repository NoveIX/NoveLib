# File: NoveLib\Public\Logging\Write-LogInfo.ps1

function Write-LogInfo {
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

    # --- self-defined parameters ---
    [string]$functionName = $MyInvocation.MyCommand.Name
    [int]$scriptLine = $MyInvocation.ScriptLineNumber

    # Call Main function
    Write-Log -Message $Message -Level INFO -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime -FunctionName $functionName -ScriptLine $scriptLine
}