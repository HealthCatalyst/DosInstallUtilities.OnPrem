<#
.SYNOPSIS
CreateOnPremStorage

.DESCRIPTION
CreateOnPremStorage

.INPUTS
CreateOnPremStorage - The name of CreateOnPremStorage

.OUTPUTS
None

.EXAMPLE
CreateOnPremStorage

.EXAMPLE
CreateOnPremStorage


#>
function CreateOnPremStorage()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
    )

    Write-Verbose 'CreateOnPremStorage: Starting'

    [hashtable]$Return = @{}

    if ([string]::IsNullOrWhiteSpace($namespace)) {
        Write-Error "no parameter passed to CreateOnPremStorage"
        exit
    }


    $shareName = "$namespace"
    $sharePath = "/mnt/data/$shareName"

    Write-Information -MessageData "Create the file share: $sharePath"

    New-Item -ItemType Directory -Force -Path $sharePath
    New-Item -ItemType Directory -Force -Path "${sharePath}backups"

    Write-Verbose 'CreateOnPremStorage: Done'

    return $Return
}

Export-ModuleMember -Function 'CreateOnPremStorage'