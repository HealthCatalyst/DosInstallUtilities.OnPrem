# Modules

# Globals
. $PSScriptRoot\functions\Globals.ps1
. $PSScriptRoot\functions\WriteToConsole.ps1

# cluster
. $PSScriptRoot\functions\Cluster\ShowCommandToJoinCluster.ps1
. $PSScriptRoot\functions\Cluster\ShowKubernetesServiceStatus.ps1

# Dashboards
. $PSScriptRoot\functions\Dashboards\OpenKubernetesDashboard.ps1

# Fileshare
. $PSScriptRoot\functions\Fileshare\mountAzureFile.ps1
. $PSScriptRoot\functions\Fileshare\MountFolderFromSecrets.ps1
. $PSScriptRoot\functions\Fileshare\mountSharedFolder.ps1
. $PSScriptRoot\functions\Fileshare\mountSMB.ps1
. $PSScriptRoot\functions\Fileshare\mountSMBWithParams.ps1
. $PSScriptRoot\functions\Fileshare\ShowContentsOfSharedFolder.ps1
. $PSScriptRoot\functions\Fileshare\CreateOnPremStorage.ps1
. $PSScriptRoot\functions\Fileshare\DeleteOnPremStorage.ps1

# firewall
. $PSScriptRoot\functions\Firewall\ConfigureFirewall.ps1
. $PSScriptRoot\functions\Firewall\OpenPortOnPrem.ps1
. $PSScriptRoot\functions\Firewall\AddFirewallPort.ps1

# Hyperv
. $PSScriptRoot\functions\Hyperv\OptimizeCentosForHyperv.ps1

# Networking
. $PSScriptRoot\functions\Networking\TestDNS.ps1
. $PSScriptRoot\functions\Networking\TroubleshootNetworking.ps1

# Packages
. $PSScriptRoot\functions\Packages\lockPackageVersion.ps1
. $PSScriptRoot\functions\Packages\unlockPackageVersion.ps1

# SoftwareInstall
. $PSScriptRoot\functions\SoftwareInstall\SetupOnPremLoadBalancer.ps1
. $PSScriptRoot\functions\SoftwareInstall\SetupNewMasterNode.ps1
. $PSScriptRoot\functions\SoftwareInstall\SetupNewNode.ps1
. $PSScriptRoot\functions\SoftwareInstall\UninstallDockerAndKubernetes.ps1
. $PSScriptRoot\functions\SoftwareInstall\InstallDashboard.ps1
. $PSScriptRoot\functions\SoftwareInstall\GenerateCertificates.ps1
. $PSScriptRoot\functions\SoftwareInstall\InstallHelmOnPrem.ps1

# Troubleshooting
. $PSScriptRoot\functions\Troubleshooting\showTroubleshootingMenu.ps1

# Main files
. $PSScriptRoot\functions\ShowOnPremMenu.ps1
. $PSScriptRoot\functions\SetupMaster.ps1
. $PSScriptRoot\functions\SetupWorker.ps1
