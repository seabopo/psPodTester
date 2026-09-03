function Start-Messaging {
    <#
    .DESCRIPTION
        Sends log messages at predetermined intervals.
    #>
    [CmdletBinding()]
    param ()

    process {

        try {

            Write-Info -f a,m -ps -i -m $( $PS.usrmsg.msg.start -f $($PS.messages.prefix), $($PS.messages.period) )

            foreach ( $number in 1..2147483647) {
                $msg = '{0} {1}: {2} {3}.' -f $(Get-Date -Format s),$($PS.messages.prefix),'Message #',$number
                $msg | Out-File $($PS.path.msgLog) -Append
                Write-Host $msg
                Start-Sleep -Seconds $([int] $PS.messages.period)
            }

        }
        catch {

            Write-Info -f a,m -e -l -m $PS.usrmsg.msg.error
            Write-Info -f a,m -e -l -m $_.Exception.Message
            $_
            Start-Sleep -Seconds 10

        }

    }
}
