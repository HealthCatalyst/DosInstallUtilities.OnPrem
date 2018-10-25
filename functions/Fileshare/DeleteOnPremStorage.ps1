<#
.SYNOPSIS
DeleteOnPremStorage

.DESCRIPTION
DeleteOnPremStorage

.INPUTS
DeleteOnPremStorage - The name of DeleteOnPremStorage

.OUTPUTS
None

.EXAMPLE
DeleteOnPremStorage

.EXAMPLE
DeleteOnPremStorage


#>
function DeleteOnPremStorage()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
    )

    Write-Verbose 'DeleteOnPremStorage: Starting'
    [hashtable]$Return = @{}

    if ([string]::IsNullOrWhiteSpace($namespace)) {
        Write-Error "no parameter passed to DeleteOnPremStorage"
        exit
    }

    $shareName = "$namespace"
    $sharePath = "/mnt/data/$shareName"

    Write-Information -MessageData "Deleting the file share: $sharePath"

    Remove-Item -Recurse -Force $sharePath

    Write-Verbose 'DeleteOnPremStorage: Done'

    return $Return
}

Export-ModuleMember -Function 'DeleteOnPremStorage'