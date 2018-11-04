<#
.SYNOPSIS
ChangeSslCertificate

.DESCRIPTION
ChangeSslCertificate

.INPUTS
ChangeSslCertificate - The name of ChangeSslCertificate

.OUTPUTS
None

.EXAMPLE
ChangeSslCertificate

.EXAMPLE
ChangeSslCertificate


#>
function ChangeSslCertificate()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'ChangeSslCertificate: Starting'

    WriteToConsole "Deleting old certificate"
    kubectl delete secret fabric-ssl-cert -n kube-system --ignore-not-found=true

    WriteToConsole "setting up load balancer"
    SetupOnPremLoadBalancer

    WriteToConsole "setting up kubernetes dashboard"
    InstallDashboard

    Write-Verbose 'ChangeSslCertificate: Done'

}

Export-ModuleMember -Function 'ChangeSslCertificate'