#==================================================================================================================
#==================================================================================================================
# psPodTester - Module Initialization
#==================================================================================================================
#==================================================================================================================

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ErrorActionPreference = "Stop"

  # Load all public functions
    Get-ChildItem -Path "$($PSScriptRoot)/Public/*.ps1" -Recurse | ForEach-Object { . $($_.FullName) }

  # Export all the public functions and aliases
    Export-ModuleMember -Function * -Alias *

  # Load all private functions
    Get-ChildItem -Path "$($PSScriptRoot)/Private/*.ps1" -Recurse | ForEach-Object { . $($_.FullName) }

  # Update the Environment Variables based on any presets that were found.
    Set-EnvironmentPresets

  # Initialize the module-level variables
    Set-Variable -Scope 'Local' -Name 'PS' -Value $([Hashtable] @{

        moduleName  = $($PSScriptRoot | Split-Path -Leaf)
        initialized = $false

        env = [Hashtable] @{
            isContainer     = $( Test-IsContainer )
            osPlatform      = $( Get-OperatingSystemPlatform )
            osVersion       = $( Get-OperatingSystemVersion )
            isNanoServer    = $( Test-IsNanoServer )
            isArmCpu        = $( Test-IsArmCpu )
            hostHasCIM      = $( Test-HasCIM )
            logicalCores    = $( Get-LogicalCores )
            physicalMemory  = $( Get-PhysicalMemory )
            userIsAdmin     = $( Test-UserIsAdmin )
            userCanRunAs    = $( Test-UserCanRunAs )
            userCanRunWS    = $( Test-UserCanRunWebServer )
        }

        path = [Hashtable] @{
            moduleRoot        = $PSScriptRoot
            appLog            = $( '{0}/logs/app.log'              -f $PSScriptRoot )
            usrLog            = $( '{0}/logs/usr.log'              -f $PSScriptRoot )
            msgLog            = $( '{0}/logs/msg.log'              -f $PSScriptRoot )
            dbgLog            = $( '{0}/logs/dbg.log'              -f $PSScriptRoot )
            help              = $( '{0}/html/help.html'            -f $PSScriptRoot )
            headerHtml        = $( '{0}/html/page-header.html'     -f $PSScriptRoot )
            footerHtml        = $( '{0}/html/page-footer.html'     -f $PSScriptRoot )
            sidebarTestHtml   = $( '{0}/html/sidebar-testing.html' -f $PSScriptRoot )
            contentHeaderHtml = $( '{0}/html/content-header.html'  -f $PSScriptRoot )
        }

        healthz = [Hashtable] @{
            enabled    = $true
            status     = 'OK'
            statusCode = 200
        }

        webServer = [Hashtable] @{
            enabled            = $env:PSPOD_WEBS_EnableWebServer     ? $true : $false
            presetUsed         = $env:PSPOD_WEBS_PresetUsed          ? $true : $false
            isRunning          = $env:PSPOD_WEBS_IsRunning           ? $true : $false
            failedToStart      = $env:PSPOD_WEBS_FailedToStart       ? $true : $false
            showPodInfo        = $env:PSPOD_WEBS_ShowPodInfo         ? $true : $false
            showEnvVariables   = $env:PSPOD_WEBS_ShowEnvVariables    ? $true : $false
            adminEnabled       = $env:PSPOD_WEBS_AdminEnabled        ? $true : $false
            adminSubnets       = $env:PSPOD_WEBS_AdminSubnets       ?? '127.0.0.1'
            pid                = $env:PSPOD_WEBS_PID                ?? 0
            port               = $env:PSPOD_WEBS_WebServerPort      ?? 80
            appName            = $env:PSPOD_WEBS_AppName            ?? 'PodTester'
            ignoreEnvVariables = $env:PSPOD_WEBS_IgnoreEnvVariables ?? @('*SCRT*','*SECRET*','*PASS*','*KEY*','*TOKEN*','PSPOD_WEBS_Admin*')
            content            = [Hashtable] @{ }
        }

        messages = [Hashtable] @{
            enabled    = $env:PSPOD_MSGS_SendMessages   ? $true : $false
            isRunning  = $env:PSPOD_MSGS_IsRunning      ? $true : $false
            pid        = $env:PSPOD_MSGS_PID           ?? 0
            period     = $env:PSPOD_MSGS_SendPeriod    ?? 30
            prefix     = $env:PSPOD_MSGS_MessagePrefix ?? 'PodTester'
        }

        tests = [Hashtable] @{
            enabled                  = $env:PSPOD_TEST_EnableTesting                     ? $true : $false
            areRunning               = $env:PSPOD_TEST_AreRunning                        ? $true : $false
            pid                      = $env:PSPOD_TEST_PID                              ?? 0
            noCPU                    = $env:PSPOD_TEST_NoCPU                             ? $true : $false
            noMemory                 = $env:PSPOD_TEST_NoMemory                          ? $true : $false
            duration                 = $env:PSPOD_TEST_StressDuration                   ?? 5
            warmUpInterval           = $env:PSPOD_TEST_WarmUpInterval                   ?? 1
            stressInterval           = $env:PSPOD_TEST_StressInterval                   ?? 1
            restInterval             = $env:PSPOD_TEST_RestInterval                     ?? 1
            coolDownInterval         = $env:PSPOD_TEST_CoolDownInterval                 ?? 1
            randomizeIntervals       = $env:PSPOD_TEST_RandomizeIntervals               ?? @()
            randomizeStressIntervals = ($env:PSPOD_TEST_RandomizeIntervals -like '*s*')  ? $true : $false
            randomizeRestIntervals   = ($env:PSPOD_TEST_RandomizeIntervals -like '*r*')  ? $true : $false
            maxIntervalDuration      = $env:PSPOD_TEST_MaxIntervalDuration              ?? 30
            startTime                = ''
            endTime                  = ''
            cpuThreads               = $env:PSPOD_TEST_CpuThreads ?? 1
            memThreads               = $env:PSPOD_TEST_MemThreads ?? 1
            currentIntervalType      = ''
            currentIntervalDuration  = ''
            currentIntervalIsRandom  = ''
            currentIntervalEndTime   = ''

        }

        usrmsg = [Hashtable] @{

            app  = [Hashtable] @{
                init       = 'Container started at: {0}'
                noPodInfo  = 'Container information display is not enabled.'
                podInfo    = 'Container information display is enabled.'
                podEnvHdr  = 'Container Environment Information'
                nonefound  = '... No items were found.'
                container  = '... Running in Container: {0}'
                platform   = '... Running on Platform: {0} ({1})'
                isArmCpu   = '... Running on ARM CPU: {0}'
                hostHasCIM = '... Host has CIM: {0}'
                cores      = '... Logical Cores: {0}'
                memory     = '... Physical Memory: {0} GB'
                adminUser  = '... User is Admin: {0}'
                runAsUser  = '... User can Elevate: {0}'
                runWsUser  = '... User can run the Web Server: {0}'
                podInfoHdr = 'Container Deployment Information (PS_PODINFO_* Environment Variables)'
                noEnvInfo  = 'Environment variable display is not enabled.'
                envInfo    = 'Environment variable display is enabled.'
                envInfoHdr = 'The following environment variables were found:'
                complete   = 'The initialization process is now complete.'
            }

            msg = [Hashtable] @{
                enabled    = 'Automated container messages are enabled.'
                noenabled  = 'Automated container messages are not enabled.'
                start      = 'Logging test messages with prefix "{0}" every {1} seconds ...'
                error      = 'The message service failed.'
            }

            healthz = [Hashtable] @{
                stopped    = 'The healthz responses have been set to service unavailable (503).'
            }

            web = [Hashtable] @{
                enabled    = 'The web server is enabled.'
                noenabled  = 'The web server is not enabled.'
                presetUsed = 'The Webserver preset was used to initialize this container.'
                starting   = 'Starting the web server ...'
                elevate    = '... The user does not have rights. Attempting to elevate ...'
                nostart    = '... Cannot start Web Server. User does not have rights.'
                started    = '... Web server started on port {0}.'
                failed     = '... The web server failed to start: {0}.'

                stopped    = 'The web server was stopped.'
                killed     = 'The pod was killed.'
                stressing  = 'A stress test was started.'
            }

            tst = [Hashtable] @{
                enabled      = 'Automated stress tests are enabled.'
                noenabled    = 'Automated stress tests are not enabled.'
                summary      = 'Test Summary'
                startTime    = '... Start Time: {0}'
                endTime      = '... End Time: {0}'
                duration     = '... Duration: {0} minutes'
                cpuThreads   = '... CPU Threads: {0}'
                memThreads   = '... Memory Threads: {0}'
                warmint      = '... Warm Interval: {0} minutes'
                coolint      = '... Cool Interval: {0} minutes'
                strescyc     = '... Stress Cycle: {0} minutes'
                stresint     = '... Stress Interval: {0} minutes'
                restint      = '... Rest Interval: {0} minutes'
                randomStress = '... Randomized Stress Interval(s): {0}'
                randomRest   = '... Randomized Rest Interval(s): {0}'
                start      = 'Starting tests...'
                warm       = 'Starting warm up interval ...'
                startcycle = 'Starting stress/rest interval cycle ...'
                stress     = 'Starting stress interval ...'
                rest       = 'Starting rest interval ...'
                cool       = 'Starting cool down interval ...'
                completed  = 'All intervals completed.'
                jobs       = '... Jobs started: {0}'
                countdown  = '... Interval will complete in {0} minute(s) ...'
                cleanup    = '... Cleaning up jobs ...'
                complete   = '... Interval complete.'
                error      = 'Intervals failed.'

            }

        }

    })

    $PS.webServer.content = [Hashtable] @{
        pageHeader     = $(( Get-Content -path $PS.path.headerHtml ) -Join "`r`n").Replace('##APPNAME##',$PS.webServer.appName)
        pageFooter     = $(( Get-Content -path $PS.path.footerHtml ) -Join "`r`n")
        sidebarTesting = $(( Get-Content -path $PS.path.sidebarTestHtml )   -Join "`r`n")
        header         = $(( Get-Content -path $PS.path.contentHeaderHtml ) -Join "`r`n")
        user           = ""
        contentType    = 'text/HTML'
        responseCode   = 200
        responseStatus = 'OK'
    }
