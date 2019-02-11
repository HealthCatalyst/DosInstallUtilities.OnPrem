<#
.SYNOPSIS
lockPackageVersion

.DESCRIPTION
lockPackageVersion

.INPUTS
lockPackageVersion - The name of lockPackageVersion

.OUTPUTS
None

.EXAMPLE
lockPackageVersion

.EXAMPLE
lockPackageVersion


#>
function lockPackageVersion()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $packagelist
    )

    Write-Verbose 'lockPackageVersion: Starting'

    [string[]] $packages = $packagelist.Split(" ");
    foreach ($name in $packages) {
        sudo yum list installed $name
        $result = $LASTEXITCODE
        if ($result -eq 0) {
            sudo yum versionlock add $name 2>&1 >> yum.log
        }
    }

    sudo yum versionlock status

    Write-Verbose 'lockPackageVersion: Done'

}

Export-ModuleMember -Function 'lockPackageVersion'