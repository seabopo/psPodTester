function Invoke-LogMessages
{
    <#
    .DESCRIPTION
        Sends log messages every 15 seconds.
    #>
    [CmdletBinding()]
    param ( [Parameter(Mandatory,ValueFromPipeline)] [PSCustomObject] $testData )

    process
    {
        Write-Info -p -ps -m $testData.messages.startmsgs

        $p = $testData.MessagePrefix
        $f = $WS_MSG_LOG_PATH
        $c = $testData.EnableConsoleLogs ? '$true' : '$false'

        $cmd = {
            param( [string] $MessagePrefix, [string] $FilePath, [boolean] $EnableConsoleLogs)
            foreach ( $number in 1..2147483647) {
                $msg = '[{0}] {1}: {2} {3}.' -f $(Get-Date -Format s),$MessagePrefix,'Message #',$number
                $msg | Out-File $filePath -Append
                if ( $EnableConsoleLogs ) { Write-Host $msg }
                Start-Sleep -Seconds 15
            }
        }
        Start-Process pwsh -ArgumentList "-command (Invoke-Command -ScriptBlock {$cmd} -ArgumentList $p,$f,$c)"

    }
}
