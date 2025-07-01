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
        [LogSetting]$LogSetting = $DefaultLogSetting
    )

    # ======================================================[ Validate object ]===================================================== #

    if (-not $LogSetting) {
        [string]$functionName = $MyInvocation.MyCommand.Name
        [int]$scriptLine = $MyInvocation.ScriptLineNumber

        $sysMsg = "[$functionName] line [$scriptLine]: DefaultLogSetting is not defined. "
        $sysMsg += "Use Set-DefaultLogSetting at the start of your script."
        throw [System.InvalidOperationException]::new($sysMsg)
    }

    # ======================================================[ Break function ]====================================================== #

    # Validate Level
    [string]$MyLevel = "INFO"
    [string]$LogMinLevel = $LogSetting.LogMinLevel
    [array]$levelOrder = @("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "DONE")
    [int]$curIndex = $levelOrder.IndexOf($MyLevel)
    [int]$minIndex = $levelOrder.IndexOf($LogMinLevel)

    # Skip this log if its level is below the minimum
    if ($curIndex -lt $minIndex) { return }

    # ======================================================[ Core function ]======================================================= #

    if ($Print -and $PrintTime) { $Print = $false }

    # Call Main function
    Write-Log -Message $Message -Level $MyLevel -LogSetting $LogSetting -Print:$Print -PrintTime:$PrintTime
}