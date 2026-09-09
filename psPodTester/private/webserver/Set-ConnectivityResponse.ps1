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

            $row = '<tr valign="top"><td nowrap>{0}</td><td></td><td>{1}</td></tr>' + $nl
            
            $userContent = '<div class="item-card">' + $nl +
                           '<h3 style="margin-top: 0.5rem;">External Connectivity Test</h3>' + $nl

          # Pod Information
            if ( $env:PSPOD_WEBS_ShowPodInfo ) {
                $userContent += '</br><h4 style="margin-top: 0.5rem;">' + 
                                'Pod Information</h4>' + $nl +
                                '<table width="90%" cellpadding=4 cellspacing=4>' + $nl
                $userContent += $( $row -f 'Pod Name',      $($env:PSPOD_INFO_POD_NAME) )
                $userContent += $( $row -f 'Pod IP',        $($env:PSPOD_INFO_POD_IP) )
                $userContent += $( $row -f 'Pod Namespace', $($env:PSPOD_INFO_POD_NAMESPACE) )
                $userContent += $( $row -f 'Node Name',     $($env:PSPOD_INFO_NODE_NAME) )
                $userContent += $( $row -f 'Node IP',       $($env:PSPOD_INFO_NODE_IP) )
                $userContent += '</table>' + $nl
            }

          # Cloudflare Trace
             try {
                $trace = @{}
                $r = Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace" -UseBasicParsing
                if ($r.StatusCode -eq 200) {
                    $r.Content -split "`n" | Where-Object { $_ -match "=" } | ForEach-Object {
                        $key, $value = $_ -split "=", 2
                        $trace[$key] = $value
                    }
                    $userContent += '</br><h4 style="margin-top: 0.5rem;">' + 
                                    'Cloudflare Trace Information (www.cloudflare.com/cdn-cgi/trace)</h4>' + $nl +
                                    '<table width="90%" cellpadding=4 cellspacing=4>' + $nl
                    $userContent += $( $row -f 'Public IP',                $trace.ip )
                    $userContent += $( $row -f 'Location',                 $trace.loc )
                    $userContent += $( $row -f 'User Agent',               $trace.uag )
                    $userContent += $( $row -f 'Host',                     $trace.h )
                    $userContent += $( $row -f 'Cloudflare Edge Location', $trace.colo )
                    $userContent += $( $row -f 'Scheme',                   $trace.visit_scheme )
                    $userContent += $( $row -f 'HTTP Version',             $trace.http )
                    $userContent += $( $row -f 'TLS Version',              $trace.tls )
                    $userContent += $( $row -f 'SNI',                      $trace.sni )
                    $userContent += '</table>' + $nl
                }
                else {
                    $userContent += "Cloudflare trace failed. Status code: $($r.StatusCode)</br></br>" + $nl
                }
            }
            catch {
                $userContent += "Cloudflare trace failed. Status code: $($_.Exception.Message)</br></br>" + $nl
            }

          # IP-API Information
             try {
                $r = Invoke-WebRequest -Uri "http://ip-api.com/json/$($trace.ip)" -UseBasicParsing
                if ($r.StatusCode -eq 200) {
                    $ipr = $r.Content | ConvertFrom-JSON
                    $userContent += '</br><h4 style="margin-top: 0.5rem;">' + 
                                    'IP-API Information (ip-api.com)</h4>' + $nl +
                                    '<table cellpadding=4 cellspacing=4>' + $nl
                    $userContent += $( $row -f 'ISP',          $ipr.isp )
                    $userContent += $( $row -f 'Org',          $ipr.org )
                    $userContent += $( $row -f 'AS Number',    $ipr.as )
                    $userContent += $( $row -f 'Country',      $ipr.country )
                    $userContent += $( $row -f 'Country Code', $ipr.countryCode )
                    $userContent += $( $row -f 'Region',       $ipr.region )
                    $userContent += $( $row -f 'Region Name',  $ipr.regionName )
                    $userContent += $( $row -f 'Timezone',     $ipr.timezone )
                    $userContent += '</table>' + $nl
                }
                else {
                    $userContent += "IP-API query failed. Status code: $($r.StatusCode)</br></br>" + $nl
                }
            }
            catch {
                $userContent += "IP-API query failed. Status code: $($_.Exception.Message)</br></br>" + $nl
            }

            $userContent += '</div>'

            $ServerEvent.content.user = $userContent

        }
        catch {
            write-host $_.Exception.Message
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
