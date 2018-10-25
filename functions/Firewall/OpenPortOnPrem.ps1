<#
.SYNOPSIS
OpenPortOnPrem

.DESCRIPTION
OpenPortOnPrem

.INPUTS
OpenPortOnPrem - The name of OpenPortOnPrem

.OUTPUTS
None

.EXAMPLE
OpenPortOnPrem

.EXAMPLE
OpenPortOnPrem


#>
function OpenPortOnPrem()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]
        $port
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $name
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $protocol
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $type
    )

    Write-Verbose 'OpenPortOnPrem: Starting'

    AddFirewallPort -port "${port}/${protocol}" -name "$name"

    Write-Verbose 'OpenPortOnPrem: Done'
}

Export-ModuleMember -Function 'OpenPortOnPrem'