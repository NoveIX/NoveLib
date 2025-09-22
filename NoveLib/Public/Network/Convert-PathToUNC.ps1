#File: NoveLib\Public\Network\Convert-PathToUNC.ps1

function Convert-PathToUNC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [string]$Path
    )

    # Match drive letter optionally followed by colon and optional backslash + path
    if ($Path -match '^([A-Za-z]):?(?:\\(.*))?$') {
        $drive = $matches[1]
        $rest = $matches[2]

        # Build and return UNC path: if no $rest, no extra backslash after share
        if ([string]::IsNullOrEmpty($rest)) { return "\\$ComputerName\$drive$" }

        # Build and return UNC path
        return "\\$ComputerName\$drive`$\$rest"
    }
    else {
        $sysMsg = "The path '$Path' is not a valid local path (e.g., 'C:\' or 'C:\Folder\File.txt')."
        throw [System.ArgumentException]::new($sysMsg)
    }
}
