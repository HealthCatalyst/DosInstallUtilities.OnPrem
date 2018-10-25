<#
.SYNOPSIS
OpenKubernetesDashboard

.DESCRIPTION
OpenKubernetesDashboard

.INPUTS
OpenKubernetesDashboard - The name of OpenKubernetesDashboard

.OUTPUTS
None

.EXAMPLE
OpenKubernetesDashboard

.EXAMPLE
OpenKubernetesDashboard


#>
function OpenKubernetesDashboard()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'OpenKubernetesDashboard: Starting'
    $dnshostname = $(ReadSecretValue  -secretname "dnshostname" -namespace "default")
    $myip = $(host $(hostname) | awk '/has address/ { print $4 ; exit }')
    WriteToConsole "dns entries for c:\windows\system32\drivers\etc\hosts (if needed)"
    WriteToConsole "${myip} ${dnshostname}"
    WriteToConsole "-"
    WriteToConsole "You can access the kubernetes dashboard at: https://${dnshostname}/dashboard/ or https://${myip}/dashboard/"
    $secretname = $(kubectl -n kube-system get secret | grep api-dashboard-user | awk '{print $1}')
    $token = $(ReadSecretData "$secretname" "token" "kube-system")
    WriteToConsole "Bearer Token"
    WriteToConsole $token
    WriteToConsole " End of Bearer Token -"

    Write-Verbose 'OpenKubernetesDashboard: Done'

}

Export-ModuleMember -Function 'OpenKubernetesDashboard'