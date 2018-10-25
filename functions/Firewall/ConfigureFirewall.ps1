<#
.SYNOPSIS
ConfigureFirewall

.DESCRIPTION
ConfigureFirewall

.INPUTS
ConfigureFirewall - The name of ConfigureFirewall

.OUTPUTS
None

.EXAMPLE
ConfigureFirewall

.EXAMPLE
ConfigureFirewall


#>
function ConfigureFirewall()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'ConfigureFirewall: Starting'

    [hashtable]$Return = @{}

    Write-Host " installing firewalld"
    # https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7
    sudo yum -y install firewalld
    Write-Host "starting firewalld"
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo systemctl status firewalld -l
    Write-Host "removing iptables"
    sudo yum -y remove iptables-services

    Write-Host "Making sure the main network interface is in public zone"
    $primarynic = $(route | grep default | awk '{print $NF; ext }')
    Write-Host "Found primary network interface: $primarynic"
    if ($primarynic) {
        $zoneforprimarynic = $(sudo firewall-cmd --get-zone-of-interface="$primarynic")
        if (!$zoneforprimarynic) {
            Write-Host "Primary network interface, $primarynic, was not in any zone so adding it to public zone"
            sudo firewall-cmd --zone=public --add-interface "$primarynic"
            sudo firewall-cmd --permanent --zone=public --add-interface="$primarynic"
            sudo firewall-cmd --reload
        }
        else {
            Write-Host "Primary network interface, $primarynic, is in $zoneforprimarynic zone"
        }
    }

    Write-Host "enabling ports in firewalld"
    # https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/3/
    # kubernetes ports: https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports
    # https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/kubernetes-networking.md
    # https://github.com/coreos/tectonic-docs/blob/master/Documentation/install/rhel/installing-workers.md
    AddFirewallPort -port "22/tcp" -name "SSH"
    AddFirewallPort -port "6443/tcp" -name "Kubernetes API server"
    AddFirewallPort -port "80/tcp" -name "HTTP"
    AddFirewallPort -port "443/tcp" -name "HTTPS"
    AddFirewallPort -port "2379-2380/tcp" -name "Flannel networking"
    AddFirewallPort -port "8472/udp" -name "Flannel networking"
    AddFirewallPort -port "8285/udp" -name "Flannel networking"
    AddFirewallPort -port "4789/udp" -name "Flannel networking"
    AddFirewallPort -port "10250-10255/tcp" -name "Kubelet API"
    # Write-Host "Opening port 53 for internal DNS"
    # AddFirewallPort -port "443/tcp" -name "DNS"
    # sudo firewall-cmd --add-port=53/udp --permanent # DNS
    # AddFirewallPort -port "443/tcp" -name "HTTPS"
    # sudo firewall-cmd --add-port=53/tcp --permanent # DNS
    # AddFirewallPort -port "443/tcp" -name "HTTPS"
    # sudo firewall-cmd --add-port=67/udp --permanent # DNS
    # AddFirewallPort -port "443/tcp" -name "HTTPS"
    # sudo firewall-cmd --add-port=68/udp --permanent # DNS
    # # sudo firewall-cmd --add-port=30000-60000/udp --permanent # NodePort services
    # sudo firewall-cmd --add-service=dns --permanent # DNS
    # Write-Host "Adding NTP service to firewall"
    sudo firewall-cmd --add-service=ntp --permanent # NTP server
    Write-Host "enable all communication between pods"
    # sudo firewall-cmd --zone=trusted --add-interface eth0
    # sudo firewall-cmd --set-default-zone=trusted
    # sudo firewall-cmd --get-zone-of-interface=docker0
    # sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0

    # https://basildoncoder.com/blog/logging-connections-with-firewalld.html
    # sudo firewall-cmd --zone=public --add-rich-rule="rule family="ipv4" source address="198.51.100.0/32" port protocol="tcp" port="10000" log prefix="test-firewalld-log" level="info" accept"
    # sudo tail -f /var/log/messages |grep test-firewalld-log

    # Write-Host "log dropped packets"
    # sudo firewall-cmd  --set-log-denied=all

    # flannel settings
    # from https://github.com/kubernetes/contrib/blob/master/ansible/roles/flannel/tasks/firewalld.yml
    # Write-Host "Open flanneld subnet traffic"
    # sudo firewall-cmd --direct --add-rule ipv4 filter FORWARD 1 -i flannel.1 -j ACCEPT -m comment --comment "flannel subnet"

    # Write-Host "Save flanneld subnet traffic"
    # sudo firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 1 -i flannel.1 -j ACCEPT -m comment --comment "flannel subnet"

    # Write-Host "Open flanneld to DNAT'ed traffic"
    # sudo firewall-cmd --direct --add-rule ipv4 filter FORWARD 1 -o flannel.1 -j ACCEPT -m comment --comment "flannel subnet"

    # Write-Host "Save flanneld to DNAT'ed traffic"
    # sudo firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 1 -o flannel.1 -j ACCEPT -m comment --comment "flannel subnet"

    Write-Host "enable logging of rejected packets"
    sudo firewall-cmd --set-log-denied=all

    # http://wrightrocket.blogspot.com/2017/11/installing-kubernetes-on-centos-7-with.html
    Write-Host "reloading firewall"
    sudo firewall-cmd --reload

    sudo systemctl status firewalld -l

    Write-Host "services enabled in firewall"
    sudo firewall-cmd --list-services
    Write-Host "ports enabled in firewall"
    sudo firewall-cmd --list-ports

    sudo firewall-cmd --list-all

    Write-Verbose 'ConfigureFirewall: Done'

    return $Return
}

Export-ModuleMember -Function 'ConfigureFirewall'