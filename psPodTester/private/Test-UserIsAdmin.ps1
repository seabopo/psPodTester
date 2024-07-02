function Test-UserIsAdmin
{
    <#
    .DESCRIPTION
        Determines if PowerShell is running in admin mode. PowerShell can't start the Web Server in a container
        if it runs under the normal user context.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

    Return $isAdmin
}
