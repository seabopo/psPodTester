function Test-IsContainer {
    <#
    .DESCRIPTION
        Determines if PowerShell is running in a container.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    if ( $env:PSPOD_ENV_IsContainer ) {
        $isContainer = [bool] [int] $env:PSPOD_ENV_IsContainer
    }
    else {

        $isContainer = $false

        if ( $IsWindows ) {
            if     ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*PSDocker*' )       { $isContainer = $true }
            elseif ( $env:USERNAME -in @('ContainerUser','ContainerAdministrator') ) { $isContainer = $true }
            elseif ( $(Get-Service -Name cexecsvc -ErrorAction SilentlyContinue) )   { $isContainer = $true }
            elseif ( (Get-Process | Measure-Object).Count -lt 3 )                    { $isContainer = $true }
        }
        else {
            if     ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*PSDocker*' ) { $isContainer = $true }
            elseif ( (Get-Process | Measure-Object).Count -lt 3 )              { $isContainer = $true }
        }

        $env:PSPOD_ENV_IsContainer = ( $isContainer ? 1 : 0 )

    }

    return $isContainer
}
