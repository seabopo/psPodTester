function Set-EchoResponse {
    <#
    .DESCRIPTION
        Sets the response variables and actions for the selected log file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $nl      = [System.Environment]::NewLine
            $request = $ServerEvent.request
            $method  = $request.HttpMethod

            $body = ''
            if ( $request.HasEntityBody ) {
                $reader = [System.IO.StreamReader]::new($request.InputStream, $request.ContentEncoding)
                $body   = $reader.ReadToEnd()
                $reader.Dispose()
            }

            $properties = [Ordered] @{
                'HTTP Method'       = $request.HttpMethod
                'URL'               = $request.Url
                'Raw URL'           = $request.RawUrl
                'Query String'      = $request.Url.Query
                'Protocol Version'  = $request.ProtocolVersion
                'Content Type'      = $request.ContentType
                'Content Length'    = $request.ContentLength64
                'Content Encoding'  = $request.ContentEncoding.EncodingName
                'Has Entity Body'   = $request.HasEntityBody
                'Is Secure'         = $request.IsSecureConnection
                'Is Local'          = $request.IsLocal
                'Is Authenticated'  = $request.IsAuthenticated
                'Keep Alive'        = $request.KeepAlive
                'User Agent'        = $request.UserAgent
                'User Host Name'    = $request.UserHostName
                'User Host Address' = $request.UserHostAddress
                'Remote Endpoint'   = $request.RemoteEndPoint
                'Local Endpoint'    = $request.LocalEndPoint
            }

            $headers = [Ordered] @{}
            $request.headers | Sort-Object | ForEach-Object { $headers[$_] = $request.headers[$_] }

            $labelWidth = ( @($properties.Keys) + @($headers.Keys) | Measure-Object -Property Length -Maximum ).Maximum

            $divider = '-' * 60

            $userContent = $nl + $('HTTP {0} PROPERTIES' -f $method) + $nl + $divider + $nl
            $properties.Keys | ForEach-Object {
                $userContent += ('{0} : {1}' -f $_.PadRight($labelWidth), $properties[$_]) + $nl
            }

            $userContent += $nl + $('HTTP {0} HEADERS' -f $method) + $nl + $divider + $nl
            $headers.Keys | ForEach-Object {
                $userContent += ('{0} : {1}' -f $_.PadRight($labelWidth), $headers[$_]) + $nl
            }
            
            if ( $method -eq 'POST' ) {
                $userContent += $nl + 'HTTP POST BODY' + $nl + $divider + $nl
                $userContent += $( [String]::IsNullOrEmpty($body) ? '(no body)' : $body ) + $nl
            }

            $userContent += $nl
            
            $PS.webServer.content.user        = $userContent
            $PS.webServer.content.contentType = 'text/plain'

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
