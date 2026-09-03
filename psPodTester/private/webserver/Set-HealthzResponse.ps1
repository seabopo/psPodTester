function Set-HealthzResponse {
    <#
    .DESCRIPTION
        Sets the Healthz response.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent,
        [Parameter()]                                          [Switch]    $Stop
    )

    process {

        try {

            if ( $Stop.IsPresent ) {
                $PS.healthz.enabled    = $true
                $PS.healthz.status     = 'Service Unavailable'
                $PS.healthz.statusCode = 503
                Write-Info -f a -p -ps -m $PS.usrmsg.healthz.stopped
                $ServerEvent | Set-FileResponse -f $PS.path.appLog -t 'Application Log' -p
            }
            elseif ( $PS.healthz.enabled ) {
                $ServerEvent.content.user           = $PS.healthz.status
                $ServerEvent.content.responseCode   = $PS.healthz.statusCode
                $ServerEvent.content.responseStatus = $PS.healthz.status
                $ServerEvent.content.contentType    = 'text/plain'
            }

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
