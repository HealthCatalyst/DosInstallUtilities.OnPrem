<#
.SYNOPSIS
ShowKubernetesServiceStatus

.DESCRIPTION
ShowKubernetesServiceStatus

.INPUTS
ShowKubernetesServiceStatus - The name of ShowKubernetesServiceStatus

.OUTPUTS
None

.EXAMPLE
ShowKubernetesServiceStatus

.EXAMPLE
ShowKubernetesServiceStatus


#>
function ShowKubernetesServiceStatus()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'ShowKubernetesServiceStatus: Starting'
    sudo systemctl status kubelet -l
    sudo journalctl -xe --priority 0..3
    sudo journalctl -u kube-apiserve

    Write-Verbose 'ShowKubernetesServiceStatus: Done'

}

Export-ModuleMember -Function 'ShowKubernetesServiceStatus'