#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

    Set-Location  -Path $(Split-Path $MyInvocation.MyCommand.Path)
    Push-Location -Path $(Split-Path $MyInvocation.MyCommand.Path)

    $scriptRootPath = $(Split-Path $MyInvocation.MyCommand.Path)
    $repoRootPath   = $((Get-Item $scriptRootPath).Parent.FullName)
    $repoName       = $($repoRootPath | Split-Path -Leaf)
    $modulePath     = Join-Path -Path $repoRootPath -ChildPath $repoName

    Import-Module $modulePath -Force
