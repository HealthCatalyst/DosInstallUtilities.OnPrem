<#
.SYNOPSIS
MountFolderFromSecrets

.DESCRIPTION
MountFolderFromSecrets

.INPUTS
MountFolderFromSecrets - The name of MountFolderFromSecrets

.OUTPUTS
None

.EXAMPLE
MountFolderFromSecrets

.EXAMPLE
MountFolderFromSecrets


#>
function MountFolderFromSecrets()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
    )

    Write-Verbose 'MountFolderFromSecrets: Starting'
    [hashtable]$Return = @{}
    WriteToConsole "waiting to let kubernetes come up"
    Do {
        Write-Host '.' -NoNewline;
        Start-Sleep -Seconds 5;
    } while (!(Test-Path -Path "/etc/kubernetes/kubelet.conf"))

    Start-Sleep -Seconds 10

    WriteToConsole "copying kube config to ${HOME}/.kube/config"
    mkdir -p "${HOME}/.kube"
    sudo cp -f "/etc/kubernetes/kubelet.conf" "${HOME}/.kube/config"
    sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

    WriteToConsole "giving read access to current user to /var/lib/kubelet/pki/kubelet-client.key"
    $u = "$(whoami)"
    sudo setfacl -m u:${u}:r "/var/lib/kubelet/pki/kubelet-client.key"

    WriteToConsole "reading secret for folder to mount "

    $secretname = "mountsharedfolder"
    $namespace = "default"
    $pathToShare = $(ReadSecretData -secretname $secretname -valueName "path" -namespace $namespace)
    $username = $(ReadSecretData -secretname $secretname -valueName "username" -namespace $namespace)
    $domain = $(ReadSecretData -secretname $secretname -valueName "domain" -namespace $namespace)
    $password = $(ReadSecretData -secretname $secretname -valueName "password" -namespace $namespace)

    if ($username) {
        mountSMBWithParams -pathToShare $pathToShare -username $username -domain $domain -password $password -saveIntoSecret $False -isUNC $True
    }
    else {
        WriteToLog "No username found in secrets"
        mountSMB -saveIntoSecret $False
    }

    Write-Verbose 'MountFolderFromSecrets: Done'
    return $Return
}

Export-ModuleMember -Function 'MountFolderFromSecrets'