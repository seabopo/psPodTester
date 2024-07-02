function Test-IsContainer
{
    <#
    .DESCRIPTION
        Determines if PowerShell is running in a docker container published by Microsoft.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $isContainer = $false

    if ( $IsWindows ) {
        if     ( $(Get-Service -Name cexecsvc -ErrorAction SilentlyContinue) )   { $isContainer = $true }
        elseif ( $env:POWERSHELL_DISTRIBUTION_CHANNEL -like '*PSDocker*' )       { $isContainer = $true }
        elseif ( $env:USERNAME -in @('ContainerUser','ContainerAdministrator') ) { $isContainer = $true }
    }

    return $isContainer
}
