# File: NoveLib\Private\Data\Write-LogOutputMap.ps1

function Write-LogConsoleOutputMap {
    param (
        # Mode for console output, restricted to valid options
        [ValidateSet("None", "MessageOnly", "MessageAndTimestamp")]
        [string]$ConsoleOutputMode
    )

    # Define mapping from console output modes to their settings
    $outputMap = @{
        "None"                = @{ consolePrint = $false; consolePrintTime = $false }
        "MessageOnly"         = @{ consolePrint = $true; consolePrintTime = $false }
        "MessageAndTimestamp" = @{ consolePrint = $true; consolePrintTime = $true }
    }

    # Return the corresponding mapping if the mode is valid
    return $outputMap[$ConsoleOutputMode]

}
