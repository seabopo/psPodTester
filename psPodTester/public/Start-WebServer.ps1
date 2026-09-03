function Start-WebServer {
    <#
    .DESCRIPTION
        Runs a local webserver.
    #>
    [CmdletBinding()]
    param ()

    process {

        try {

            if ( $PS.webserver.presetUsed ) { Write-Info -f a -i -ps -m $PS.usrmsg.web.presetUsed }
            Write-Info -f a -p -ps -m $PS.usrmsg.web.starting

            $wsListener = New-Object System.Net.HttpListener
            $wsListener.Prefixes.Add( $( "http://*:{0}/" -f $PS.webServer.port ) )
            $wsListener.Start()
            $Error.Clear()

            $PS.webServer.isRunning   = $true
            $env:PSPOD_WEBS_IsRunning = 1

            Write-Info -f a -m $( $PS.usrmsg.web.started -f $PS.webServer.port )

            :wsListener while ($wsListener.IsListening) {

                $se = Initialize-ServerEvent -ListenerContext $wsListener.GetContext()

                $se | Write-UserLogEntry

                switch ( $se.uri ) {


                #     "GET /connectivity" { }
                #     "GET /stress"       { }

                #     "GET /stress10"     { }
                #     "GET /stress30"     { }
                #     "GET /stress10x4"   { }
                #     "GET /stressbreak"  { }

                #     "GET /stopweb"      { }
                #     "GET /kill"         { }


                    "GET /help"         { $se | Set-FileResponse -f $PS.path.help   -t 'About This App'           }
                    "GET /podinfo"      { $se | Set-FileResponse -f $PS.path.dbgLog -t 'Container Properties'  -p }
                    "GET /applog"       { $se | Set-FileResponse -f $PS.path.appLog -t 'Application Log'       -p }
                    "GET /userlog"      { $se | Set-FileResponse -f $PS.path.usrLog -t 'User Request Log'      -p }
                    "GET /msglog"       { $se | Set-FileResponse -f $PS.path.msgLog -t 'Messages Service Log'  -p }

                    "GET /headers"      { $se | Set-HeadersResponse      }
                    "GET /echo"         { $se | Set-EchoResponse         }
                    "POST /echo"        { $se | Set-EchoResponse         }
                    "GET /connectivity" { $se | Set-ConnectivityResponse }
                    
                    "GET /healthz"      { $se | Set-HealthzResponse       }
                    "GET /stophealthz"  { $se | Set-HealthzResponse -Stop }

                    default             { $se | Set-FileResponse -f $PS.path.help   -t 'About This App'           }
                }

                $se | Send-WebResponse

            }
        }
        catch {
            Write-Info -e -m $( "Web server terminated with the following error: {0}" -f $_.Exception.Message )
            Start-Sleep -Seconds 5
        }
        finally {
            if ($wsListener.IsListening) { $wsListener.Stop() }
            $wsListener.Close()
        }

    }
}
