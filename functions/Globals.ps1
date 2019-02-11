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
    dockerversion = "17.03.1.ce-1"
    dockerselinuxversion = "2.68-1"
    kubernetesversion = "1.11.3-0"
    kubernetescniversion = "0.6.0-0"
    kubernetesserverversion = "1.11.3-0"
    kubernetesImagesversion = "1.11.3"
    critoolsversion = "1.12.0-0"
    realtimePackageUrl = "https://raw.githubusercontent.com/HealthCatalyst/helm.realtime/master/fabricrealtime-1.1.0.tgz"
    externalLoadBalancerLabel = "k8s-app-external"
    externalLoadBalancerLabelValue = "nginx"
    internalLoadBalancerLabel = "k8s-app-internal"
    internalLoadBalancerLabelValue = "nginx"
    internalLoadBalancerLabelSelector = "k8s-app-internal=nginx"
    externalLoadBalancerLabelSelector = "k8s-app-external=nginx"
    ngniximageTag = "0.20.0"
}

Export-ModuleMember -Variable globals
