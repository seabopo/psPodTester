function Write-UserLogEntry {
    <#
    .DESCRIPTION
        Writes an an entry to the user log for the last user request.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $log = $( "{0} {1} {2} {3} {4}" -f $(Get-Date -Format s),
                    $ServerEvent.request.RemoteEndPoint.Address.ToString(),
                    $ServerEvent.request.httpMethod,
                    $ServerEvent.request.UserHostName,
                    $ServerEvent.request.Url.PathAndQuery )

            $log | Out-File $PS.path.usrLog -Append

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
