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

    DeleteHelmPackage -package kubernetes-dashboard;
    DeleteHelmPackage -package heapster-release;
    Start-Sleep -Seconds 5

    helm install stable/heapster `
        --name heapster-release `
        --namespace kube-system `
        --set rbac.create=true `
        --debug `
        --wait --timeout 30


    [string] $dashboardUser = $(Get-UserForDashboard)
    kubectl create serviceaccount $dashboardUser -n kube-system
    kubectl create clusterrolebinding kubernetes-dashboard-user --clusterrole=cluster-admin --serviceaccount=kube-system:$dashboardUser

    # kubectl create clusterrolebinding kubernetes-dashboard-user --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
    # $serviceAccount = "kubernetes-dashboard-service-account"
    # kubectl create serviceaccount $serviceAccount

    # Write-Host "Giving permissions to the kubernetes-dashboard service"
    # kubectl create clusterrolebinding kubernetes-dashboard-service --clusterrole=cluster-admin --serviceaccount=kube-system:$serviceAccount

    # https://github.com/kubernetes/dashboard/wiki/Dashboard-arguments

    [string] $dnshostname = $(ReadSecretValue -secretname "dnshostname" -namespace "default")
    AssertStringIsNotNull -text $dnshostname

    helm install stable/kubernetes-dashboard `
        --name kubernetes-dashboard `
        --namespace kube-system `
        --set rbac.create=true `
        --set ingress.enabled=true `
        --set-string ingress.path='"/ui"' `
        --set extraArgs="{--api-log-level\=DEBUG}" `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/secure-backends"='"true"' `
        --set-string ingress.annotations."kubernetes\.io/ingress\.class"='"nginx"' `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/rewrite-target"='"/"' `
        --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/add-base-url"='"true"' `
        --debug `
        --wait

#        --set ingress.tls[0].hosts="{$dnshostname}" `
#        --set ingress.tls[0].secretName=fabric-ssl-cert `
#       --set ingress.hosts="{$dnshostname}" `
#       --set ingress.http.paths[0].path="/ui" `

    Write-Verbose 'InstallDashboard: Done'

}

Export-ModuleMember -Function 'InstallDashboard'