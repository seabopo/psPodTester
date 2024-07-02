function Invoke-WebServer
{
    <#
    .DESCRIPTION
        Runs a local webserver.
    #>
    [CmdletBinding()]
    param ()

    process
    {
        Write-Info -p -ps -m $USER_MESSAGES.startingws

        $port = $env:PSPOD_TEST_WebServerPort     ??= 80
        $logs = $env:PSPOD_TEST_EnableConsoleLogs ? '$true' : '$false'

        if ( $ENV_USERISADMIN ) {
            try {
                Start-Process -FilePath "pwsh" `
                              -ArgumentList ('-File', $WS_START_PATH, '-Port', $port, "-EnableConsoleLogs:$($logs)")
                Write-Info -m $($USER_MESSAGES.startedws -f $port)
                Start-Sleep -Seconds 3
            }
            catch {
                Write-Info -e -m $( "... WebServer failed to start: {0}" -f $_.Exception.Message )
            }
        }

        if ( -not $ENV_USERISADMIN -and $ENV_ISCONTAINER ) {
            Write-Info -e -m $USER_MESSAGES.nostartws
        }

        if ( $isWindows -and -not $ENV_USERISADMIN -and -not $ENV_ISCONTAINER ) {
            Write-Info -w -m $USER_MESSAGES.wselevate
            try {
                Start-Process -FilePath "pwsh" -Verb RunAs `
                              -ArgumentList ('-File', $WS_START_PATH, `
                                             '-Port', $port, `
                                             "-EnableConsoleLogs:$($logs)")
                Write-Info -m $($USER_MESSAGES.startedws -f $port)
                Start-Sleep -Seconds 3
            }
            catch {
                Write-Info -e -m $( "... WebServer failed to start: {0}" -f $_.Exception.Message )
            }
        }

    }
}
