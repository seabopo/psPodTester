function Start-Testing
{
    <#
    .SYNOPSIS
        Executes CPU and/or memory stress tests.

    .DESCRIPTION
        Executes CPU and/or memory stress tests.

    .OUTPUTS
        Console status messages on the testing status only.

    .PARAMETER StressDuration
        OPTIONAL. Integer. Alias: -sd. The total time, in minutes, for a series of stress and rest intervals to
        execute. This does not include warm up or cool down intervals. Setting a StressDuration of 0 will make
        the intervals run for [int32]::MaxValue (2,147,483,647) minutes, which is 1,491,308 days or 4,086 years.
        Default Value: 30.

     .PARAMETER StressInterval
        OPTIONAL. Integer. Alias: -si. The time, in minutes, that each stress interval should run for. The stress
        interval puts CPU and/or Memory stress (load) on the instance.
        Default Value: 5.

    .PARAMETER RestInterval
        OPTIONAL. Integer. Alias: -ri. The time, in minutes, to remove all load after each stress interval.
        Default Value: 5.

    .PARAMETER WarmUpInterval
        OPTIONAL. Integer. Alias: -wi. The time, in minutes, to wait before starting the stress/rest intervals.
        A single Warm Up Interval is executed at the start of the session. The Warm Up Interval is not included
        in the StressDuration.
        Default Value: 0.

    .PARAMETER CoolDownInterval
        OPTIONAL. Integer. Alias: -ci. The time, in minutes, to wait after the stress/rest intervals have
        completed before exiting the PowerShell process. A single Cool Down Interval is executed at the end of
        the session. The Cool Down Interval is not included in the StressDuration.
        Default Value: 0.

    .PARAMETER CpuThreads
        OPTIONAL. Integer. Alias: -ct. The number of threads to use for CPU stressing.
        Default Value: 0 (Automatically calculated). Physical and virtualized Windows devices will use 1 thread
        per logical core. Mac OS, Linux and Window containers will use 2 threads. Use the NoCPU switch to ignore
        this test instead of setting CpuThreads to 0.

    .PARAMETER MemThreads
        OPTIONAL. Integer. Alias: -mt. The number of threads to use for memory stressing.
        Default Value: 0 (Automatically calculated) which will use 2 threads.
        Use the NoMemory switch to ignore this test instead of setting MemThreads to 0.

    .PARAMETER RandomizeIntervals
        OPTIONAL. Array of String. Alias: -rz. An array of single characters indicating the intervals that should
        be randomized. If an interval is included in this parameter the randomized time will use the defined
        interval time as the minimum value and the MaxIntervalDuration as the maximum value.
        Default: none.
        Supported Values:
            Stress(D)uration
            (W)armUpInterval
            (C)oolDownInterval
            (S)tressInterval
            (R)estInterval

    .PARAMETER MaxIntervalDuration
        OPTIONAL. Integer. Alias: -md. The maximum time, in minutes, to use for interval randomization.
        Default: 1440 (24 hours)

    .PARAMETER NoCPU
        OPTIONAL. Switch. Alias: -nc. Disables CPU tests.

    .PARAMETER NoMemory
        OPTIONAL. Switch. Alias: -nm. Disables memory tests.

    .PARAMETER NoExit
        OPTIONAL. Switch. Alias: -nx. Prevents the PowerShell process from exiting after the Cool Down Interval
        has ended. Use this setting to emulate a service in k8s or other systems that use a scheduler so the
        StressDuration parameter is honored and scheduler doesn't keep restarting the the container/pod.

    .PARAMETER NoStress
        OPTIONAL. Switch. Alias: -ns. Disables all testing stress intervals (warm, stress, rest, cool).
        Use this to:
         - Dump the debugging with the ShowDebugData switch and then immediately exit.
         - Run a webserver with the EnableWebServer and NoExit switches.

    .PARAMETER ShowDebugData
        OPTIONAL. Switch. Alias: -dd. Dumps all environment variables and data used by the module.

    .PARAMETER ShowPodInfo
        OPTIONAL. Switch. Alias: -pi. Dumps all environment variables that have a PSPOD_INFO_ prefix.

    .PARAMETER EnableWebServer
        OPTIONAL. Switch. Alias: -ws. Enables a webserver which displays the console log messages. Enabling a
        WebServer requires administrative access. In a Windows container that means the process must be run as
        the ContainerAdministrator context. On Windows, non-container installations where administrative access
        is not detected the process will attempt to use the PowerShell RunAs argument and the user will be
        prompted to provide access.

    .PARAMETER WebServerPort
        OPTIONAL. INT. Alias: -wp. Sets the WebServer port. Default: 8080

    .PARAMETER SendMessages
        OPTIONAL. Switch. Alias: -sm. Logs and sends a console message every 15 seconds.

    .PARAMETER MessagePrefix
        OPTIONAL. STRING. Alias: -mp. A block of text that prefixes every message sent via the SendMessages
        switch. Use something unique to easily find it in the log system.

    .PARAMETER EnableConsoleLogs
        OPTIONAL. Switch. Alias: -cl. Send the web server user access logs and the message logs to standard out.

    .EXAMPLE

        Start-Testing -sd 60 -wi 2 -ci 0 -si 5 -ri 5 -RandomizeIntervals d,s,r -NoExit

    #>
    [CmdletBinding()]
    param (
        [Parameter()] [Alias('sd')] [ValidateRange(0, [int]::MaxValue)] [Int]      $StressDuration      = 10,
        [Parameter()] [Alias('wi')] [ValidateRange(0, [int]::MaxValue)] [Int]      $WarmUpInterval      = 1,
        [Parameter()] [Alias('ci')] [ValidateRange(0, [int]::MaxValue)] [Int]      $CoolDownInterval    = 0,
        [Parameter()] [Alias('si')] [ValidateRange(0, [int]::MaxValue)] [Int]      $StressInterval      = 5,
        [Parameter()] [Alias('ri')] [ValidateRange(0, [int]::MaxValue)] [Int]      $RestInterval        = 5,
        [Parameter()] [Alias('ct')] [ValidateRange(0, [int]::MaxValue)] [Int]      $CpuThreads          = 0,
        [Parameter()] [Alias('mt')] [ValidateRange(0, [int]::MaxValue)] [Int]      $MemThreads          = 0,
        [Parameter()] [Alias('rz')] [ValidateSet("d","w","c","s","r")]  [String[]] $RandomizeIntervals  = @(),
        [Parameter()] [Alias('md')] [ValidateRange(0, [int]::MaxValue)] [Int]      $MaxIntervalDuration = 1440,
        [Parameter()] [Alias('nc')]                                     [Switch]   $NoCPU,
        [Parameter()] [Alias('nm')]                                     [Switch]   $NoMemory,
        [Parameter()] [Alias('ns')]                                     [Switch]   $NoStress
    )

    begin
    {
      # Create a PSCustomObject to load all test data.
        [PSCustomObject] $testData = @{ BoundParameters = $PSBoundParameters }

      # Add and calculate remaining values
        $testData = $testData | Add-CallParameters |
                                Add-PhysicalMemory | Add-LogicalCores |
                                Update-MemoryThreadCount | Update-CpuThreadCount |
                                Update-MaxStressDuration | Update-RandomizedIntervals | Add-TotalIntervalTime |
                                Add-UserMessages
    }

    process
    {
        try {

            if ( $NoStress ) {
                Write-Info -p -ps -m $testData.messages.nostress
            }
            else {
                Write-EventMessages -m $testData.messages.start -d $testData.TotalIntervalTime

                Write-Info -m $testData.messages.cputhreads
                Write-Info -m $testData.messages.memthreads
                Write-Info -m $testData.messages.warmint
                Write-Info -m $testData.messages.coolint
                Write-Info -m $testData.messages.strescyc
                Write-Info -m $testData.messages.stresint
                Write-Info -m $testData.messages.restint
                Write-Info -m $testData.messages.randomized

                Write-EventMessages -m $testData.messages.warm -d $testData.WarmUpInterval -Wait
                Write-EventMessages -m $testData.messages.startcycle -d $testData.StressDuration

                Invoke-StressTests -TestData $testData

                Write-EventMessages -m $testData.messages.cool -d $testData.CoolDownInterval -Wait
                Write-Info -p -ps -m $testData.messages.completed
            }

        }
        catch {
            Write-Info -e -m $testData.messages.error
            $_
            Start-Sleep -Seconds 10
        }
    }
}
