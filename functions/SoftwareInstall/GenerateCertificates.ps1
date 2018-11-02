<#
.SYNOPSIS
GenerateCertificates

.DESCRIPTION
GenerateCertificates

.INPUTS
GenerateCertificates - The name of GenerateCertificates

.OUTPUTS
None

.EXAMPLE
GenerateCertificates

.EXAMPLE
GenerateCertificates


#>
function GenerateCertificates() {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertHostName
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertPassword
    )

    Write-Verbose 'GenerateCertificates: Starting'

    Set-StrictMode -Version latest
    # stop whenever there is an error
    $ErrorActionPreference = "Stop"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases", "", Justification = "We're calling linux commands")]

    $sslsecret = $(kubectl get secret fabric-ssl-cert -n kube-system --ignore-not-found=true)

    if (!$sslsecret) {
        $certfolder = Read-Host -Prompt "Location of SSL cert files (tls.crt and tls.key): (leave empty to generate self-signed certificates)"

        if (!$certfolder) {
            $ClientCertUser = "fabricrabbitmquser"
            $certfolder = "/opt/healthcatalyst/certs"

            Write-Host "Generating self-signed SSL certificate"
            $u = "$(whoami)"
            Write-Host "Creating folder: $certfolder and giving access to $u"
            sudo mkdir -p "$certfolder"
            sudo setfacl -m u:$u:rwx "$certfolder"
            cd "$certfolder"
            Write-Host "Cleaning out the folder"
            sudo rm -rf *
            echo "------- $certfolder ------"
            ls -al "$certfolder"
            echo "---------------------------"

            Write-Host "Running docker container, fabric.docker.certificategenerator, to generate certificates"
            docker pull healthcatalyst/fabric.docker.certificategenerator
            docker run --rm -v ${certfolder}:/opt/certs/ `
                -e CERT_HOSTNAME="$CertHostName" `
                -e CERT_PASSWORD="$CertPassword" `
                -e CLIENT_CERT_USER="$ClientCertUser" `
                --name fabric.docker.certificategenerator `
                -t healthcatalyst/fabric.docker.certificategenerator

            echo "------- $certfolder/testca ------"
            ls -al "$certfolder/testca"
            echo "---------------------------"
            echo "------- $certfolder/server ------"
            ls -al "$certfolder/server"
            echo "---------------------------"
            echo "------- $certfolder/client ------"
            ls -al "$certfolder/client"
            echo "---------------------------"

            # https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309
            kubectl delete secret fabric-ca-cert -n kube-system --ignore-not-found=true
            kubectl create secret tls fabric-ca-cert -n kube-system --key "testca/rootCA.key" --cert "testca/rootCA.crt"

            kubectl delete secret fabric-client-cert -n kube-system --ignore-not-found=true
            kubectl create secret tls fabric-client-cert -n kube-system --key "client/client.key" --cert "client/client.crt"

            sudo cp testca/rootCA.p12 fabric_ca_cert.p12
            sudo cp client/client.p12 fabricrabbitmquser_client_cert.p12
            kubectl delete secret fabric-ssl-download-cert -n kube-system --ignore-not-found=true
            kubectl create secret generic fabric-ssl-download-cert -n kube-system `
                --from-file="fabric_ca_cert.p12" `
                --from-file="fabricrabbitmquser_client_cert.p12"

            # remove *.csr, *.key, *.crt, *.srl

            cd "~"

            $certfolder = "$certfolder/server"
        }
        else {
            Write-Host "TLS files specified so using then"
        }

        echo "------ $certfolder ------"
        ls -al "$certfolder"
        echo "------------------------"

        Write-Host "Deleting any old TLS certs"
        kubectl delete secret fabric-ssl-cert -n kube-system --ignore-not-found=true

        Write-Host "Storing TLS certs as kubernetes secret"
        kubectl create secret tls fabric-ssl-cert -n kube-system --key "$certfolder/tls.key" --cert "$certfolder/tls.crt"

        # kubectl create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs -n kube-system

        CreateNamespaceIfNotExists -namespace "kube-system"

        # copy secrets to fabricrealtime namespace
        [string] $secretName = "fabric-ca-cert"
        kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace=fabricrealtime -f -
        [string] $secretName = "fabric-ssl-cert"
        kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace=fabricrealtime -f -
        [string] $secretName = "fabric-client-cert"
        kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace=fabricrealtime -f -
        [string] $secretName = "fabric-ssl-download-cert"
        kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace=fabricrealtime -f -
    }
    else {
        Write-Host "Secret fabric-ssl-cert already set so using it"
    }

    Write-Verbose 'GenerateCertificates: Done'
}

Export-ModuleMember -Function 'GenerateCertificates'