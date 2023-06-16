function Invoke-StressTests
{
    <#
    .DESCRIPTION
        Runs CPU and memory stress tests.
    #>
    [CmdletBinding()]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    process
    {
        do {

            if ( $stress ) { $stress = $false; $rest = $true;  $duration = $testData.RestInterval   }
            else           { $stress = $true;  $rest = $false; $duration = $testData.StressInterval }

            if ( ($stress -and $testData.RandomizeStress) -or ($rest -and $testData.RandomizeRest) ) {
                $duration = Get-Random -Minimum $duration -Maximum $testData.MaxStressCycleInterval
            }

            if ( ( (Get-Date) + (New-TimeSpan -Minutes $duration) ) -gt $testData.StressEndTime ) {
                $duration = (NEW-TIMESPAN -Start ( Get-Date ) -End $testData.StressEndTime).Minutes
            }

            if ( $stress -and $duration -gt 0 ) {

                Write-EventMessages -m $testData.messages.stress `
                                    -d $duration `
                                    -c $testData.CPUthreads `
                                    -r $testData.MEMthreads

                if ( $testData.CPUthreads -gt 0 ) {
                    foreach ( $thread in 1..$testData.CPUthreads ){
                        Start-Job -ScriptBlock {
                            foreach ( $number in 1..2147483647)  {
                                1..2147483647 | ForEach-Object { $x = 1 }{ $x = $x * $_ }
                            }
                        } | Out-Null
                    }
                }

                if ( $testData.MEMthreads -gt 0 ) {
                    foreach ( $thread in 1..$testData.MEMthreads ){
                        Start-Job -ScriptBlock {
                            1..50 | ForEach-Object { $x = 1 }{ [array]$x += $x }
                        } | Out-Null
                    }
                }

                Write-Info -m $( $testData.messages.jobs -f @(get-job).count )

                $duration..1 | ForEach-Object {
                    Write-Info -m $( $testData.messages.countdown -f $_ )
                    Start-Sleep -Seconds 60
                }

                Write-Info -m $testData.messages.cleanup
                get-job | stop-job
                get-job | Remove-Job
               #[System.GC]::GetTotalMemory(‘forcefullcollection’) | out-null
                [System.GC]::Collect()
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()

                Write-Info -m $testData.messages.complete

            }
            elseif ( $rest -and $duration -gt 0 ) {

                Write-EventMessages -m $testData.messages.rest -d $duration -wait

            }

        } until ( (Get-Date) -ge $testData.StressEndTime )
    }
}
