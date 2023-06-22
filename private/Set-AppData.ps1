function Add-CallParameters
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

  # Add all of the calling function's Parameters and default values
    (Get-PSCallStack)[1].InvocationInfo.MyCommand.ScriptBlock.Ast.Body.ParamBlock.Parameters |
        ForEach-Object {
            if ( $_.StaticType.Name -eq 'SwitchParameter' -and $null -eq $_.DefaultValue ) {
                $testData.Add( $_.Name.VariablePath.UserPath.ToString(), $false )
            }
            else {
                $testData.Add( $_.Name.VariablePath.UserPath.ToString(), $_.DefaultValue.Value )
            }
        }

  # Overwrite default values with any passed values.
    $testData.BoundParameters.GetEnumerator() |
        ForEach-Object {
            if ( $testData.ContainsKey($_.key) ) { $testData[$_.key] = $_.value }
        }

    $testData.Remove('BoundParameters')

    return $testData
}

function Test-UserIsAdmin
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

    $testData.Add('UserIsAdmin',$isAdmin)

    return $testData
}

function Test-IsContainer
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $isContainer = $false

    if ( $IsWindows ) {
        if     ( $(Get-Service -Name cexecsvc -ErrorAction SilentlyContinue) )   { $isContainer = $true }
        elseif ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*PSDocker*' )       { $isContainer = $true }
        elseif ( $env:USERNAME -in @('ContainerUser','ContainerAdministrator') ) { $isContainer = $true }
    }

    $testData.Add('isContainer',$isContainer)

    return $testData
}

function Test-IsNanoServer
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $isNanoServer = $false

    if ( $IsWindows ) {
        if ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*NanoServer*' ) { $isNanoServer = $true }
    }

    $testData.Add('isNanoServer',$isNanoServer)

    return $testData
}

function Add-PhysicalMemory
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $physicalMemory = $null

    if ( $IsWindows ) {
        if ( $null -eq $(Get-Service -Name cexecsvc -ErrorAction SilentlyContinue) ) {
            $physicalMemory = [math]::Round((Get-ComputerInfo).OsTotalVisibleMemorySize/1024)
        }
    }

    $testData.Add('PhysicalMemory',$physicalMemory)

    return $testData
}

function Add-LogicalCores
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $logicalCores = $null

    if ( $IsWindows ) {
        if ( $testData.IsContainer ) { $logicalCores = $Env:NUMBER_OF_PROCESSORS }
        else { $logicalCores = (Get-ComputerInfo).CsNumberOfLogicalProcessors }
    }

    $testData.Add('LogicalCores',$logicalCores)

    return $testData
}

function Update-MemoryThreadCount
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    if ( $testData.MemThreads -eq 0 ) {
         $testData.MemThreads = if ( $testData.NoMemory ) { 0 }
                                elseif ($testData.PhysicalMemory -gt 16384 ) { 2 }
                                else { 1 }
    }

    return $testData
}

function Update-CpuThreadCount
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    if ( $testData.CpuThreads -eq 0 ) {
         $testData.CpuThreads = if     ( $testData.NoCPU )            { 0 }
                                elseif ( $testData.LogicalCores )     { $testData.LogicalCores - $testData.MemThreads }
                                elseif ( $testData.MemThreads -ge 2 ) { 0 }
                                else                                  { 2 - $testData.MemThreads }
    }

    return $testData
}

function Update-MaxStressDuration
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    if ( $testData.StressDuration -eq 0 ) { $testData.StressDuration = [int32]::MaxValue }

    return $testData
}

