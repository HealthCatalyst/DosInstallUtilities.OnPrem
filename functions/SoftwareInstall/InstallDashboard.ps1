<#
.SYNOPSIS
InstallDashboard

.DESCRIPTION
InstallDashboard

.INPUTS
InstallDashboard - The name of InstallDashboard

.OUTPUTS
None

.EXAMPLE
InstallDashboard

.EXAMPLE
InstallDashboard


#>
function InstallDashboard()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'InstallDashboard: Starting'

    helm del --purge kubernetes-dashboard;
    helm del --purge heapster-release;
    Start-Sleep -Seconds 5

    helm install stable/heapster `
        --name heapster-release `
        --namespace kube-system `
        --set rbac.create=true `
        --wait --timeout 30


    [string] $dashboardUser = $(Get-UserForDashboard)
    kubectl create serviceaccount $dashboardUser
    kubectl create clusterrolebinding kubernetes-dashboard-user --clusterrole=cluster-admin --serviceaccount=kube-system:$dashboardUser

    # $serviceAccount = "kubernetes-dashboard-service-account"
    # kubectl create serviceaccount $serviceAccount

    # Write-Host "Giving permissions to the kubernetes-dashboard service"
    # kubectl create clusterrolebinding kubernetes-dashboard-service --clusterrole=cluster-admin --serviceaccount=kube-system:$serviceAccount

    helm install stable/kubernetes-dashboard `
        --name kubernetes-dashboard `
        --namespace kube-system `
        --set ingress.enabled=true `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/secure-backends"='"true"' `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/rewrite-target"='"/"' `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/add-base-url"='"true"' `
        --set-string ingress.path='"/dashboard"' `
        --wait

    Write-Verbose 'InstallDashboard: Done'

}

Export-ModuleMember -Function 'InstallDashboard'