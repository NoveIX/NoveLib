# File: NoveLib\Private\Function\Copy-FileItem.ps1

function Copy-FileItem {
    [CmdletBinding()]
    param (
        # Parameter
        [Parameter(Mandatory = $true)]
        [object[]]$Files,

        # Steam
        [Parameter(Mandatory = $true)]
        [switch]$Stream,
        [Parameter(Mandatory = $true)]
        [int]$MaxFileSize,
        [Parameter(Mandatory = $true)]
        [int]$BufferSize
    )


    foreach ($file in $files) {
        # Resolve Destination Path And Create
        [string]$fileDest = Copy-FileResolveDestination -File $file -Source $Source -Destination $Destination -Ensure

        # Copy File
        if (($file.Length -ge $MaxFileSize) -and $Stream) {
            try {
                Copy-FileBuffer -SourceFile $file.FullName -DestinationFile $fileDest -BufferSize $BufferSize -File $file
            }
            finally {
                $Script:CurrentFile_NoveLibFX++
            }
        }
        else {
            try {
                Copy-Item -Path $file.FullName -Destination $fileDest -Force -ErrorAction Stop
            }
            finally {
                $Script:CurrentFile_NoveLibFX++
                $Script:CurrentBytes_NoveLibFX += $file.Length
            }
        }

        # Display progress bar
        Copy-FileDisplayMode -File $file
    }
}
