<#
.SYNOPSIS
SetupMaster

.DESCRIPTION
SetupMaster

.INPUTS
SetupMaster - The name of SetupMaster

.OUTPUTS
None

.EXAMPLE
SetupMaster

.EXAMPLE
SetupMaster


#>
function SetupMaster()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
        ,
        [bool]
        $singlenode
    )

    Write-Verbose 'SetupMaster: Starting'
    [hashtable]$Return = @{}

    [string] $logfile = "$(get-date -f yyyy-MM-dd-HH-mm)-setupmaster.txt"
    WriteToConsole "Logging to $logfile"
    Start-Transcript -Path "$logfile"

    WriteToConsole "cleaning up old stuff"
    UninstallDockerAndKubernetes

    WriteToConsole "setting up new node"
    SetupNewNode -baseUrl $baseUrl

    WriteToConsole "setting up new master node"
    SetupNewMasterNode -baseUrl $baseUrl

    WriteToConsole "enabling master node to run containers"
    # enable master to run containers
    # kubectl taint nodes --all node-role.kubernetes.io/master-
    kubectl taint node --all node-role.kubernetes.io/master:NoSchedule-

    if ($singlenode) {
        Write-Host "enabling master node to run containers"
        # enable master to run containers
        # kubectl taint nodes --all node-role.kubernetes.io/master-
        kubectl taint node --all node-role.kubernetes.io/master:NoSchedule-
    }
    else {
        mountSharedFolder -saveIntoSecret $True
    }

    WriteToConsole "Installing Helm"
    InstallHelmOnPrem

    WriteToConsole "setting up load balancer"
    SetupOnPremLoadBalancer

    WriteToConsole "setting up kubernetes dashboard"
    InstallDashboard

    # clear
    Write-Host "waiting for pods to run in kube-system"
    WaitForPodsInNamespace -namespace "kube-system" -interval 5

    if ($singlenode -eq $True) {
        Write-Host "Finished setting up a single-node cluster"
    }
    else {
        ShowCommandToJoinCluster $baseUrl
    }

    Stop-Transcript

    Write-Verbose 'SetupMaster: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupMaster'