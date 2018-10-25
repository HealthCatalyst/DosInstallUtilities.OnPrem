<#
.SYNOPSIS
UninstallDockerAndKubernetes

.DESCRIPTION
UninstallDockerAndKubernetes

.INPUTS
UninstallDockerAndKubernetes - The name of UninstallDockerAndKubernetes

.OUTPUTS
None

.EXAMPLE
UninstallDockerAndKubernetes

.EXAMPLE
UninstallDockerAndKubernetes


#>
function UninstallDockerAndKubernetes()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'UninstallDockerAndKubernetes: Starting'

    [hashtable]$Return = @{}

    $logfile = "$(get-date -f yyyy-MM-dd-HH-mm)-uninstall.txt"
    WriteToConsole "Logging to $logfile"
    Start-Transcript -Path "$logfile"

    WriteToConsole "Uninstalling docker and kubernetes"

    if ("$(command -v kubeadm)") {
        WriteToLog "resetting kubeadm"
        sudo kubeadm reset -f
    }
    sudo yum -y remove kubelet kubeadm kubectl kubernetes-cni
    unlockPackageVersion "kubelet kubeadm kubectl kubernetes-cni"

    if ("$(command -v docker)") {
        sudo docker system prune -f
        # sudo docker volume rm etcd
    }
    sudo rm -rf /var/etcd/backups/*
    sudo yum -y remove docker-engine.x86_64 docker-ce docker-engine-selinux.noarch docker-cimprov.x86_64 docker-engine
    sudo yum -y remove docker docker-common docker-selinux docker-engine docker-ce docker-ce-selinux container-selinux
    sudo yum -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    unlockPackageVersion "docker-ce docker-ce-selinux"

    WriteToConsole "Successfully uninstalled docker and kubernetes"

    Stop-Transcript

    Write-Verbose 'UninstallDockerAndKubernetes: Done'

    return $Return
}

Export-ModuleMember -Function 'UninstallDockerAndKubernetes'