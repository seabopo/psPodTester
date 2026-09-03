function Test-IsArmCPU {
    <#
    .DESCRIPTION
        Determins if the CPU is an ARM CPU. This is only used on the container host to determing the image to use.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ( )

    $isArm = $false

    if ( $env:PSPOD_ENV_IsArmCPU ) {
        $isArm = [bool] [int] $env:PSPOD_ENV_IsArmCPU
    }
    else {
        if ( -not (Test-IsContainer) ) {
            if ($IsWindows) {
                $isArm = ($ENV:PROCESSOR_ARCHITECTURE -like '*ARM*')
            }
            elseif ( $isMacOS ) {
                $isArm = ((uname -m) -match 'arm|arm64|aarch64')
                # hw.optional.arm64: 1
            }
            elseif ( $isLinux ) {
                $isArm = ((uname -m) -match 'arm|arm64|aarch64')
            }
        }
        $env:PSPOD_ENV_IsArmCPU = ( $isArm ? 1 : 0 )
    }

    return $isArm
}
