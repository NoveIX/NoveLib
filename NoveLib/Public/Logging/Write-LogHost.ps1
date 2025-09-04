# File: NoveLib\Public\Logging\Write-LogHost.ps1

function Write-LogHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        [string]$Level,

        [switch]$PrintTime
    )

    # =================================================================================================== #

    #### Validate parameter

    # Validate Level Log definition
    [array]$levelOrder = @("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")
    [int]$curIndex = $levelOrder.IndexOf($Level)
    [int]$minIndex = $levelOrder.IndexOf($LogMinLevel)

    # Skip this log if its level is below the minimum
    if ($curIndex -lt $minIndex) { return }

    # =================================================================================================== #

    #### Write console

    # Print Time
    if ($PrintTime) { Write-Host "[$timeStamp] " -NoNewline }

    # Retrieves color for level, defaulting to no color
    [string]$color = Write-LogColorMap -Level $Level

    Write-Host "[" -NoNewline
    Write-Host "$Level" -ForegroundColor $color -NoNewline
    Write-Host "]" -NoNewline
    Write-Host " - $Message"
}