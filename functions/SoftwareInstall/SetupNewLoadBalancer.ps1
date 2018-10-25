<#
.SYNOPSIS
SetupNewLoadBalancer

.DESCRIPTION
SetupNewLoadBalancer

.INPUTS
SetupNewLoadBalancer - The name of SetupNewLoadBalancer

.OUTPUTS
None

.EXAMPLE
SetupNewLoadBalancer

.EXAMPLE
SetupNewLoadBalancer


#>
function SetupNewLoadBalancer()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
    )

    Write-Verbose 'SetupNewLoadBalancer: Starting'

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

    $sslsecret = $(kubectl get secret traefik-cert-ahmn -n kube-system --ignore-not-found=true)

    if (!$sslsecret) {
        $certfolder = Read-Host -Prompt "Location of SSL cert files (tls.crt and tls.key): (leave empty to generate self-signed certificates)"

        if (!$certfolder) {
            Write-Host "Generating self-signed SSL certificate"
            sudo yum -y install openssl
            $u = "$(whoami)"
            $certfolder = "/opt/healthcatalyst/certs"
            Write-Host "Creating folder: $certfolder and giving access to $u"
            sudo mkdir -p "$certfolder"
            sudo setfacl -m u:$u:rwx "$certfolder"
            rm -rf "$certfolder/*"
            cd "$certfolder"
            # https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309
            Write-Host "Generating CA cert"
            sudo openssl genrsa -out rootCA.key 2048
            sudo openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -subj /CN=HCKubernetes/O=HealthCatalyst/ -out rootCA.crt
            Write-Host "Generating certificate for $dnsrecordname"
            sudo openssl genrsa -out tls.key 2048
            sudo openssl req -new -key tls.key -subj /CN=$dnsrecordname/O=HealthCatalyst/ -out tls.csr
            sudo openssl x509 -req -in tls.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out tls.crt -days 3650 -sha256
            sudo cp tls.crt tls.pem
            cd "~"
        }

        ls -al "$certfolder"

        Write-Host "Deleting any old TLS certs"
        kubectl delete secret traefik-cert-ahmn -n kube-system --ignore-not-found=true

        Write-Host "Storing TLS certs as kubernetes secret"
        kubectl create secret generic traefik-cert-ahmn -n kube-system --from-file="$certfolder/tls.crt" --from-file="$certfolder/tls.key"
    }

    $ingressInternalType = "public"
    $ingressExternalType = "onprem"
    $externalIp = ""
    $internalIp = ""

    # LoadLoadBalancerStack -baseUrl $baseUrl -ssl 1 -customerid $customerid `
    #                     -ingressInternalType $ingressInternalType -ingressExternalType $ingressExternalType `
    #                     -isOnPrem $true `
    #                     -externalSubnetName "" -externalIp "$externalIp" `
    #                     -internalSubnetName "" -internalIp "$internalIp" `
    #                     -local $False

    Write-Host "installing helm"
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh

    helm init --client-only

    # https://zero-to-jupyterhub.readthedocs.io/en/stable/setup-helm.html
    kubectl --namespace kube-system create serviceaccount tiller

    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

    helm init --service-account tiller

    helm init --upgrade --service-account tiller

    [string] $package = "nginx"
    [string] $packageInternal = "nginx-internal"
    [string] $ngniximageTag = "0.20.0"

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
        --set controller.image.tag="$ngniximageTag"

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

        Write-Verbose 'SetupNewLoadBalancer: Done'

        return $Return
}

Export-ModuleMember -Function 'SetupNewLoadBalancer'