function Get-OperatingSystemVersion {
    <#
    .DESCRIPTION
        Gets the Operating System version (Windows 10, MacOS 10.15.7, Linux 5.4.0-1043-azure).
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param ( )

    if ( $env:PSPOD_ENV_osVersion ) {
        $osVersion = $env:PSPOD_ENV_osVersion
    }
    else {
        if ($IsWindows) {
            if ( Test-IsContainer ) {
                $osVersion = (cmd /c ver)
            }
            else {
                $osVersion = (Get-ComputerInfo).WindowsProductName
            }
        }
        elseif ( $isMacOS ) {
            $osVersion = (sw_vers -productVersion)
        }
        elseif ( $isLinux ) {
            $osVersion = ( uname -r )
        }
        else {
            $osVersion = 'Unknown'
        }
        $env:PSPOD_ENV_osVersion = $osVersion
    }

    return $osVersion
}
