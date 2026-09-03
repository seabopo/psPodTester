function Set-ConnectivityResponse {
    <#
    .DESCRIPTION
        Performs a WHOAMI request to confirm internet connectivity.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $nl = [System.Environment]::NewLine

            $response = Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -UseBasicParsing

            $trace = @{}
            $response.Content -split "`n" | Where-Object { $_ -match "=" } | ForEach-Object {
                $key, $value = $_ -split "=", 2
                $trace[$key] = $value
            }

            $row = '<tr valign="top"><td nowrap>{0}</td><td></td><td>{1}</td></tr>' + $nl
            
            $userContent = '<div class="item-card">' + $nl +
                           '<h3 style="margin-top: 0.5rem;">External Connectivity Test</h3></br>' + $nl +
                           '<table width="90%" cellpadding=4 cellspacing=4>' + $nl +
                           '<tr><td><b>Name</b></td><td width=10></td><td><b>Value</b></td></tr>' + $nl

            $userContent += $( $row -f 'Public IP',       $trace.ip )
            $userContent += $( $row -f 'Location',        $trace.loc )
            $userContent += $( $row -f 'User Agent',      $trace.uag )
            $userContent += $( $row -f 'Host',            $trace.h )
            $userContent += $( $row -f 'Cloudflare Colo', $trace.colo )
            $userContent += $( $row -f 'Scheme',          $trace.visit_scheme )
            $userContent += $( $row -f 'HTTP Version',    $trace.http )
            $userContent += $( $row -f 'TLS Version',     $trace.tls )
            $userContent += $( $row -f 'SNI',             $trace.sni )
            
            $userContent += '</table>' + $nl + '</div>'

            $ServerEvent.content.user = $userContent

        }
        catch {
            write-host $_.Exception.Message
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
