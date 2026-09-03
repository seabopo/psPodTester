function Test-HasCIM {
    <#
    .DESCRIPTION
        The “Common Information Model” (CIM) is an open-source standard for accessing and displaying information
        about a computer. PowerShell uses CIM to access system information. This function determines if a CIM is
        available on the current system. The function is used to determine if the system is running Windows.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $hasCIM = $false

    if ( $env:PSPOD_ENV_HasCIM ) {
        $hasCIM = [bool] [int] $env:PSPOD_ENV_HasCIM
    }
    else {
        if ( $IsWindows ) {
            try {
                Get-CimInstance -ClassName Win32_ComputerSystem
                $hasCIM = $true
            }
            catch { }
        }
        $env:PSPOD_ENV_HasCIM = ( $hasCIM ? 1 : 0 )
    }

    return $hasCIM
}
