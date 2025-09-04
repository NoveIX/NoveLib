# File: NoveLib.psm1

# Module root
$ModuleRoot = $PSScriptRoot

# Directory
$PrivateDir = Join-Path -Path $ModuleRoot -ChildPath "Private"
$ClassDir = Join-Path -Path $PrivateDir -ChildPath "Class"
$PublicDir = Join-Path -Path $ModuleRoot -ChildPath "Public"
$AliasDir = Join-Path -Path $PublicDir -ChildPath "Alias"

# =================================================================================================== #

# Load classes
$ClassFiles = Get-ChildItem -Path $ClassDir -Filter *.ps1 -Recurse -File
foreach ($file in $ClassFiles) { . $file.FullName }

# =================================================================================================== #

# Load private functions - not to be exported
$PrivateSubDirs = Get-ChildItem -Path $PrivateDir -Directory -Exclude "Class"
foreach ($dir in $PrivateSubDirs) {
    $PrivateFiles = Get-ChildItem -Path $dir -Filter *.ps1 -Recurse -File
    foreach ($file in $PrivateFiles) { . $file.FullName }
}

# =================================================================================================== #

# Load public functions - to be exported
$FunctionToExport = @()
$PublicSubDirs = Get-ChildItem -Path $PublicDir -Directory -Exclude "Alias"
foreach ($dir in $PublicSubDirs) {
    $PublicFiles = Get-ChildItem -Path $dir -Filter *.ps1 -Recurse -File
    foreach ($file in $PublicFiles) {
        . $file.FullName
        $FunctionToExport += $file
    }
}

# =================================================================================================== #

# Find all functions declared in public files and export them
$ExportedFunctions = foreach ($function in $FunctionToExport) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($function.FullName, [ref]$null, [ref]$null)
    foreach ($func in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
        $func.Name
    }
}

# =================================================================================================== #

# Load aliases - to be exported
$ExportedAlias = @()
$AliasFiles = Get-ChildItem -Path $AliasDir -Filter *.ps1 -Recurse -File
foreach ($file in $AliasFiles) {

    # Retrieves all aliases and filters them to obtain only the new ones.
    $ExistingAliases = Get-Alias | Select-Object -ExpandProperty Name
    . $file.FullName
    $NewAliases = Get-Alias | Where-Object { $ExistingAliases -notcontains $_.Name }
    $ExportedAlias += $NewAliases
}

# =================================================================================================== #

# Export function
Export-ModuleMember -Function $ExportedFunctions -Alias $ExportedAlias
