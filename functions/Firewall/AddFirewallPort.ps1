<#
.SYNOPSIS
AddFirewallPort

.DESCRIPTION
AddFirewallPort

.INPUTS
AddFirewallPort - The name of AddFirewallPort

.OUTPUTS
None

.EXAMPLE
AddFirewallPort

.EXAMPLE
AddFirewallPort


#>
function AddFirewallPort() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $port
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $name
    )

    Write-Verbose 'AddFirewallPort: Starting'

    if ("$(sudo firewall-cmd --query-port=${port})" -ne "yes") {
        Write-Host "opening port $port for $name"
        sudo firewall-cmd --add-port=${port} --permanent
    }
    else {
        Write-Host "Port $port for $name is already open"
    }

    Write-Verbose 'AddFirewallPort: Done'
}

Export-ModuleMember -Function 'AddFirewallPort'