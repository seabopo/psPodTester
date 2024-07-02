function Invoke-LogMessages
{
    <#
    .DESCRIPTION
        Sends log messages every 15 seconds.
    #>
    [CmdletBinding()]
    param ()

    process {

        $f = $WS_MSG_LOG_PATH
        $p = $env:PSPOD_TEST_MessagePrefix ?? 'psPodTesterMessagePrefix'
        $c = $env:PSPOD_TEST_EnableConsoleLogs ? $true : $false

        Start-LogMessages -MessagePrefix "$p" -LogFilePath "$f" -EnableConsoleLogs:$c

    }
}
