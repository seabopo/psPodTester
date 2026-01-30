function Start-LogMessages
{
    <#
    .DESCRIPTION
        Sends log messages every 15 seconds.
    #>
    [CmdletBinding()]
    param (
        [Parameter()] [Alias('p')] [String] $MessagePrefix,
        [Parameter()] [Alias('f')] [String] $LogFilePath,
        [Parameter()] [Alias('c')] [Switch] $EnableConsoleLogs
    )

    process {

        Write-Info -p -ps -m $( $USER_MESSAGES.startmsgs -f $MessagePrefix )

        $f = $LogFilePath
        $p = $MessagePrefix
        $c = $EnableConsoleLogs

        $cmd = {
            param( [string] $MessagePrefix, [string] $FilePath, [boolean] $EnableConsoleLogs)
            foreach ( $number in 1..2147483647) {
                $msg = '{0} {1}: {2} {3}.' -f $(Get-Date -Format s),$MessagePrefix,'Message #',$number
                $msg | Out-File $filePath -Append
                if ( $EnableConsoleLogs ) { Write-Host $msg }
                $waitTime = $( ([int]$number -le 120) ? 15 : (([int]$number -le 150) ? 60 : 900) )
                Start-Sleep -Seconds $waitTime
            }
        }
        Start-Process pwsh -ArgumentList "-command (Invoke-Command -ScriptBlock {$cmd} -ArgumentList $p,$f,$c)"

    }
}
