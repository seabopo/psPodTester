function Initialize-ServerEvent {
    <#
    .DESCRIPTION
        Initialize the server event object, which contains all of the user request and response data.
    #>
    [CmdletBinding()]
    param ( $ListenerContext )

    process {

        try {

            $method   = $ListenerContext.Request.httpMethod.ToUpper()
            $path     = $ListenerContext.Request.Url.LocalPath.ToLower()
            $sourceIp = $ListenerContext.request.RemoteEndPoint.Address.ToString()
            $isAdmin  = Test-IPInSubnet -i $sourceIp -s $PS.webServer.adminSubnets
            
            $serverEvent = [HashTable] @{

                request     = $ListenerContext.Request
                response    = $ListenerContext.Response
                uri         = "{0} {1}" -f $method, $path
                sourceIp    = $sourceIp
                isAdmin     = $isAdmin
                enableAdmin = $PS.webServer.adminEnabled
                allowAdmin  = ($isAdmin -and $PS.webServer.adminEnabled)
                content     = $PS.webServer.content
                
                actions = @{
                    stressAndRedirect = $false
                    stop              = $false
                    kill              = $false
                    stopHealthz       = $false
                }

            }

            if ( -not $serverEvent.allowAdmin ) {
                $ServerEvent.content.sidebarTesting = ''
            }

            $ServerEvent.content.contentType = 'text/HTML'

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

        return $serverEvent

    }
}
