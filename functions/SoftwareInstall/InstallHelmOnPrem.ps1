<#
.SYNOPSIS
InstallHelmOnPrem

.DESCRIPTION
InstallHelmOnPrem

.INPUTS
InstallHelmOnPrem - The name of InstallHelmOnPrem

.OUTPUTS
None

.EXAMPLE
InstallHelmOnPrem

.EXAMPLE
InstallHelmOnPrem


#>
function InstallHelmOnPrem()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'InstallHelmOnPrem: Starting'

    Write-Host "installing helm"
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh

    InitHelm

    Write-Verbose 'InstallHelmOnPrem: Done'
}

Export-ModuleMember -Function 'InstallHelmOnPrem'