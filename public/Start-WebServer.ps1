function Start-WebServer
{
    <#
    .DESCRIPTION
        Runs a basic webserver which serves the log file holding a copy of the module's console messages.
    #>
    [CmdletBinding()]
    param (
        [Parameter()] [Alias('p')] [Int]    $Port = 8080,
        [Parameter()] [Alias('c')] [Switch] $EnableConsoleLogs
    )

    begin
    {
        $msg = @{
            starting   = "Starting web server ..."
            started    = "Web server started on port {0}."
            stopped    = "The web server was stopped."
            killed     = "The pod was killed."
            stressing  = "A stress test was started."
        }
    }

    process
    {
        try
        {
            $wsListener = New-Object System.Net.HttpListener
            $wsListener.Prefixes.Add( $( "http://*:{0}/" -f $Port ) )
            $wsListener.Start()
            $Error.Clear()

            Write-Info -ps -m $( $msg.started -f $Port ) -nl

            :wsListener while ($wsListener.IsListening)
            {
                $context   = $wsListener.GetContext()
                $request   = $context.Request
                $response  = $context.Response
                $uri       = "{0} {1}" -f $request.httpMethod, $request.Url.LocalPath

                $log = $( "{0} {1} {2} {3} {4}" -f $(Get-Date -Format s),
                                                   $request.RemoteEndPoint.Address.ToString(),
                                                   $request.httpMethod,
                                                   $request.UserHostName,
                                                   $request.Url.PathAndQuery )

                $log | Out-File $WS_USR_LOG_PATH -Append

                if ( $EnableConsoleLogs ) { Write-Info -m $log -nl }

                $stressAndRedirect = $false
                $stop = $false
                $kill = $false
                $cpuThreads = $env:PSPOD_TEST_CpuThreads ??= 0
                $memThreads = $env:PSPOD_TEST_MemThreads ??= 0
                $noCPU      = if ( $env:PSPOD_TEST_NoCPU )    { $true } else { $false }
                $noMem      = if ( $env:PSPOD_TEST_NoMemory ) { $true } else { $false }

                switch ($uri)
                {
                    "GET /stress10" {
                        Remove-Item -Path Env:\PSPOD_TEST_*
                        $env:PSPOD_TEST_WarmUpInterval = 0
                        $env:PSPOD_TEST_StressDuration = 10
                        $env:PSPOD_TEST_StressInterval = 10
                        $env:PSPOD_TEST_RestInterval   = 0
                        $env:PSPOD_TEST_CpuThreads     = $CpuThreads
                        $env:PSPOD_TEST_MemThreads     = $MemThreads
                        if ( $noCPU ) { $env:PSPOD_TEST_NoCPU    = 1 }
                        if ( $noMem ) { $env:PSPOD_TEST_NoMemory = 1 }
                        $stressAndRedirect             = $true
                        break
                    }
                    "GET /stress10x4" {
                        Remove-Item -Path Env:\PSPOD_TEST_*
                        $env:PSPOD_TEST_WarmUpInterval = 0
                        $env:PSPOD_TEST_StressDuration = 240
                        $env:PSPOD_TEST_StressInterval = 10
                        $env:PSPOD_TEST_RestInterval   = 20
                        $env:PSPOD_TEST_CpuThreads     = $CpuThreads
                        $env:PSPOD_TEST_MemThreads     = $MemThreads
                        if ( $noCPU ) { $env:PSPOD_TEST_NoCPU    = 1 }
                        if ( $noMem ) { $env:PSPOD_TEST_NoMemory = 1 }
                        $stressAndRedirect             = $true
                        break
                    }
                    "GET /break" {
                        Remove-Item -Path Env:\PSPOD_TEST_*
                        $env:PSPOD_TEST_WarmUpInterval      = 0
                        $env:PSPOD_TEST_StressDuration      = 240
                        $env:PSPOD_TEST_StressInterval      = 240
                        $env:PSPOD_TEST_RestInterval        = 0
                        $env:PSPOD_TEST_CpuThreads          = 12
                        $env:PSPOD_TEST_MemThreads          = 4
                        $stressAndRedirect                  = $true
                        break
                    }
                    "GET /userlog" { $contentPath = $WS_USR_LOG_PATH; break }
                    "GET /applog"  { $contentPath = $WS_APP_LOG_PATH; break }
                    "GET /msglog"  { $contentPath = $WS_MSG_LOG_PATH; break }
                    "GET /stop"    { $stop = $true; break }
                    "GET /kill"    { $kill = $true; break }
                    default        { $contentPath = $WS_APP_LOG_PATH; break }
                }

                if ( $stressAndRedirect ) {
                    Write-Info -ps -m $msg.stressing
                    $stressProc = Start-Process -FilePath "pwsh" -ArgumentList ('-File', $DOCKER_PATH) -PassThru
                    $response.Redirect('/applog')
                    $response.Close()
                }
                elseif ( $stop ) {
                    $response.Redirect('/applog')
                    $response.Close()
                    start-sleep -seconds 3
                    $wsListener.Stop()
                    $wsListener.Close()
                    Write-Info -ps -m $msg.stopped
                }
                elseif ( $kill ) {
                    $response.Redirect('/applog')
                    $response.Close()
                    if ( $stressProc ) {
                        Stop-Process $stressProc
                        get-job | stop-job
                        get-job | Remove-Job
                    }
                    Write-Info -ps -m $msg.killed
                    start-sleep -seconds 3
                    Get-Process "pwsh" | Stop-Process
                }
                else {
                    $ResponseText = $((Get-Content -path $WS_HEADER_PATH) -Join "`r`n") +
                                    $((Get-Content -path $contentPath)    -Join "`r`n") +
                                    $((Get-Content -path $WS_FOOTER_PATH) -Join "`r`n")
                    $buffer = [Text.Encoding]::UTF8.GetBytes($ResponseText)
                    $response.AddHeader("Last-Modified", [IO.File]::GetLastWriteTime($contentPath).ToString('r'))
                    $response.AddHeader("Server", "psPodTester")
                    $response.SendChunked = $FALSE
                    $response.ContentType = "text/HTML"
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $response.Close()
                }
            }
        }
        finally
        {
            if ($wsListener.IsListening) { $wsListener.Stop() }
            $wsListener.Close()
        }

    }
}
