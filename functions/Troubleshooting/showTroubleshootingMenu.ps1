<#
.SYNOPSIS
showTroubleshootingMenu

.DESCRIPTION
showTroubleshootingMenu

.INPUTS
showTroubleshootingMenu - The name of showTroubleshootingMenu

.OUTPUTS
None

.EXAMPLE
showTroubleshootingMenu

.EXAMPLE
showTroubleshootingMenu


#>
function showTroubleshootingMenu()
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
        ,
        [bool]
        $isAzure
    )

    Write-Verbose 'showTroubleshootingMenu: Starting'

    $userinput = ""
    while ($userinput -ne "q") {
        Write-Host "================ Troubleshooting menu ================"
        Write-Host "0: Show status of cluster"
        Write-Host "-----  Kubernetes ------"
        Write-Host "1: Open Kubernetes dashboard"
        Write-Host "2: Troubleshoot networking"
        Write-Host "3: Test DNS"
        Write-Host "4: Show contents of shared folder"
        Write-Host "5: Show kubernetes service status"
        Write-Host "6: Troubleshoot Ingresses"
        Write-Host "7: Show logs of all pods in kube-system"
        Write-Host "8: Show logs of the load balancer"
        Write-Host "9: Show logs of the dashboard"
        Write-Host "----- Reinstall ------"
        Write-Host "12: Change SSL certificate"
        Write-Host "13: Reinstall Load Balancer"
        Write-Host "14: Reinstall Dashboard"
        Write-Host "------ Other tasks ---- "
        Write-Host "31: Create a Single Node Cluster"
        Write-Host "32: Mount folder"
        Write-Host "33: Create kubeconfig"
        Write-Host "--- helpers ---"
        Write-Host "41: Optimize Centos under Hyper-V"
        Write-Host "q: Go back to main menu"
        $userinput = Read-Host "Please make a selection"
        switch ($userinput) {
            '0' {
                ShowStatusOfCluster
            }
            '1' {
                if ($isAzure) {
                    LaunchAzureKubernetesDashboard
                }
                else {
                    OpenKubernetesDashboard
                }
            }
            '2' {
                TroubleshootNetworking
            }
            '3' {
                TestDNS $baseUrl
            }
            '4' {
                ShowContentsOfSharedFolder
            }
            '5' {
                ShowKubernetesServiceStatus
            }
            '6' {
                troubleshootIngress "kube-system"
            }
            '7' {
                ShowLogsOfAllPodsInNameSpace "kube-system"
            }
            '8' {
                kubectl logs -l "app=nginx-ingress" -n kube-system
            }
            '9' {
                kubectl logs -l "app=kubernetes-dashboard" -n kube-system
            }
            '12' {
                ChangeSslCertificate
            }
            '13' {
                SetupOnPremLoadBalancer
            }
            '14' {
                InstallDashboard
            }
            '31' {
                SetupMaster -baseUrl $baseUrl -singlenode $true
            }
            '32' {
                mountSharedFolder -saveIntoSecret $true
            }
            '33' {
                GenerateKubeConfigFile
            }
            '41' {
                OptimizeCentosForHyperv
            }
            'q' {
                return
            }
        }
        $userinput = Read-Host -Prompt "Press Enter to continue or q to go back to top menu"
        if ($userinput -eq "q") {
            return
        }
        [Console]::ResetColor()
        Clear-Host
    }

    Write-Verbose 'showTroubleshootingMenu: Done'

}

Export-ModuleMember -Function 'showTroubleshootingMenu'