<#
.SYNOPSIS
TroubleshootNetworking

.DESCRIPTION
TroubleshootNetworking

.INPUTS
TroubleshootNetworking - The name of TroubleshootNetworking

.OUTPUTS
None

.EXAMPLE
TroubleshootNetworking

.EXAMPLE
TroubleshootNetworking


#>
function TroubleshootNetworking()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'TroubleshootNetworking: Starting'

    # https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/3/
    WriteToConsole " open ports "
    sudo nmap 127.0.0.1
    WriteToConsole "network interfaces "
    sudo ip link show
    WriteToConsole "services enabled in firewall"
    sudo firewall-cmd --list-services
    WriteToConsole "ports enabled in firewall"
    sudo firewall-cmd --list-ports
    WriteToConsole "active zones"
    sudo firewall-cmd --get-active-zones
    WriteToConsole "available services to enable"
    sudo firewall-cmd --get-services
    WriteToConsole "all rules in firewall"
    sudo firewall-cmd --list-all
    sudo firewall-cmd --zone trusted --list-all
    WriteToConsole "iptables --list"
    sudo iptables --list
    WriteToConsole "checking DNS server "
    $ipfordnsservice = $(kubectl get svc kube-dns -n kube-system -o jsonpath="{.spec.clusterIP}")
    sudo dig "@${ipfordnsservice}" kubernetes.default.svc.cluster.local +noall +answer
    sudo dig "@${ipfordnsservice}" ptr 1.0.96.10.in-addr.arpa. +noall +answer
    WriteToConsole "recent rejected packets "
    sudo tail --lines 1000 /var/log/messages | grep REJECT

    Write-Verbose 'TroubleshootNetworking: Done'

}

Export-ModuleMember -Function 'TroubleshootNetworking'