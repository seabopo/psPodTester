function Test-UserCanRunAs
{
    <#
    .DESCRIPTION
        Tests if a user has the rights to perform a 'RunAs' action.
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    try {
        $proc = Start-Process -FilePath "pwsh" -Verb RunAs -PassThru -ArgumentList('dir')
        $testData.Add('UserCanRunAs',$true)
    }
    catch {
        $testData.Add('UserCanRunAs',$false)
    }

    return $testData
}
