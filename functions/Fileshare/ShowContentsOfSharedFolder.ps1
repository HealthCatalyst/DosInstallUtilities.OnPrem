<#
.SYNOPSIS
ShowContentsOfSharedFolder

.DESCRIPTION
ShowContentsOfSharedFolder

.INPUTS
ShowContentsOfSharedFolder - The name of ShowContentsOfSharedFolder

.OUTPUTS
None

.EXAMPLE
ShowContentsOfSharedFolder

.EXAMPLE
ShowContentsOfSharedFolder


#>
function ShowContentsOfSharedFolder()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'ShowContentsOfSharedFolder: Starting'
    ls -al /mnt/data
    Write-Verbose 'ShowContentsOfSharedFolder: Done'

}

Export-ModuleMember -Function 'ShowContentsOfSharedFolder'