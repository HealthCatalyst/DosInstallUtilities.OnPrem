<#
.SYNOPSIS
SetupWorker

.DESCRIPTION
SetupWorker

.INPUTS
SetupWorker - The name of SetupWorker

.OUTPUTS
None

.EXAMPLE
SetupWorker

.EXAMPLE
SetupWorker


#>
function SetupWorker()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $joincommand
    )

    Write-Verbose 'SetupWorker: Starting'

    [hashtable]$Return = @{}

    # Set-PSDebug -Trace 1
    [string] $logfile = "$(get-date -f yyyy-MM-dd-HH-mm)-setupworker.txt"
    WriteToConsole "Logging to $logfile"
    Start-Transcript -Path "$logfile"

    WriteToConsole "cleaning up old stuff"
    UninstallDockerAndKubernetes

    WriteToConsole "setting up new node"
    SetupNewNode -baseUrl $baseUrl

    WriteToConsole "mounting network folder"
    MountFolderFromSecrets -baseUrl $baseUrl

    WriteToConsole "joining cluster"
    Write-Host "sudo $joincommand"
    Invoke-Expression "sudo $joincommand"

    # sudo kubeadm join --token $token $masterurl --discovery-token-ca-cert-hash $discoverytoken

    WriteToConsole "This node has successfully joined the cluster"

    Stop-Transcript

    Write-Verbose 'SetupWorker: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupWorker'