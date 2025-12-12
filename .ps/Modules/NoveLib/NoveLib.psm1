# ======================[ NoveLib.psm1 ]====================== #

$moduleRoot = Split-Path -Parent $PSCommandPath
$dllPath = Join-Path -Path $moduleRoot -ChildPath "Binary"

# Seleziona il target .NET in base all'ambiente
if ($PSEdition -eq 'Core') { $dllPath = Join-Path -Path $dllPath -ChildPath 'NoveLib.net8.0.dll' }
else { $dllPath = Join-Path -Path $dllPath -ChildPath 'NoveLib.net48.dll' }

# Carica la DLL se esiste
if (Test-Path $dllPath) { Import-Module $dllPath }
else { throw "Assembly non trovato: $dllPath" }

# ============================================================ #
