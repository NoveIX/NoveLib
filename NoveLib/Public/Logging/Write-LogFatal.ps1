# File: NoveLib\Public\Logging\Write-LogFatal.ps1

function Write-LogFatal {
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
    Write-Log -Message $Message -Level FATAL -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime -FunctionName $functionName -ScriptLine $scriptLine
}