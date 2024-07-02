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
        if ( $ENV_ISCONTAINER ) { $logicalCores = $Env:NUMBER_OF_PROCESSORS }
        else { $logicalCores = (Get-ComputerInfo).CsNumberOfLogicalProcessors }
    }

    $testData.Add('LogicalCores',$logicalCores)

    return $testData
}

function Update-MemoryThreadCount
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $testData.MemThreads = if ( $testData.NoMemory ) { 0 }
                           elseif ( $testData.MemThreads -eq 0 ) { 2 }
                           else { $testData.MemThreads}

    if ( $testData.MemThreads -lt 0 ) { 0 }

    return $testData
}

function Update-CpuThreadCount
{
    [CmdletBinding()] [OutputType([PSCustomObject])]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    $testData.CpuThreads = if ( $testData.NoCPU ) { 0 }
                           elseif ( $testData.CpuThreads -eq 0 -and $null -eq $testData.LogicalCores ) { 2 }
                           elseif ( $testData.CpuThreads -eq 0 -and $testData.LogicalCores ) { $testData.LogicalCores }
                           else { $testData.CpuThreads }

    if ( $testData.CpuThreads -lt 0 ) { 0 }

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

        start      = "Starting tests..."
        warm       = "Starting warm up interval ..."
        startcycle = "Starting stress/rest interval cycle ..."
        stress     = "Starting stress interval ..."
        rest       = "Starting rest interval ..."
        cool       = "Starting cool down interval ..."
        completed  = "All intervals completed."
        error      = "Intervals failed."
        nostress   = "The NoStress switch was detected.`r`nAll stress intervals will be skipped."

        warmint    = "... Warm Interval: {0} minutes"   -f $testData.WarmUpInterval
        coolint    = "... Cool Interval: {0} minutes"   -f $testData.CoolDownInterval
        strescyc   = "... Stress Cycle: {0} minutes"    -f $testData.StressDuration
        stresint   = "... Stress Interval: {0} minutes" -f $stressVal
        restint    = "... Rest Interval: {0} minutes"   -f $restVal
        randomized = "... Randomized Interval(s): {0}"  -f $randVal
        cputhreads = "... CPU Threads: {0}"             -f $testData.CPUthreads
        memthreads = "... Memory Threads: {0}"          -f $testData.MEMthreads

        jobs      = "... Jobs started: {0}"
        countdown = "... Interval will complete in {0} minute(s) ..."
        cleanup   = "... Cleaning up jobs ..."
        complete  = "... Interval complete."
    }

    $testData.Add('Messages',$messages)

    return $testData
}