function Update-RandomizedIntervals
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    if ( $testData.RandomizeIntervals ) {

        if ( $testData.RandomizeIntervals.Contains('d') -and $testData.StressDuration -ne [int32]::MaxValue ) {
             $testData.StressDuration = Get-Random -Minimum $testData.StressDuration `
                                                   -Maximum $testData.MaxIntervalDuration
        }

        if ( $testData.RandomizeIntervals.Contains('w') ) {
             $testData.WarmUpInterval = Get-Random -Minimum $testData.WarmUpInterval `
                                                   -Maximum $testData.MaxIntervalDuration
        }

        if ( $testData.RandomizeIntervals.Contains('c') ) {
             $testData.CoolDownInterval = Get-Random -Minimum $testData.CoolDownInterval `
                                                     -Maximum $testData.MaxIntervalDuration
        }

        $testData.Add('RandomizeStress',$RandomizeIntervals.Contains('s'))
        $testData.Add('RandomizeRest',$RandomizeIntervals.Contains('r'))
    }
    else {
        $testData.Add('RandomizeStress',$false)
        $testData.Add('RandomizeRest',$false)
    }

    $stressEndTime = (Get-Date) + ( New-TimeSpan -Minutes $StressDuration )

    $maxSCinterval = if ( $testData.StressDuration -lt $testData.MaxIntervalDuration ) { $testData.StressDuration }
                     else { $testData.MaxIntervalDuration }

    $testData.Add('StressEndTime',$stressEndTime)
    $testData.Add('MaxStressCycleInterval',$maxSCinterval)

    return $testData
}

function Add-TotalIntervalTime
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $totalIntervalTime = if ( $testData.NoStress ) { 0 }
                         else { $testData.WarmUpInterval + $testData.StressDuration + $testData.CoolDownInterval }

    $testData.Add('TotalIntervalTime',$totalIntervalTime)

    return $testData
}

function Add-UserMessages
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    if ( $testData.RandomizeIntervals ) {
        $stressVal = $testData.RandomizeIntervals.Contains('s') ?
                     $('{0}-{1}' -f $testData.StressInterval, $testData.MaxStressCycleInterval) :
                     $testData.StressInterval
        $restVal   = $testData.RandomizeIntervals.Contains('r') ?
                     $('{0}-{1}' -f $testData.RestInterval, $testData.MaxStressCycleInterval) :
                     $testData.RestInterval
        $randVal   = $testData.RandomizeIntervals -join ','
    }
    else {
        $stressVal = $testData.StressInterval
        $restVal   = $testData.RestInterval
        $randVal   = ''
    }

    $messages = @{

        start      = "Starting ..."
        warm       = "Starting warm up interval ..."
        startcycle = "Starting stress/rest interval cycle ..."
        stress     = "Starting stress interval ..."
        rest       = "Starting rest interval ..."
        cool       = "Starting cool down interval ..."
        completed  = "All intervals completed."
        error      = "Intervals failed."
        noexit     = "The NoExit switch was detected.`r`nThis process will now wait indefinitely."
        exit       = "The process is now exiting ..."
        nostress   = "The NoStress switch was detected.`r`nAll stress intervals will be skipped."
        podinfo    = "POD Information"
        startmsgs  = "The SendMessages switch was detected.`nLogging test messages with prefix '{0}' every 15 seconds ..." -f $testData.MessagePrefix

        warmint    = "... Warm Interval: {0} minutes"   -f $testData.WarmUpInterval
        coolint    = "... Cool Interval: {0} minutes"   -f $testData.CoolDownInterval
        strescyc   = "... Stress Cycle: {0} minutes"    -f $testData.StressDuration
        stresint   = "... Stress Interval: {0} minutes" -f $stressVal
        restint    = "... Rest Interval: {0} minutes"   -f $restVal
        randomized = "... Randomized Interval(s): {0}"  -f $randVal
        cputhreads = "... CPU Threads: {0}"             -f $testData.CPUthreads
        memthreads = "... Memory Threads: {0}"          -f $testData.MEMthreads

        container  = "... Running in Container: {0}"   -f $testData.isContainer
        adminuser  = "... User is Admin: {0}"          -f $testData.UserIsAdmin

        startingws = "Starting web server ..."
        wselevate  = "... User does not have admin rights. Attempting to elevate ..."
        startedws  = "... Web server started on port {0}." -f $testData.WebServerPort
        nostartws  = "... CANNOT START WEB SERVER. User does not have admin rights."

        jobs      = "... Jobs started: {0}"
        countdown = "... Interval will complete in {0} minute(s) ..."
        cleanup   = "... Cleaning up jobs ..."
        complete  = "... Interval complete."
    }

    $testData.Add('Messages',$messages)

    return $testData
}















function Test-HasCIM
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $hasCIM = $false

    if ( $IsWindows ) {
        try {
            Get-CimInstance -ClassName Win32_ComputerSystem
            $hasCIM = $true
        }
        catch { }
    }

    $testData.Add('HasCIM',$hasCIM)

    return $testData
}

function Test-UserCanRunAs
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    try {
        $proc = Start-Process -FilePath "pwsh" -Verb RunAs -PassThru -ArgumentList('dir')
        $testData.Add('UserCanRunAs',$true)
    }
    catch {
        $testData.Add('UserCanRunAs',$false)
    }

    return $testData
}

function Test-UserCanRunWebServer
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

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
