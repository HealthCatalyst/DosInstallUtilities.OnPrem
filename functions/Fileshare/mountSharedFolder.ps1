<#
.SYNOPSIS
mountSharedFolder

.DESCRIPTION
mountSharedFolder

.INPUTS
mountSharedFolder - The name of mountSharedFolder

.OUTPUTS
None

.EXAMPLE
mountSharedFolder

.EXAMPLE
mountSharedFolder


#>
function mountSharedFolder()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $saveIntoSecret
    )

    Write-Verbose 'mountSharedFolder: Starting'

    [hashtable]$Return = @{}

    Write-Host "DOS requires a network folder that can be accessed from all the worker VMs"
    Write-Host "1. Mount an existing Azure file share"
    Write-Host "2. Mount an existing UNC network file share"
    Write-Host "3. I've already mounted a shared folder at /mnt/data/"
    Write-Host ""

    $inputArray = @(1,2,3)

    Do {$mountChoice = Read-Host -Prompt "Choose a number"} while (!$mountChoice -or ($inputArray -notcontains $mountChoice))

    if ($mountChoice -eq "1") {
        mountAzureFile -saveIntoSecret $saveIntoSecret
    }
    elseif ($mountChoice -eq "2") {
        mountSMB -saveIntoSecret $saveIntoSecret
    }
    else {
        WriteToLog "User will mount a shared folder manually"
    }

    Write-Verbose 'mountSharedFolder: Done'

    return $Return
}

Export-ModuleMember -Function 'mountSharedFolder'