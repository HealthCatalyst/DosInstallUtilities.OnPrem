<#
.SYNOPSIS
mountSMBWithParams

.DESCRIPTION
mountSMBWithParams

.INPUTS
mountSMBWithParams - The name of mountSMBWithParams

.OUTPUTS
None

.EXAMPLE
mountSMBWithParams

.EXAMPLE
mountSMBWithParams


#>
function mountSMBWithParams()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pathToShare
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $username
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $domain
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $password
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $saveIntoSecret
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [bool]
        $isUNC
    )

    Write-Verbose 'mountSMBWithParams: Starting'

    [hashtable]$Return = @{}
    $passwordlength = $($password.length)
    WriteToLog "mounting file share with path: [$pathToShare], user: [$username], domain: [$domain], password_length: [$passwordlength] saveIntoSecret: [$saveIntoSecret], isUNC: [$isUNC]"
    # save as secret
    # secretname="sharedfolder"
    # namespace="default"
    # if [[ ! -z  "$(kubectl get secret $secretname -n $namespace -o jsonpath='{.data}' --ignore-not-found=true)" ]]; then
    #     kubectl delete secret $secretname -n $namespace
    # fi

    # kubectl create secret generic $secretname --namespace=$namespace --from-literal=path=$pathToShare --from-literal=username=$username --from-literal=password=$password

    # from: https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux
    sudo yum -y install samba-client samba-common cifs-utils

    sudo mkdir -p /mnt/data

    # sudo mount -t cifs $pathToShare /mnt/data -o vers=2.1,username=<storage-account-name>,password=<storage-account-key>,dir_mode=0777,file_mode=0777,serverino

    # remove previous entry for this drive
    grep -v "/mnt/data" /etc/fstab | sudo tee /etc/fstab

    sudo umount "/mnt/data"

    if ($isUNC -eq $True) {
        WriteToLog "Mounting as UNC folder"
        WriteToLog "sudo mount --verbose -t cifs $pathToShare /mnt/data -o vers=2.1,username=$username,domain=$domain,pass=$password,dir_mode=0777,file_mode=0777"
        sudo mount --verbose -t cifs $pathToShare /mnt/data -o "vers=2.1,username=$username,domain=$domain,pass=$password,dir_mode=0777,file_mode=0777"
        $result=$LASTEXITCODE
        if($result -ne 0){
            throw "Unable to mount $pathToShare with username=$username,domain=$domain exitcode=$result"
        }
        echo "$pathToShare /mnt/data cifs nofail,vers=2.1,username=$username,domain=$domain,pass=$password,dir_mode=0777,file_mode=0777" | sudo tee -a /etc/fstab
    }
    else {
        WriteToLog "Mounting as non-UNC folder"
        sudo mount --verbose -t cifs $pathToShare /mnt/data -o "vers=2.1,username=$username,pass=$password,dir_mode=0777,file_mode=0777,serverino"
        $result=$LASTEXITCODE
        if($result -ne 0){
            throw "Unable to mount $pathToShare with username=$username exitcode=$result"
        }
        echo "$pathToShare /mnt/data cifs nofail,vers=2.1,username=$username,pass=$password,dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab
    }

    WriteToLog "Mounting all shares"
    sudo mount -a --verbose

    if ( $saveIntoSecret -eq $True) {
        WriteToLog "Saving mount information into a secret"
        $secretname = "mountsharedfolder"
        $namespace = "default"
        if ([string]::IsNullOrEmpty("$(kubectl get secret $secretname -n $namespace -o jsonpath='{.data}' --ignore-not-found=true)")) {
            kubectl delete secret $secretname --namespace=$namespace
        }
        kubectl create secret generic $secretname --namespace=$namespace --from-literal=path=$pathToShare --from-literal=username=$username --from-literal=domain=$domain --from-literal=password=$password
    }

    touch "/mnt/data/$(hostname).txt"

    WriteToLog "Listing files in shared folder"
    ls -al /mnt/data

    Write-Verbose 'mountSMBWithParams: Done'

    return $Return
}

Export-ModuleMember -Function 'mountSMBWithParams'