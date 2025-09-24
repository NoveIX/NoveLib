# File: NoveLib\Private\Data\Write-LogColorMap.ps1

function Write-LogColorMap {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")]
        [string]$Level
    )

    # Define log color map
    [hashtable]$colorMap = @{
        "TRACE" = 'DarkGray'
        "DEBUG" = 'Gray'
        "INFO"  = 'DarkCyan'
        "WARN"  = 'Yellow'
        "ERROR" = 'Red'
        "FATAL" = 'DarkRed'
        "DONE"  = 'Green'
    }

    return $colorMap[$Level]
}
