function Test-UserCanRunWebServer {
    <#
    .DESCRIPTION
        Tests if a user has the rights to run a web server.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $canRunWebServer = $false

    try {
        $wsListener = New-Object System.Net.HttpListener
        $wsListener.Prefixes.Add( $( "http://*:8888/") )
        $wsListener.Start()
        if ( $wsListener.IsListening ) { $wsListener.Stop() }
        $wsListener.Close()
        $canRunWebServer = $true
    }
    catch { }

    $env:PSPOD_ENV_CanRunWebServer = ( $canRunWebServer ? 1 : 0 )

    return $canRunWebServer
}
