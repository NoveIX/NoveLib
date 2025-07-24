# File: NoveLib\Private\Data\Write-LogColorMap.ps1

function Write-LogColorMap {
    param (
        # Log level - restricted to specific set of valid values
        [Parameter(Mandatory = $true)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        [string]$Level
    )

    # Define a map from log levels to console colors
    $colorMap = @{
        "TRACE" = 'DarkGray'
        "DEBUG" = 'Gray'
        "INFO"  = 'DarkCyan'
        "WARN"  = 'Yellow'
        "FAIL"  = 'Red'
        "DONE"  = 'Green'
    }

    # Return the color corresponding to the log level
    return $colorMap[$Level]
}
