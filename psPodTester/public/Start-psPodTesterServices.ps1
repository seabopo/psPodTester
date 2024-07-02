function Start-psPodTesterServices
{
    <#
    .DESCRIPTION
        Starts the core container services: WebServer, SendMessages, and Testing.
    #>

    [CmdletBinding()]
    param ()

    process
    {
        try {

          # Initialize the container log.
            Write-Info -p -ps -m $($USER_MESSAGES.init -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
            Write-Info -m $( $USER_MESSAGES.container -f $ENV_ISCONTAINER )
            Write-Info -m $( $USER_MESSAGES.adminuser -f $ENV_USERISADMIN )

          # Dump the environment variables if specified.
            if ( $env:PSPOD_TEST_ShowDebugData ) {
                Write-Info -p -ps -m $USER_MESSAGES.env
                Write-Info -i -m $( Get-Item -Path Env:* | Sort-Object | Out-String )
            }

          # Define and set any pre-defined environment variables profiles
            if ( $env:PSPOD_PRESET_Webserver ) {
                Write-Info -p -ps -m $USER_MESSAGES.wspreset
                $env:PSPOD_TEST_EnableWebServer     = 1
                $env:PSPOD_TEST_NoStress            = 1
                $env:PSPOD_TEST_NoExit              = 1
                $env:PSPOD_TEST_WebServerPort     ??= 80
                $env:PSPOD_TEST_SendMessages      ??= 1
                $env:PSPOD_TEST_MessagePrefix     ??= 'psPodTesterMessagePrefix'
                $env:PSPOD_TEST_ShowDebugData     ??= 1
                $env:PSPOD_TEST_EnableConsoleLogs ??= 1
                $env:PSPOD_TEST_ShowPodInfo       ??= 1
            }

          # Dump the environment variables if updated.
            if ( $env:PSPOD_TEST_ShowDebugData -and $env:PSPOD_PRESET_Webserver ) {
                Write-Info -p -ps -m $USER_MESSAGES.envupdated
                Write-Info -i -m $( Get-Item -Path Env:* | Sort-Object | Out-String )
            }

          # Remove the presets so they don't interfere with the tests started via the Web UI.
            Remove-Item -Path Env:\PSPOD_PRESET_*

          # Dump the pod information if specified.
            if ( $env:PSPOD_TEST_ShowPodInfo ) {
                Write-Info -p -ps -m $USER_MESSAGES.podinfo
                Get-Item -Path Env:\PSPOD_INFO_* | Sort-Object | ForEach-Object {
                    Write-Info -m $("{0}: {1}" -f $_.Name.Replace('PSPOD_INFO_',''),$_.Value )
                }
            }

          # Enable the sending of log messages if specified.
            if ( $env:PSPOD_TEST_SendMessages ) { Invoke-LogMessages }

          # Enable the Web Server if specified.
            if ( $env:PSPOD_TEST_EnableWebServer ) { Invoke-WebServer }

          # Run any tests if specified.
            $params = @{
                          StressDuration      = $env:PSPOD_TEST_StressDuration      ?? 10
                          WarmUpInterval      = $env:PSPOD_TEST_WarmUpInterval      ?? 1
                          CoolDownInterval    = $env:PSPOD_TEST_CoolDownInterval    ?? 0
                          StressInterval      = $env:PSPOD_TEST_StressInterval      ?? 5
                          RestInterval        = $env:PSPOD_TEST_RestInterval        ?? 5
                          CpuThreads          = $env:PSPOD_TEST_CpuThreads          ?? 0
                          MemThreads          = $env:PSPOD_TEST_MemThreads          ?? 0
                          RandomizeIntervals  = $env:PSPOD_TEST_RandomizeIntervals  ?? @()
                          MaxIntervalDuration = $env:PSPOD_TEST_MaxIntervalDuration ?? 1440
                          NoCPU               = $env:PSPOD_TEST_NoCPU                ? $true : $false
                          NoMemory            = $env:PSPOD_TEST_NoMemory             ? $true : $false
                          NoStress            = $env:PSPOD_TEST_NoStress             ? $true : $false
            }
            Start-Testing @params


            if ( $env:PSPOD_TEST_NoExit ) {
                Write-Info -p -ps -m $USER_MESSAGES.noexit
                Wait-Event -1
            }
            else {
                Write-Info -p -ps -m $USER_MESSAGES.exit
            }

        }
        catch {
            Write-Info -e -m $_.Exception.Message
            $_
            Start-Sleep -Seconds 10
        }
    }
}
