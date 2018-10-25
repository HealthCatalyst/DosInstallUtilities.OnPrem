<#
.SYNOPSIS
Globals

.DESCRIPTION
Globals

.INPUTS
Globals - The name of Globals

.OUTPUTS
None

.EXAMPLE
Globals

.EXAMPLE
Globals


#>
function GlobalsDummy()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'Globals: Starting'

    Write-Verbose 'Globals: Done'

}

# 18.06.1.ce-3
# The list of validated docker versions was updated to 1.11.1, 1.12.1, 1.13.1, 17.03, 17.06, 17.09, 18.06. (#68495)

[hashtable] $globals = @{
    dockerversion = "17.03.2.ce-1"
    dockerselinuxversion = "17.03.2.ce-1"
    kubernetesversion = "1.12.1-0"
    kubernetescniversion = "0.6.0-0"
    kubernetesserverversion = "1.12.1-0"
    kubernetesImagesversion = "1.12.1"
}

Export-ModuleMember -Variable globals