function Get-OperatingSystemPlatform {
    <#
    .DESCRIPTION
        Gets the platform of the operating system (Windows, MacOS or Linux).
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param ( )

    $os = $env:PSPOD_ENV_osPlatform ?? ($IsWindows ? 'Windows' : ($isMacOS ? 'MacOS' : ($isLinux ? 'Linux' : '')))

    $env:PSPOD_ENV_osPlatform = $os

    return $os
}
