function Invoke-WebServer
{
    <#
    .DESCRIPTION
        Runs a local webserver.
    #>
    [CmdletBinding()]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    process
    {
        Write-Info -p -ps -m $testData.messages.startingws

        if ( $testData.UserIsAdmin ) {
            try {
                Start-Process -FilePath "pwsh" `
                              -ArgumentList ('-File', $WS_START_PATH, `
                                             '-Port', $testData.WebServerPort, `
                                             "-EnableConsoleLogs:$($testData.EnableConsoleLogs)")
                Write-Info -m $($testData.messages.startedws -f $testData.WebServerPort)
                Start-Sleep -Seconds 5
            }
            catch {
                Write-Info -e -m $( "... WebServer failed to start: {0}" -f $_.Exception.Message )
            }
        }

        if ( -not $testData.UserIsAdmin -and $testData.IsContainer ) {
            Write-Info -e -m $testData.messages.nostartws
        }

        if ( $isWindows -and -not $testData.UserIsAdmin -and -not $testData.IsContainer ) {
            Write-Info -w -m $testData.messages.wselevate
            try {
                Start-Process -FilePath "pwsh" -Verb RunAs `
                              -ArgumentList ('-File', $WS_START_PATH, `
                                             '-Port', $testData.WebServerPort, `
                                             "-EnableConsoleLogs:$($testData.EnableConsoleLogs)")
                Write-Info -m $($testData.messages.startedws -f $testData.WebServerPort)
                Start-Sleep -Seconds 5
            }
            catch {
                Write-Info -e -m $( "... WebServer failed to start: {0}" -f $_.Exception.Message )
            }
        }

    }
}
