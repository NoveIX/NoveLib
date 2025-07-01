# Loading module
# ================================================================================================================================ #

# +------------------+
# | Library function |
# +------------------+

# ================================================================================================================================ #

# Open NoveLib Log
function Open-NoveLibLog {
    Invoke-Item -Path $LogDir
}

# ================================================================================================================================ #

# Import NoveLib
function New-NoveLibLogFile {  
    param (
        # Loading module
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "FAIL", "DONE")]
        $LogMinLevel = "INFO"
    )

    # Log level
    $LogDir = $( Join-Path -Path $env:TEMP -ChildPath "NoveLib" )

    # Retrieve all functions from the "NoveLib" library
    $FunctionNames = Get-Command -Module "NoveLib" -CommandType Function -ErrorAction SilentlyContinue

    # Create variables for function log
    foreach ($FunctionName in $FunctionNames) {
        $FunctionName = $FunctionName.Name
        $VarName = "${FunctionName}LogSetting"
        $Value = New-LogSetting -Filename $FunctionName -Path $LogDir -LogMinLevel $LogMinLevel -DateInLogFile
        Set-Variable -Name $VarName -Value $Value -Scope Script
    }
}
New-NoveLibLogFile

# ================================================================================================================================ #