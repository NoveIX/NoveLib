# File: NoveLib\Public\FileSystem\Copy-FileRobocopy.ps1.ps1

function Copy-FileRobocopy {
    [CmdletBinding()]
    param (
        # Source directory to copy from
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Source,

        # Destination directory to copy to
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination
    )

    # Assicura che le cartelle siano formattate correttamente per robocopy
    $sourcePath = (Resolve-Path -LiteralPath $Source).ProviderPath.TrimEnd('\') + '\'

    if (-not (Test-Path -LiteralPath $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
    $destinationPath = (Resolve-Path -LiteralPath $Destination).ProviderPath.TrimEnd('\') + '\'

    # Parametri robocopy:
    # /E      => Include tutte le sottocartelle (anche quelle vuote)
    # /COPYALL => Copia tutti gli attributi (timestamp, sicurezza, ACL, ecc.)
    # /R:0    => Nessun tentativo di ritrasmissione se fallisce
    # /W:0    => Nessuna attesa tra i tentativi
    # /NFL /NDL => Non elencare file o directory (più silenzioso)
    # /NP     => Non mostrare la percentuale
    # /ETA    => Mostra il tempo stimato

    $arguments = @(
        "`"$sourcePath`"",
        "`"$destinationPath`"",
        "/E",
        "/COPYALL",
        "/R:0",
        "/W:0",
        "/NFL", "/NDL", "/NP", "/ETA"
    )

    $robocopyExe = "robocopy.exe"
    $process = Start-Process -FilePath $robocopyExe -ArgumentList $arguments -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -ge 8) {
        throw "Robocopy ha restituito un errore. Codice di uscita: $($process.ExitCode)"
    }
}
