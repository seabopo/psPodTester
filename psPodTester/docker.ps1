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

Set-Location  -Path $PSScriptRoot
Push-Location -Path $PSScriptRoot

Import-Module $(Split-Path $Script:MyInvocation.MyCommand.Path) -Force

Start-psPodTesterServices
