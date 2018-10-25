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
    WriteToLog "User name: $u"

    # for calico network plugin
    # WriteToLog "running kubeadm init for calico"
    # sudo kubeadm init --kubernetes-version=v1.9.6 --pod-network-cidr=10.244.0.0/16 --feature-gates CoreDNS=true

    # CLUSTER_DNS_CORE_DNS="true"

    sudo kubeadm config images pull --kubernetes-version=v${$($globals.kubernetesserverversion)} --v 9

    $globals
    # WriteToLog "running kubeadm init for flannel"
    # for flannel network plugin
    # sudo kubeadm init --kubernetes-version=v${kubernetesversion} --pod-network-cidr=10.244.0.0/16 --feature-gates CoreDNS=true
    # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
    sudo kubeadm init `
            --kubernetes-version=v${$($globals.kubernetesserverversion)} `
            --pod-network-cidr=10.244.0.0/16 `
            --skip-token-print `
            --v 9 `
            --apiserver-cert-extra-sans $(hostname --fqdn)

    $result = $LastExitCode
    if($result -ne 0){
        WriteToLog $result
        throw "Error running kubeadm init: $result"
    }

    WriteToLog "Troubleshooting kubeadm: https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/"

    # which CNI plugin to use: https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/

    # for logs, sudo journalctl -xeu kubelet

    WriteToLog "copying kube config to $HOME/.kube/config"
    mkdir -p $HOME/.kube
    sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    WriteToLog "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    sudo chown "$(id -u):$(id -g)" $HOME/.kube/config

    # calico
    # from https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/
    # WriteToLog "enabling calico network plugin"
    # http://leebriggs.co.uk/blog/2017/02/18/kubernetes-networking-calico.html
    # kubectl apply -f ${baseUrl}/kubernetes/cni/calico.yaml

    # flannel
    # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
    WriteToLog "enabling flannel network plugin"
    kubectl apply -f ${baseUrl}/kubernetes/cni/flannel.yaml

    WriteToLog "sleeping 10 secs to wait for pods"
    Start-Sleep 10

    WriteToLog "adding cni0 network interface to trusted zone"
    sudo firewall-cmd --zone=trusted --add-interface cni0 --permanent
    # sudo firewall-cmd --zone=trusted --add-interface docker0 --permanent
    sudo firewall-cmd --reload

    WriteToLog "kubelet status"
    sudo systemctl status kubelet -l

    # enable master to run containers
    # kubectl taint nodes --all node-role.kubernetes.io/master-

    # kubectl create -f "${baseUrl}/azure/cafe-kube-dns.yml"
    WriteToLog "nodes"
    kubectl get nodes

    WriteToLog "sleep for 10 secs"
    Start-Sleep 10

    WriteToLog "current pods"
    kubectl get pods -n kube-system -o wide

    WriteToLog "waiting for pods to run"
    WaitForPodsInNamespace kube-system 5

    WriteToLog "current pods"
    kubectl get pods -n kube-system -o wide

    if (!(Test-Path C:\Windows -PathType Leaf)) {
        WriteToLog "creating /mnt/data"
        sudo mkdir -p "/mnt/data"
        WriteToLog "sudo chown $(id -u):$(id -g) /mnt/data"
        sudo chown "$(id -u):$(id -g)" "/mnt/data"
        sudo chmod -R 777 "/mnt/data"
    }

    AddFirewallPort -port "6661/tcp" -name "Mirth"
    AddFirewallPort -port "5671/tcp" -name "RabbitMq"
    AddFirewallPort -port "3307/tcp" -name "MySql"

    WriteToLog "reloading firewall"
    sudo firewall-cmd --reload

    WriteToLog "enabling autocomplete for kubectl"
    echo "source <(kubectl completion bash)" >> ~/.bashrc

    Write-Verbose 'SetupNewMasterNode: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupNewMasterNode'