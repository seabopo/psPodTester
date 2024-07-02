function Test-UserCanRunWebServer
{
    <#
    .DESCRIPTION
        Tests if a user has the rights to run a web server.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    try {
        $wsListener = New-Object System.Net.HttpListener
        $wsListener.Prefixes.Add( $( "http://*:8888/") )
        $wsListener.Start()
        if ($wsListener.IsListening) { $wsListener.Stop() }
        $wsListener.Close()
        $testData.Add('UserCanRunWebServer',$true)
    }
    catch {
        $testData.Add('UserCanRunWebServer',$false)
    }

    return $testData
}
