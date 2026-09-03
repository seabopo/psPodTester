function Send-WebResponse {
    <#
    .DESCRIPTION
        Sends a response to a user request.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $isPlainText = ( $ServerEvent.content.contentType -eq 'text/plain' )

            $ResponseText = $isPlainText ? $ServerEvent.content.user : (
                            $ServerEvent.content.pageHeader +
                            $ServerEvent.content.sidebarTesting +
                            $ServerEvent.content.header +
                            $ServerEvent.content.user +
                            $ServerEvent.content.pageFooter )

            $buffer = [Text.Encoding]::UTF8.GetBytes($ResponseText)
            $ServerEvent.response.AddHeader("Server", "psPodTester")
            $ServerEvent.response.SendChunked       = $false
            $ServerEvent.response.ContentType       = $isPlainText ? 'text/plain' : 'text/HTML'
            $ServerEvent.response.ContentLength64   = $buffer.Length
            $ServerEvent.response.StatusCode        = $ServerEvent.content.responseCode
            $ServerEvent.response.StatusDescription = $ServerEvent.content.responseStatus
            $ServerEvent.response.OutputStream.Write($buffer, 0, $buffer.Length)
            $ServerEvent.response.Close()

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
