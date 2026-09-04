function Test-IsArmCPU {
    <#
    .DESCRIPTION
        Determines if the CPU is an ARM CPU.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ( )

    $isArm = $false
    if ($isWindows) {
        $isArm = ($ENV:PROCESSOR_ARCHITECTURE -like '*ARM*')
    }
    else {
        $isArm = ((uname -m) -match 'arm|arm64|aarch64')
    }
    $env:PSPOD_ENV_IsArmCPU = ( $isArm ? 1 : 0 )

    return $isArm
}
