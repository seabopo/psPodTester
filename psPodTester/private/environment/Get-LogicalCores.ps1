function Get-LogicalCores {
    <#
    .DESCRIPTION
        Gets the number of logical cores of the host environment.
    #>

    [CmdletBinding()]
    [OutputType([Int])]
    param ( )

    $logicalCores = 0

    if ( $env:PSPOD_ENV_LogicalCores ) {
        $logicalCores = [int] $env:PSPOD_ENV_LogicalCores
    }
    else {
        if ($IsWindows) {
            if ( Test-IsContainer ) {
                $logicalCores = [int] ($Env:NUMBER_OF_PROCESSORS)
            }
            else {
                $logicalCores = [int] ((Get-ComputerInfo).CsNumberOfLogicalProcessors)
            }
        }
        elseif ( $isMacOS ) {
            $logicalCores = [int] (sysctl -n hw.ncpu)
        }
        elseif ( $isLinux ) {
            $logicalCores = [int] (nproc)
        }
        $env:PSPOD_ENV_LogicalCores = $logicalCores
    }

    return $logicalCores
}
