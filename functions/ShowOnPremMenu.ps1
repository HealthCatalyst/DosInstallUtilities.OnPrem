<#
.SYNOPSIS
ShowOnPremMenu

.DESCRIPTION
ShowOnPremMenu

.INPUTS
ShowOnPremMenu - The name of ShowOnPremMenu

.OUTPUTS
None

.EXAMPLE
ShowOnPremMenu

.EXAMPLE
ShowOnPremMenu


#>
function ShowOnPremMenu()
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
        [bool]
        $local
        ,
        [Parameter(Mandatory=$true)]
        [bool]
        $isPrerelease
    )

    Write-Verbose 'ShowOnPremMenu: Starting'

    [string] $userinput = ""
    while ($userinput -ne "q") {
        [bool] $skip=$false
        Write-Host "================ Health Catalyst ================"
        Write-Host "------ On-Premise -------"
        Write-Host "1: Setup Master VM"
        Write-Host "2: Show command to join another node to this cluster"
        Write-Host "3: Uninstall Docker and Kubernetes"
        Write-Host "4: Show all nodes"
        Write-Host "5: Show status of cluster"
        Write-Host "6: Setup Single Node Cluster"
        Write-Host "-----------"
        Write-Host "20: Troubleshooting Menu"
        Write-Host "-----------"
        Write-Host "52: Fabric Realtime Menu"
        Write-Host "-----------"
        Write-Host "q: Quit"
        $userinput = Read-Host "Please make a selection"
        switch ($userinput) {
            '1' {
                SetupMaster -baseUrl $baseUrl -singlenode $false -Verbose
            }
            '2' {
                ShowCommandToJoinCluster -baseUrl $baseUrl -prerelease $isPrerelease
            }
            '3' {
                UninstallDockerAndKubernetes
            }
            '4' {
                Write-Host "Current cluster: $(kubectl config current-context)"
                kubectl version --short
                kubectl get "nodes"
            }
            '5' {
                ShowStatusOfCluster
            }
            '6' {
                SetupMaster -baseUrl $baseUrl -singlenode $true -Verbose
            }
            '20' {
                showTroubleshootingMenu -baseUrl $baseUrl -isAzure $false
                $skip=$true
            }
            '52' {
                ShowRealtimeMenu -baseUrl $baseUrl -namespace "fabricrealtime" -local $local -isAzure $false
                $skip=$true
            }
            'q' {
                return
            }
        }
        if(!($skip)){
            $userinput = Read-Host -Prompt "Press Enter to continue or q to exit"
            if($userinput -eq "q"){
                return
            }
        }
        [Console]::ResetColor()
        Clear-Host
    }

    Write-Verbose 'ShowOnPremMenu: Done'
}

Export-ModuleMember -Function 'ShowOnPremMenu'