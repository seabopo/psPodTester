function Test-UserCanRunAs {
    <#
    .DESCRIPTION
        Tests if a user has the rights to perform a 'RunAs' action.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $canRunAs = $false

    if ( $IsWindows ) {
        try {
            Start-Process -FilePath "pwsh" -Verb RunAs -PassThru -ArgumentList('dir') | Out-Null
            $canRunAs = $true
        }
        catch { }
    }
    $env:PSPOD_ENV_CanRunAs = ( $canRunAs ? 1 : 0 )

    return $canRunAs
}
