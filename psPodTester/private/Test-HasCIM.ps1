function Test-HasCIM
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    $hasCIM = $false

    if ( $IsWindows ) {
        try {
            Get-CimInstance -ClassName Win32_ComputerSystem
            $hasCIM = $true
        }
        catch { }
    }

    return $hasCIM
}
