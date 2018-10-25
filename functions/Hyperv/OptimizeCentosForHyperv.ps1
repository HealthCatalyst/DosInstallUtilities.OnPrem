<#
.SYNOPSIS
OptimizeCentosForHyperv

.DESCRIPTION
OptimizeCentosForHyperv

.INPUTS
OptimizeCentosForHyperv - The name of OptimizeCentosForHyperv

.OUTPUTS
None

.EXAMPLE
OptimizeCentosForHyperv

.EXAMPLE
OptimizeCentosForHyperv


#>
function OptimizeCentosForHyperv()
{
    [CmdletBinding()]
    param
    (
    )

    Write-Verbose 'OptimizeCentosForHyperv: Starting'

    # from https://www.altaro.com/hyper-v/centos-linux-hyper-v/
    WriteToConsole "installing hyperv-daemons package"
    sudo yum install -y hyperv-daemons bind-utils
    WriteToConsole "turning off disk optimization in centos since Hyper-V already does disk optimization"
    # don't use WriteToConsole here
    echo "noop" | sudo tee /sys/block/sda/queue/scheduler
    $myip = $(host $(hostname) | awk '/has address/ { print $4 ; exit }')
    WriteToConsole "You can connect to this machine via SSH: ssh $(whoami)@${myip}"
    # grep -v "$(hostname)" /etc/hosts | sudo tee /etc/hosts > /dev/null
    # WriteToConsole "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts > /dev/null

    Write-Verbose 'OptimizeCentosForHyperv: Done'

}

Export-ModuleMember -Function 'OptimizeCentosForHyperv'