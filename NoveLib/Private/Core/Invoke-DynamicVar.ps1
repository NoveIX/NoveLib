# File: NoveLib\Private\Core\Invoke-DynamicVar.ps1

function Invoke-DynamicVar {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Name,

        [Parameter(Position = 1)]
        [object]$Value
    )

    if ($PSBoundParameters.ContainsKey('Value')) {
        # Se passo il valore, creo o aggiorno la variabile dinamica
        Set-Variable -Name $Name -Value $Value -Scope Script -Force
    }

    # Ritorno il valore della variabile (se esiste)
    if (Get-Variable -Name $Name -Scope Script -ErrorAction SilentlyContinue) {
        return (Get-Variable -Name $Name -Scope Script).Value
    }
    else {
        return $null
    }
}
