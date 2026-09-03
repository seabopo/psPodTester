function Write-EnvironmentInfo {
    <#
    .DESCRIPTION
        Writes the container environment variables to the log files
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    if ( $PS.webServer.showEnvVariables ) {

        Write-Info -f a,d -p -ps -m $( $PS.usrmsg.app.envInfo )

        Write-Info -f d -ps -m $( $PS.usrmsg.app.envInfoHdr )

        $envVariables = Get-Item -Path Env: | ForEach-Object { $_ } | Sort-Object -Property Name

        if ( $envVariables.Count -eq 0 ) {
            Write-Info -f d -m $( $PS.usrmsg.app.nonefound )
        }
        else {
            foreach ( $variable in $envVariables ) {
                $display = $true
                foreach ( $ignoreName in $PS.webServer.ignoreEnvVariables ) {
                    if ( $variable.Name -like $ignoreName ) { $display = $false; break }
                }
                if ( $display ) {
                    Write-Info -f d -m $("... {0}: {1}" -f $variable.Name, $variable.Value )
                }
            }
        }

    }
    else {
        Write-Info -f a,d -m $( $PS.usrmsg.app.noEnvInfo )
    }

}
