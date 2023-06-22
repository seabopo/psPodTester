function Invoke-LogMessages
{
    <#
    .DESCRIPTION
        Sends log messages every 15 seconds.
    #>
    [CmdletBinding()]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $MessagePrefix )

    process
    {
        Write-Info -p -ps -m $testData.messages.startmsgs

        Start-Job -ScriptBlock {
            foreach ( $number in 1..2147483647) {
                $log = $( "[{0}] {1}: {2} {3}." -f $(Get-Date -Format s),$using:MessagePrefix,'Message #',$number)
                $log | Out-File $using:WS_MSG_LOG_PATH -Append
                Write-Host $log
                Start-Sleep -Seconds 15
            }
        } | Out-Null

    }
}
