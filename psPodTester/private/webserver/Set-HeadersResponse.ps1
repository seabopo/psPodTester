function Set-HeadersResponse {
    <#
    .DESCRIPTION
        Sets the response variables and actions for the selected log file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $nl = [System.Environment]::NewLine

            $userContent = '<div class="item-card">' + $nl +
                           '<h3 style="margin-top: 0.5rem;">HTTP Headers</h3></br>' + $nl +
                           '<table width="90%" cellpadding=4 cellspacing=4>' + $nl +
                           '<tr><td><b>Name</b></td><td width=10></td><td><b>Value</b></td></tr>' + $nl

            $ServerEvent.request.headers | Sort-Object | ForEach-Object {
                $userContent += ('<tr valign="top"><td nowrap>{0}</td><td></td><td>{1}</td></tr>' -f
                                $_,$($ServerEvent.request.headers[$_])) + $nl
            }

            $userContent += '</table>' + $nl + '</div>'

            $PS.webServer.content.user = $userContent

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
