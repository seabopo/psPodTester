function Get-PhysicalMemory {
    <#
    .DESCRIPTION
        Gets the physical memory of the host environment in MB.
    #>

    [CmdletBinding()]
    [OutputType([Int])]
    param ( )

    $physicalMemory = 0

    if ( $env:PSPOD_ENV_PhysicalMemory ) {
        $physicalMemory = [int] $env:PSPOD_ENV_PhysicalMemory
    }
    else {
        if ( $IsWindows ) {
            if ( $null -eq $(Get-Service -Name cexecsvc -ErrorAction SilentlyContinue) ) {
                $physicalMemory = [math]::Round((Get-ComputerInfo).OsTotalVisibleMemorySize/1024)
            }
        }
        elseif ( $isMacOS) {
            $physicalMemory = [math]::Round((sysctl -n hw.memsize) / 1024 / 1024)
        }
        elseif ( $isLinux ) {
            $physicalMemory = (grep MemFree /proc/meminfo).TrimStart('MemFree: ').TrimEnd(' kB')
            $physicalMemory = [math]::Round([Int]($physicalMemory) / 1024)
        }
        $env:PSPOD_ENV_PhysicalMemory = $physicalMemory
    }

    return $physicalMemory
}
