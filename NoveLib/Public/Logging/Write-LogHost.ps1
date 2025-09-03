# File: NoveLib\Public\Logging\Write-LogHost.ps1

function Write-LogHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        [string]$Level
    )

    # Validate Level Log definition
    $levelOrder = @("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")
    $curIndex = $levelOrder.IndexOf($Level)
    $minIndex = $levelOrder.IndexOf($logMinLevel)

    # Skip this log if its level is below the minimum
    if ($curIndex -lt $minIndex) { return }

    $color = Get-LogColorMap -Level $Level
    Write-Host "[" -NoNewline
    Write-Host "$Level" -ForegroundColor $color -NoNewline
    Write-Host "]" -NoNewline
    Write-Host " - $Message"
}