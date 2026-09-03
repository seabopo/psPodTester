function Test-IsNanoServer {
    <#
    .DESCRIPTION
        Determines if PowerShell is running in a Windows NanoServer docker container published by Microsoft.
        This determines the type of admin elevation required to start the web server.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $isNanoServer = $false

    if ( $env:PSPOD_ENV_IsNanoServer ) {
        $isNanoServer = [bool] [int] $env:PSPOD_ENV_IsNanoServer
    }
    else {
        if ( $IsWindows ) {
            if ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*NanoServer*' ) { $isNanoServer = $true }
        }
        $env:PSPOD_ENV_IsNanoServer = ( $isNanoServer ? 1 : 0 )
    }

    return $isNanoServer
}
