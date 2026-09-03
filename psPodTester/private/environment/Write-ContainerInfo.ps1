function Write-ContainerInfo {
    <#
    .DESCRIPTION
        Writes information about the container to the log files.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    if ( $PS.webServer.showPodInfo ) {

        Write-Info -f a,d -p -ps -m $( $PS.usrmsg.app.podInfo )

        Write-Info -f d -ps -m $( $PS.usrmsg.app.podEnvHdr )
        Write-Info -f d -m $( $PS.usrmsg.app.container  -f $PS.env.isContainer )
        Write-Info -f d -m $( $PS.usrmsg.app.platform   -f $PS.env.osPlatform, $PS.env.osVersion )
        Write-Info -f d -m $( $PS.usrmsg.app.isArmCpu   -f $PS.env.isArmCpu )
        Write-Info -f d -m $( $PS.usrmsg.app.hostHasCIM -f $PS.env.hostHasCIM )
        Write-Info -f d -m $( $PS.usrmsg.app.cores      -f $PS.env.logicalCores )
        Write-Info -f d -m $( $PS.usrmsg.app.memory     -f $PS.env.physicalMemory )
        Write-Info -f d -m $( $PS.usrmsg.app.adminuser  -f $PS.env.userIsAdmin )
        Write-Info -f d -m $( $PS.usrmsg.app.runasuser  -f $PS.env.userCanRunAs )
        Write-Info -f d -m $( $PS.usrmsg.app.runwsuser  -f $PS.env.userCanRunWS )

        Write-Info -f d -ps -m $( $PS.usrmsg.app.podInfoHdr )

        $envVariables = Get-Item -Path Env:\PSPOD_INFO_* | ForEach-Object { $_ } | Sort-Object -Property Name

        if ( $envVariables.Count -eq 0 ) {
            Write-Info -f d -m $( $PS.usrmsg.app.nonefound )
        }
        else {
            foreach ( $variable in $envVariables ) {
                Write-Info -f d -m $("... {0}: {1}" -f $variable.Name, $variable.Value )
            }
        }

    }
    else {
        Write-Info -f a,d -m $( $PS.usrmsg.app.noPodInfo )
    }

}
