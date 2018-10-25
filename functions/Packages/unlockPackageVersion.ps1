<#
.SYNOPSIS
unlockPackageVersion

.DESCRIPTION
unlockPackageVersion

.INPUTS
unlockPackageVersion - The name of unlockPackageVersion

.OUTPUTS
None

.EXAMPLE
unlockPackageVersion

.EXAMPLE
unlockPackageVersion


#>
function unlockPackageVersion()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $packagelist
    )

    Write-Verbose 'unlockPackageVersion: Starting'

    [string[]] $packages = $packagelist.Split(" ");
    foreach ($name in $packages) {
        sudo yum versionlock delete $name 2>&1 >> yum.log
    }

    Write-Verbose 'unlockPackageVersion: Done'

}

Export-ModuleMember -Function 'unlockPackageVersion'