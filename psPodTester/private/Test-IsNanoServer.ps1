function Test-IsNanoServer
{
    <#
    .DESCRIPTION
        Determines if PowerShell is running in a Windows NanoServer docker container published by Microsoft.
        This determines the type of admin elevation required to start the web server.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $isNanoServer = $false

    if ( $IsWindows ) {
        if ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*NanoServer*' ) { $isNanoServer = $true }
    }

    return $isNanoServer
}
