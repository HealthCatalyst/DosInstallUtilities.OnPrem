<#
.SYNOPSIS
ShowCommandToJoinCluster

.DESCRIPTION
ShowCommandToJoinCluster

.INPUTS
ShowCommandToJoinCluster - The name of ShowCommandToJoinCluster

.OUTPUTS
None

.EXAMPLE
ShowCommandToJoinCluster

.EXAMPLE
ShowCommandToJoinCluster


#>
function ShowCommandToJoinCluster()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
        ,
        [bool]
        $prerelease
    )

    Write-Verbose 'ShowCommandToJoinCluster: Starting'


    $joinCommand = $(sudo kubeadm token create --print-join-command)
    if ($joinCommand) {
        # $parts = $joinCommand.Split(' ');
        # $masterurl = $parts[2];
        # $token = $parts[4];
        # $discoverytoken = $parts[6];

        WriteToConsole "Run this command on any new node to join this cluster (this command expires in 24 hours):"
        WriteToConsole "---------------- COPY BELOW THIS LINE ----------------"
        $fullCommand= "curl -sSL $baseUrl/onprem/main.sh?p=`$RANDOM -o main.sh; bash main.sh `"$joinCommand`""
        if($prerelease){
            $fullCommand = "${fullCommand} -prerelease"
        }
        WriteToConsole $fullCommand

        # if [[ ! -z "$pathToShare" ]]; then
        #     Write-Host "curl -sSL $baseUrl/onprem/mountfolder.sh?p=$RANDOM | bash -s $pathToShare $username $domain $password 2>&1 | tee mountfolder.log"
        # fi
        # Write-Host "sudo $(sudo kubeadm token create --print-join-command)"
        Write-Host ""
        Write-Host "-------------------- COPY ABOVE THIS LINE ------------------------------"
    }

    Write-Verbose 'ShowCommandToJoinCluster: Done'

}

Export-ModuleMember -Function 'ShowCommandToJoinCluster'