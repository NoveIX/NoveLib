# File: NoveLib\Public\Logging\Write-LogException.ps1

function Write-LogException {
    [CmdletBinding()]
    param (
        # Log parameter
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [string]$Prefix = '',

        # Force console print
        [ValidateSet("None", "MessageOnly", "MessageAndTimestamp")]
        [string]$PrintMode = "None"
    )

    $exception = $ErrorRecord.Exception

    if (-not [string]::IsNullOrWhiteSpace($Prefix)) {
        $Prefix = "[$Prefix] - "
    }

    Write-LogDebug -Message "$($Prefix)Exception type: $($exception.GetType().FullName)" -PrintMode $PrintMode
    Write-LogDebug -Message "$($Prefix)Exception message: $($exception.Message)" -PrintMode $PrintMode

    if ($exception.InnerException) {
        Write-LogDebug -Message "$($Prefix)Inner exception: $($exception.InnerException.Message)" -PrintMode $PrintMode
    }

    Write-LogDebug -Message "$($Prefix)Stack trace: $($ErrorRecord.ScriptStackTrace)" -PrintMode $PrintMode
}
