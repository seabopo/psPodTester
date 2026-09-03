function Set-FileResponse {
    <#
    .DESCRIPTION
        Sets the response variables and actions for the selected log file.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]                            [Alias('f')]  [String]    $FilePath,
        [Parameter()]                            [Alias('t')]  [String]    $PageTitle,
        [Parameter()]                            [Alias('p')]  [Switch]    $PreFormatted,
        [Parameter(Mandatory,ValueFromPipeline)] [Alias('se')] [Hashtable] $ServerEvent
    )

    process {

        try {

            $userContent = $( (Get-Content -Path $FilePath) -Join [System.Environment]::NewLine )

            if ( $PreFormatted ) {
                $userContent = '<pre>' + $userContent + '</pre>'
            }
            else {
                $userContent = '<p>' + $userContent + '</p>'
            }

            if ( $PageTitle ) {
                $userContent = '<h3 style="margin-top: 0.5rem;">' + $PageTitle + '</h3></br>' + $userContent
            }

            $userContent = '<div class="item-card">' + $userContent + '</div>'

            $ServerEvent.content.user = $userContent

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            Start-Sleep -Seconds 1
        }

    }
}
