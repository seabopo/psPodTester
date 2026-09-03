function Test-UserIsAdmin {
    <#
    .DESCRIPTION
        Determines if PowerShell is running in admin mode. PowerShell can't start the Web Server in a
        Windows container if it runs under the normal user context.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $isAdmin = $false

    if ( $env:PSPOD_ENV_IsAdmin) {
        $isAdmin = [bool] [int] $env:PSPOD_ENV_IsAdmin
    }
    else {
        if ( $IsWindows ) {
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
            $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        $env:PSPOD_ENV_IsAdmin = ( $isAdmin ? 1 : 0 )
    }

    return $isAdmin
}
