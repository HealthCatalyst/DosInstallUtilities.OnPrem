<#
.SYNOPSIS
WriteToConsole

.DESCRIPTION
WriteToConsole

.INPUTS
WriteToConsole - The name of WriteToConsole

.OUTPUTS
None

.EXAMPLE
WriteToConsole

.EXAMPLE
WriteToConsole


#>
function WriteToConsole()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $txt
    )

    Write-Verbose ""
    # Write-Information -MessageData "$txt"
    Write-Host "===============================================" -ForegroundColor "Magenta"
    Write-Host "$txt" -ForegroundColor "Magenta"
    Write-Host "===============================================" -ForegroundColor "Magenta"
}

Export-ModuleMember -Function 'WriteToConsole'