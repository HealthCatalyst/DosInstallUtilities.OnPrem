<#
.SYNOPSIS
mountAzureFile

.DESCRIPTION
mountAzureFile

.INPUTS
mountAzureFile - The name of mountAzureFile

.OUTPUTS
None

.EXAMPLE
mountAzureFile

.EXAMPLE
mountAzureFile


#>
function mountAzureFile()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $saveIntoSecret
    )

    Write-Verbose 'mountAzureFile: Starting'

    [hashtable]$Return = @{}

    Do {$storageAccountName = Read-Host -Prompt "Storage Account Name"} while (!$storageAccountName)

    Do {$shareName = Read-Host -Prompt "Storage Share Name"} while (!$shareName)

    $pathToShare = "//${storageAccountName}.file.core.windows.net/${shareName}"
    $username = "$storageAccountName"

    Do {$storageAccountKey = Read-Host -Prompt "storage account key"} while (!$storageAccountKey)

    mountSMBWithParams -pathToShare $pathToShare -username $username -domain "domain" -password $storageAccountKey -saveIntoSecret $saveIntoSecret -isUNC $False

    Write-Verbose 'mountAzureFile: Done'

    return $Return
}

Export-ModuleMember -Function 'mountAzureFile'