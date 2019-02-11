<#
.SYNOPSIS
SetupNewMasterNode

.DESCRIPTION
SetupNewMasterNode

.INPUTS
SetupNewMasterNode - The name of SetupNewMasterNode

.OUTPUTS
None

.EXAMPLE
SetupNewMasterNode

.EXAMPLE
SetupNewMasterNode


#>
function SetupNewMasterNode()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
    )

    Write-Verbose 'SetupNewMasterNode: Starting'

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases", "", Justification="We're calling linux commands")]

    [hashtable]$Return = @{}

    [string] $u = "$(whoami)"
    Write-Host "User name: $u"

    # for calico network plugin
    # Write-Host "running kubeadm init for calico"
    # sudo kubeadm init --kubernetes-version=v1.9.6 --pod-network-cidr=10.244.0.0/16 --feature-gates CoreDNS=true

    # CLUSTER_DNS_CORE_DNS="true"

    $kubernetesImagesversion = $globals.kubernetesImagesversion

    sudo kubeadm config images pull --kubernetes-version=v${kubernetesImagesversion} --v 9
    $result = $LastExitCode
    if($result -ne 0){
        throw "kubeadm config: $result"
    }

    $globals
    # Write-Host "running kubeadm init for flannel"
    # for flannel network plugin
    # sudo kubeadm init --kubernetes-version=v${kubernetesversion} --pod-network-cidr=10.244.0.0/16 --feature-gates CoreDNS=true
    # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
    sudo kubeadm init `
            --kubernetes-version=v${kubernetesImagesversion} `
            --pod-network-cidr=10.244.0.0/16 `
            --skip-token-print `
            --v 1 `
            --apiserver-cert-extra-sans $(hostname --fqdn)

    $result = $LastExitCode
    if($result -ne 0){
        Write-Host $result
        throw "Error running kubeadm init: $result"
    }

    Write-Host "Troubleshooting kubeadm: https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/"

    # which CNI plugin to use: https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/

    # for logs, sudo journalctl -xeu kubelet

    Write-Host "copying kube config to $HOME/.kube/config"
    mkdir -p $HOME/.kube
    sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    Write-Host "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    sudo chown "$(id -u):$(id -g)" $HOME/.kube/config

    # calico
    # from https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/
    # Write-Host "enabling calico network plugin"
    # http://leebriggs.co.uk/blog/2017/02/18/kubernetes-networking-calico.html
    # kubectl apply -f ${baseUrl}/kubernetes/cni/calico.yaml

    # flannel
    # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
    Write-Host "enabling flannel network plugin"
    # kubectl apply -f ${baseUrl}/kubernetes/cni/flannel.yaml
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    Write-Host "sleeping 10 secs to wait for pods"
    Start-Sleep 10

    Write-Host "adding cni0 network interface to trusted zone"
    sudo firewall-cmd --zone=trusted --add-interface cni0 --permanent
    # sudo firewall-cmd --zone=trusted --add-interface docker0 --permanent
    sudo firewall-cmd --reload

    Write-Host "kubelet status"
    sudo systemctl status kubelet -l
    $result = $LastExitCode
    if($result -ne 0){
        throw "systemctl status kubelet: $result"
    }

    # enable master to run containers
    # kubectl taint nodes --all node-role.kubernetes.io/master-

    # kubectl create -f "${baseUrl}/azure/cafe-kube-dns.yml"
    Write-Host "nodes"
    kubectl get nodes
    $result = $LastExitCode
    if($result -ne 0){
        throw "kubectl get nodes: $result"
    }
    Write-Host "sleep for 10 secs"
    Start-Sleep 10

    Write-Host "current pods"
    kubectl get pods -n kube-system -o wide

    Write-Host "waiting for pods to run"
    WaitForPodsInNamespace kube-system 5

    Write-Host "current pods"
    kubectl get pods -n kube-system -o wide

    if (!(Test-Path C:\Windows -PathType Leaf)) {
        Write-Host "creating /mnt/data"
        sudo mkdir -p "/mnt/data"
        Write-Host "sudo chown $(id -u):$(id -g) /mnt/data"
        sudo chown "$(id -u):$(id -g)" "/mnt/data"
        sudo chmod -R 777 "/mnt/data"
    }

    AddFirewallPort -port "6661/tcp" -name "Mirth"
    AddFirewallPort -port "5671/tcp" -name "RabbitMq"
    AddFirewallPort -port "3307/tcp" -name "MySql"

    Write-Host "reloading firewall"
    sudo firewall-cmd --reload

    Write-Host "enabling autocomplete for kubectl"
    echo "source <(kubectl completion bash)" >> ~/.bashrc

    Write-Verbose 'SetupNewMasterNode: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupNewMasterNode'