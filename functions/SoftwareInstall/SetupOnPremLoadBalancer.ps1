<#
.SYNOPSIS
SetupOnPremLoadBalancer

.DESCRIPTION
SetupOnPremLoadBalancer

.INPUTS
SetupOnPremLoadBalancer - The name of SetupOnPremLoadBalancer

.OUTPUTS
None

.EXAMPLE
SetupOnPremLoadBalancer

.EXAMPLE
SetupOnPremLoadBalancer


#>
function SetupOnPremLoadBalancer() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
    )

    Write-Verbose 'SetupOnPremLoadBalancer: Starting'

    Set-StrictMode -Version latest
    # stop whenever there is an error
    $ErrorActionPreference = "Stop"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases", "", Justification="We're calling linux commands")]

    [hashtable]$Return = @{}

    WriteToConsole "deleting any old resources"
    # enable running pods on master
    # kubectl taint node mymasternode node-role.kubernetes.io/master:NoSchedule
    Write-Host "deleting existing resources with label traefik"
    kubectl delete 'pods,services,configMaps,deployments,ingress' -l k8s-traefik=traefik -n kube-system --ignore-not-found=true

    Write-Host "deleting existing service account for traefik"
    kubectl delete ServiceAccount traefik-ingress-controller-serviceaccount -n kube-system --ignore-not-found=true

    AskForSecretValue -secretname "customerid" -prompt "Customer ID "
    Write-Host "reading secret from kubernetes"
    $customerid = $(ReadSecretValue -secretname "customerid" -namespace "default")

    $fullhostname = $(hostname --fqdn)
    Write-Host "Full host name of current machine: $fullhostname"
    AskForSecretValue -secretname "dnshostname" -prompt "DNS name used to connect to the master VM (leave empty to use $fullhostname)" -namespace "default" -defaultvalue $fullhostname
    $dnsrecordname = $(ReadSecretValue -secretname "dnshostname" -namespace "default")

    [string] $secret = "certpassword"
    [string] $namespace = "default"
    [string] $certPassword = $(GenerateSecretPassword -secretname "$secret" -namespace "$namespace").Password
    GenerateCertificates -CertHostName "$dnsrecordname" -CertPassword $certPassword

    Write-Host "installing helm"
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh

    InitHelm

    [string] $package = "nginx"
    [string] $packageInternal = "nginx-internal"
    [string] $ngniximageTag = $globals.ngniximageTag

    Write-Output "Removing old deployment"
    helm del --purge $package
    helm del --purge $packageInternal

    Start-Sleep -Seconds 5

    # nginx configuration: https://github.com/helm/charts/tree/master/stable/nginx-ingress#configuration

    Write-Verbose "Installing the public nginx load balancer"
    helm install stable/nginx-ingress `
        --namespace "kube-system" `
        --name "$package" `
        --set controller.service.type="ClusterIP" `
        --set controller.hostNetwork=true `
        --set controller.image.tag="$ngniximageTag" `
        --set controller.extraArgs.default-ssl-certificate="kube-system/fabric-ssl-cert" `
        --set controller.extraArgs.v=3 `
        --debug `
        --wait

    # setting values in helm: https://github.com/helm/helm/blob/master/docs/chart_best_practices/values.md
    # and https://github.com/helm/helm/blob/master/docs/using_helm.md
    # use "helm inspect values" to see values

    # Write-Verbose "Installing the internal nginx load balancer"
    # # NOTE: helm cannot handle spaces before or after "=" in --set command
    # helm install stable/nginx-ingress `
    #     --namespace "kube-system" `
    #     --name "$packageInternal" `
    #     --set controller.service.type="ClusterIP" `
    #     --set controller.hostNetwork=true `
    #     --set controller.image.tag="$ngniximageTag"

    Write-Verbose 'SetupOnPremLoadBalancer: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupOnPremLoadBalancer'