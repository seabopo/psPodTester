#==================================================================================================================
#==================================================================================================================
# psPodTester - Docker Run File
#==================================================================================================================
#==================================================================================================================
<#
    Calling this file from Windows:
    -------------------------------

        Remove-Item -Path Env:\PSPOD_TEST_*

        $env:PSPOD_TEST_StressDuration      = 10
        $env:PSPOD_TEST_WarmUpInterval      = 1
        $env:PSPOD_TEST_CoolDownInterval    = 1
        $env:PSPOD_TEST_StressInterval      = 1
        $env:PSPOD_TEST_RestInterval        = 1
        $env:PSPOD_TEST_CpuThreads          = 1
        $env:PSPOD_TEST_MemThreads          = 1

        $env:PSPOD_TEST_RandomizeIntervals  = "s,r"
        $env:PSPOD_TEST_MaxIntervalDuration = 10

        $env:PSPOD_TEST_NoCPU               = 1
        $env:PSPOD_TEST_NoMemory            = 1
        $env:PSPOD_TEST_NoExit              = 1

        $env:PSPOD_TEST_EnableWebServer     = 1
        $env:PSPOD_TEST_WebServerPort       = 8080

      NOTES:
       - PSPOD_TEST_NoCPU and PSPOD_TEST_NoMemory are exclusive. Only one may be used at a time.
       - PSPOD_TEST_NoCPU, PSPOD_TEST_NoMemory and PSPOD_TEST_NoExit are SWITCHES ... their presence indicates they should
         be used. Their value is irrelevant. If you don't want to enable these praramaters do not set their
         associated environment variables.

    Calling this file via Docker:
    -----------------------------

        docker run  --mount type=bind,source=C:\Repos\Github\psStress,target=C:\psStress `
                    -e "PSPOD_TEST_StressDuration=10" `
                    -e "PSPOD_TEST_WarmUpInterval=0" `
                    -e "PSPOD_TEST_CoolDownInterval=0" `
                    -e "PSPOD_TEST_StressInterval=1" `
                    -e "PSPOD_TEST_RestInterval=1" `
                    -e "PSPOD_TEST_RandomizeIntervals=s,r" `
                    -e "PSPOD_TEST_MaxIntervalDuration=5" `
                    -e "PSPOD_TEST_CpuThreads=1" `
                    -e "PSPOD_TEST_MemThreads=1" `
                    -e "PSPOD_TEST_NoExit=1" `
                    -it `
                    mcr.microsoft.com/powershell:nanoserver-1809 `
                    pwsh -ExecutionPolicy Bypass -command "/psstress/docker.ps1"

#>

Set-Location -Path $PSScriptRoot
Push-Location -Path $PSScriptRoot

Import-Module $(Split-Path $Script:MyInvocation.MyCommand.Path) -Force

$switchParams = @('PSPOD_TEST_NoCPU','PSPOD_TEST_NoMemory','PSPOD_TEST_NoStress','PSPOD_TEST_NoExit',
                  'PSPOD_TEST_EnableWebServer', 'PSPOD_TEST_EnableConsoleLogs',
                  'PSPOD_TEST_ShowDebugData', 'PSPOD_TEST_ShowPodInfo', 'PSPOD_TEST_SendMessages')
$arrayParams  = @('PSPOD_TEST_RandomizeIntervals')

$params = @{}

if ( $env:PSPOD_PRESET_Webserver ) {
    write-host "`nThe Webserver preset was found. Enabling settings ..." -ForegroundColor Magenta
    $env:PSPOD_TEST_EnableWebServer     = 1
    $env:PSPOD_TEST_NoStress            = 1
    $env:PSPOD_TEST_NoExit              = 1
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_WebServerPort) ) {
        $env:PSPOD_TEST_WebServerPort = 80
    }
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_SendMessages) ) {
        $env:PSPOD_TEST_SendMessages = 1
    }
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_MessagePrefix) ) {
        $env:PSPOD_TEST_MessagePrefix = 'psPodTesterMessagePrefix'
    }
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_ShowDebugData) ) {
        $env:PSPOD_TEST_ShowDebugData = 1
    }
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_EnableConsoleLogs) ) {
        $env:PSPOD_TEST_EnableConsoleLogs = 1
    }
    if ( [string]::IsNullOrEmpty($env:PSPOD_TEST_ShowPodInfo) ) {
        $env:PSPOD_TEST_ShowPodInfo = 1
    }
}

if ( $env:PSPOD_TEST_ShowDebugData ) {
    write-host "`nThe following environment variables were found:" -ForegroundColor Magenta
    Get-Item -Path Env:* | Sort-Object | Out-String
    write-host "`nThe following environment variables will be used:" -ForegroundColor Magenta
}

Get-Item -Path Env:\PSPOD_TEST_* |
    ForEach-Object {
        if ( $env:PSPOD_TEST_ShowDebugData ) { "... $($_.Name) = $($_.Value)" }
        $key   = $_.Name.Replace('PSPOD_TEST_','')
        $value = if    ( $_.Name -in $switchParams ) { $true }
                elseif ( $_.Name -in $arrayParams )  { $_.value -split ',' }
                else                                 { $_.value }
        $params.Add($key,$value)
    }

Start-Testing @params
