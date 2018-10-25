<#
.SYNOPSIS
SetupNewNode

.DESCRIPTION
SetupNewNode

.INPUTS
SetupNewNode - The name of SetupNewNode

.OUTPUTS
None

.EXAMPLE
SetupNewNode

.EXAMPLE
SetupNewNode


#>
function SetupNewNode()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
    )

    Write-Verbose 'SetupNewNode: Starting'

    [hashtable]$Return = @{}

    WriteToLog "checking if this machine can access a DNS server via host $(hostname)"
    WriteToLog "/etc/resolv.conf"
    sudo cat /etc/resolv.conf
    WriteToLog "----------------------------"

    $myip = $(host $(hostname) | awk '/has address/ { print $4 ; exit }')

    if (!$myip) {
        throw "Cannot access my DNS server: host $(hostname)"
        WriteToLog "Cannot access my DNS server: host $(hostname)"
        WriteToLog "checking if this machine can access a DNS server via host $(hostname)"
        $myip = $(hostname -I | cut -d" " -f 1)
        if ($myip) {
            WriteToLog "Found an IP via hostname -I: $myip"
        }
    }
    else {
        WriteToLog "My external IP is $myip"
    }

    # $(export dockerversion="17.03.2.ce-1")
    # $(export kubernetesversion="1.9.6-0")
    # 1.9.3-0
    # 1.9.6-0
    # 1.10.0-0
    # $(export kubernetescniversion="0.6.0-0")

    WriteToLog "using docker version ${$($globals.dockerversion)}, kubernetes version ${$($globals.kubernetesversion)}, cni version ${$($globals.kubernetescniversion)}"

    $u = "$(whoami)"
    WriteToLog "User name: $u"


    ConfigureFirewall
    # ConfigureIpTables

    WriteToConsole "starting NTP deamon"
    # https://www.tecmint.com/install-ntp-server-in-centos/
    sudo systemctl start ntpd
    sudo systemctl enable ntpd
    sudo systemctl status ntpd -l

    # WriteToConsole "stopping docker and kubectl"
    # $servicestatus = $(systemctl show -p SubState kubelet)
    # if [[ $servicestatus = *"running"* ]]; then
    # WriteToLog "stopping kubelet"
    # sudo systemctl stop kubelet
    # fi

    # remove older versions
    UninstallDockerAndKubernetes

    WriteToConsole "Adding docker repo "
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    WriteToConsole " current repo list"
    sudo yum -y repolist

    WriteToConsole "docker versions available in repo "
    sudo yum -y --showduplicates list docker-ce
    sudo yum -y --showduplicates list docker-ce-selinux

    # https://saurabh-deochake.github.io/posts/2017/07/post-1/
    WriteToConsole "setting selinux to disabled so kubernetes can work"
    sudo setenforce 0
    sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    # sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

    WriteToConsole "Installing docker via yum "
    WriteToLog "using docker version ${$($globals.dockerversion)}, kubernetes version ${$($globals.kubernetesversion)}, cni version ${$($globals.kubernetescniversion)}"
    # need to pass --setpot=obsoletes=0 due to this bug: https://github.com/docker/for-linux/issues/20#issuecomment-312122325

    sudo yum install -y --setopt=obsoletes=0 docker-ce-${$($globals.dockerversion)}.el7.centos docker-ce-selinux-${$($globals.dockerselinuxversion)}.el7.centos

    # installYumPackages "docker-ce-${dockerversion}.el7.centos docker-ce-selinux-${dockerversion}.el7.centos"
    lockPackageVersion "docker-ce docker-ce-selinux"

    # https://kubernetes.io/docs/setup/independent/install-kubeadm/
    # log rotation for docker: https://docs.docker.com/config/daemon/
    # https://docs.docker.com/config/containers/logging/json-file/
    WriteToConsole "Configuring docker to use systemd and set logs to max size of 10MB and 5 days "
    sudo mkdir -p /etc/docker
    sudo curl -sSL -o /etc/docker/daemon.json ${baseUrl}/onprem/daemon.json?p=1

    WriteToConsole "Starting docker service "
    sudo systemctl enable docker
    sudo systemctl start docker

    if ($u -ne "root") {
        WriteToConsole "Giving permission to $u to interact with docker"
        sudo usermod -aG docker $u
        # reload permissions without requiring a logout
        # from https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
        # https://man.cx/newgrp(1)
        # WriteToConsole "Reloading permissions via newgrp"
        # newgrp docker
    }

    WriteToLog "using docker version ${$($globals.dockerversion)}, kubernetes version ${$($globals.kubernetesversion)}, cni version ${$($globals.kubernetescniversion)}"

    WriteToLog "docker status"
    sudo systemctl status docker -l

    WriteToConsole "Adding kubernetes repo"
    sudo yum-config-manager --add-repo ${baseUrl}/onprem/kubernetes.repo

    WriteToConsole "checking to see if port 10250 is still busy"
    sudo lsof -i -P -n | grep LISTEN

    WriteToConsole "kubernetes versions available in repo"
    sudo yum -y --showduplicates list kubelet kubeadm kubectl kubernetes-cni

    WriteToConsole "installing kubernetes"
    WriteToLog "using docker version ${$($globals.dockerversion)}, kubernetes version ${$($globals.kubernetesversion)}, cni version ${$($globals.kubernetescniversion)}"

    sudo yum -y install kubelet-${$($globals.kubernetesversion)} kubeadm-${$($globals.kubernetesversion)} kubectl-${$($globals.kubernetesversion} kubernetes-cni-${kubernetescniversion)}

    lockPackageVersion "kubelet kubeadm kubectl kubernetes-cni"
    WriteToConsole "locking versions of kubernetes so they don't get updated by yum update"
    # sudo yum versionlock add kubelet
    # sudo yum versionlock add kubeadm
    # sudo yum versionlock add kubectl
    # sudo yum versionlock add kubernetes-cni

    WriteToLog "setting up iptables for kubernetes in k8s.conf"
    # # Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed
    sudo curl -o "/etc/sysctl.d/k8s.conf" -sSL "$baseUrl/onprem/k8s.conf"
    sudo sysctl --system

    WriteToConsole "starting kubernetes service"
    sudo systemctl enable kubelet
    sudo systemctl start kubelet

    WriteToConsole "finished setting up node"

    Write-Verbose 'SetupNewNode: Done'

    return $Return
}

Export-ModuleMember -Function 'SetupNewNode'