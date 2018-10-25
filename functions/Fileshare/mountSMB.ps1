<#
.SYNOPSIS
mountSMB

.DESCRIPTION
mountSMB

.INPUTS
mountSMB - The name of mountSMB

.OUTPUTS
None

.EXAMPLE
mountSMB

.EXAMPLE
mountSMB


#>
function mountSMB()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $saveIntoSecret
    )

    Write-Verbose 'mountSMB: Starting'
    [hashtable]$Return = @{}

    Do {$pathToShare = Read-Host -Prompt "path to SMB share (e.g., //myserver.mydomain/myshare)"} while (!$pathToShare)

    # convert to unix style since that's what linux mount command expects
    $pathToShare = ($pathToShare -replace "\\", "/")

    Do {$domain = Read-Host -Prompt "domain"} while (!$domain)

    Do {$username = Read-Host -Prompt "username"} while (!$username)

    Do {$password = Read-Host -assecurestring -Prompt "password"} while ($($password.Length) -lt 1)
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    mountSMBWithParams -pathToShare $pathToShare -username $username -domain $domain -password $password -saveIntoSecret $saveIntoSecret -isUNC $True

    Write-Verbose 'mountSMB: Done'

    return $Return
}

Export-ModuleMember -Function 'mountSMB'