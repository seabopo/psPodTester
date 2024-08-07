#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

Clear-Host

$scriptRootPath = $(Split-Path $MyInvocation.MyCommand.Path)
$repoRootPath   = $((Get-Item $scriptRootPath).Parent.FullName)
$repoName       = $($repoRootPath | Split-Path -Leaf)
$modulePath     = Join-Path -Path $repoRootPath -ChildPath $repoName

Set-Location  -Path $scriptRootPath
Push-Location -Path $scriptRootPath

Import-Module $modulePath -Force

Remove-Item -Path Env:\PSPOD_*

$null | Out-File $( '{0}/http/app.log' -f $modulePath )
$null | Out-File $( '{0}/http/usr.log' -f $modulePath )
$null | Out-File $( '{0}/http/msg.log' -f $modulePath )

$Test = @{

    # WebServerPreset  = $true
    # WebServer           = $true
    # WebServerDirect     = $true

    # DefaultStress       = $true

    # DockerCodeWSprofile = $true
    # DockerCodeCustom    = $true

    DockerContainer  = $true

    # DumpDebugData       = $true
    # AutomaticThreads    = $true
    # ManualThreads       = $true
    # RandomThreads       = $true
    # CPU                 = $true
    # Memory              = $true
    # None                = $true

}

# Clean-up Jobs if you manually abort
#   get-job | stop-job
#   get-job | Remove-Job

# Requies this this session to be running as admin ...
if ( $Test.WebServerDirect )  { $env:PSPOD_APP_NAME = 'psPodTester'; Start-Webserver -c }

if ( $Test.WebServerPreset ) {
    $env:PSPOD_PRESET_Webserver = 1
    Start-psPodTesterServices
}

if ( $Test.WebServer ) {
  $env:PSPOD_TEST_EnableWebServer     = 1
  $env:PSPOD_TEST_WebServerPort       = 8080
  $env:PSPOD_TEST_EnableConsoleLogs   = 1
  $env:PSPOD_TEST_ShowDebugData       = 1
  $env:PSPOD_TEST_ShowPodInfo         = 1
  $env:PSPOD_TEST_SendMessages        = 1
  $env:PSPOD_TEST_MessagePrefix       = 'UniqueMessagePrefix'
  $env:PSPOD_TEST_NoStress            = 1
  $env:PSPOD_TEST_NoExit              = 1
  $env:PSPOD_INFO_PodName             = 'Podname'
  $env:PSPOD_INFO_ServerName          = 'ServerName'
  Start-psPodTesterServices
}


if ( $Test.DefaultStress ) {
  $env:PSPOD_TEST_EnableWebServer     = 1
  $env:PSPOD_TEST_WebServerPort       = 8080
  $env:PSPOD_TEST_EnableConsoleLogs   = 1
  $env:PSPOD_TEST_ShowDebugData       = 1
  $env:PSPOD_TEST_ShowPodInfo         = 1
  $env:PSPOD_TEST_SendMessages        = 1
  $env:PSPOD_TEST_MessagePrefix       = 'UniqueMessagePrefix'
  $env:PSPOD_INFO_PodName             = 'Podname'
  $env:PSPOD_INFO_ServerName          = 'ServerName'
  Start-psPodTesterServices
}


if ( $Test.DockerCodeWSprofile )
{
    Remove-Item -Path Env:\PSPOD_TEST_*

    $env:PSPOD_PRESET_Webserver         = 1
    $env:PSPOD_TEST_CpuThreads          = 3

    ..\pspodtester\docker.ps1

}

if ( $Test.DockerCodeCustom )
{
    Remove-Item -Path Env:\PSPOD_TEST_*

    $env:PSPOD_TEST_StressDuration      = 33
    $env:PSPOD_TEST_WarmUpInterval      = 3
    $env:PSPOD_TEST_CoolDownInterval    = 3
    $env:PSPOD_TEST_StressInterval      = 3
    $env:PSPOD_TEST_RestInterval        = 3
    $env:PSPOD_TEST_RandomizeIntervals  = "s,r"
    $env:PSPOD_TEST_MaxIntervalDuration = 33
    $env:PSPOD_TEST_CpuThreads          = 3
    $env:PSPOD_TEST_MemThreads          = 3
    $env:PSPOD_TEST_NoExit              = 1
    #$env:PSPOD_TEST_NoCPU               = 1
    $env:PSPOD_TEST_NoMemory            = 1
    #$env:PSPOD_TEST_NoStress            = 1
    $env:PSPOD_TEST_WebServerPort       = 8080
    $env:PSPOD_TEST_EnableWebServer     = 1
    $env:PSPOD_TEST_EnableConsoleLogs   = 1
    $env:PSPOD_TEST_ShowDebugData       = 1
    $env:PSPOD_TEST_ShowPodInfo         = 1
    $env:PSPOD_INFO_PodName             = 'Podname'
    $env:PSPOD_INFO_ServerName          = 'ServerName'
    $env:PSPOD_TEST_SendMessages        = 1
    $env:PSPOD_TEST_MessagePrefix       = 'UniqueMessagePrefix'

    .\pspodtester\docker.ps1

}


if ( $Test.DumpDebugData )    { Start-Testing -ns -dd -pi }

if ( $Test.AutomaticThreads ) { Start-Testing -sd 3 -wi 1 -ci 0 -si 1 -ri 1 -ws }

if ( $Test.ManualThreads )    { Start-Testing -sd 4 -wi 1 -ci 1 -si 1 -ri 1 -ct 3 -mt 3 }

if ( $Test.RandomThreads )    { Start-Testing -sd 5 -wi 0 -ci 0 -si 2 -ri 2 -rz d,w -md 10 }

if ( $Test.CPU )              { Start-Testing -sd 2 -wi 0 -ci 0 -si 1 -ri 1 -NoMemory }

if ( $Test.Memory )           { Start-Testing -sd 2 -wi 0 -ci 0 -si 1 -ri 1 -NoCPU }

if ( $Test.None )             { Start-Testing -sd 5 -wi 0 -ci 0 -si 2 -ri 2 -NoCPU -NoMemory }



# NOTES:
#  - Windows Versions:
#    - The Windows 10 and Windows Server 2019 OS require the 'lts-nanoserver-1809' image.
#    - The Windows 11 and Windows Server 2022 OS require the 'lts-nanoserver-ltsc2022' image.
#  - If the NoExit switch is not used the containers will exit when the stress intervals
#    have completed. If the container is run as a K8s service the scheduler will restart the
#    pod, and the tests. Use the NoExit parameter to avoid this. Alternatively, use this to
#    test pod restarts and alerting. You can also use the cooldown period to delay the pod
#    from exiting.
#  - Running the webserver requires that the user context is ContainerAdministrator. You'll
#    get an authorization error otherwise and the webserver will not start.
#  - Running the tests from the web server UI instead of specifying testes in the docker file
#    will stress only the individual pod - there is no communication to other pods, so any
#    additional pods that are spun up based on pod autoscaling will produce no load.
#  - To stress pod autoscaling run tests at pod launch. This will max out your
#    autoscaling counts. Make sure to allow rest intervals that will allow all pods to
#    scale down via the autoscaler before the stress cycle starts again.
#
# UPDATE "SOURCE=C:\Repos\Github\psPodTester\psPodTester" to your own repo path for testing.
#
if ( $Test.DockerContainer )
{

    # Test Webserver Preset.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_PRESET_Webserver=1" `
                -e "PSPOD_TEST_CpuThreads=2" `
                -it --user ContainerAdministrator `
                -p 80:80 `
     mcr.microsoft.com/powershell:lts-nanoserver-1809 `
     cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  exit

  # Open an interactive container that uses the PowerShell Nano Server base image.
    docker run -it --user ContainerAdministrator mcr.microsoft.com/powershell:lts-nanoserver-1809 cmd /c pwsh -ExecutionPolicy Bypass

  # Open an interactive container that uses the PowerShell Nano Server base image.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -it --user ContainerAdministrator `
                --memory=384m --cpus=2 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass

  # Open an interactive container and run a test file.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -it --user ContainerAdministrator `
                --memory=512m --cpus=2 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -file "/psPodTester/test.ps1"

  # DEBUG
  # Dumps the container's environment and application variables and waits for the container to be killed.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_NoStress=1" `
                -e "PSPOD_TEST_ShowDebugData=1" `
                -e "PSPOD_TEST_ShowPodInfo=1" `
                -it `
                -p 8080:8080 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  # WEBSERVER ONLY - SINGLE POD TESTS
  # Run the web server and skip all tests. A few basic tests can be run from the web
  # server, but these only stress the single container you are connected to. This will
  # allow you to test a singe container/pod for logging, monitoring, alterting. Stressing
  # this pod will cause the K8s HPA to run a new instance, but the second instance will
  # not generate any load.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_APP_NAME=psPodTester" `
                -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_SendMessages=1" `
                -e "PSPOD_TEST_MessagePrefix=UniqueMessagePrefix" `
                -e "PSPOD_TEST_EnableConsoleLogs=1" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_NoStress=1" `
                -e "PSPOD_TEST_ShowDebugData=1" `
                -e "PSPOD_TEST_ShowPodInfo=1" `
                -e "PSPOD_TEST_CpuThreads=2" `
                -e "PSPOD_TEST_MemThreads=2" `
                -e "PSPOD_INFO_PodName=TestPod" `
                -e "PSPOD_INFO_ServerName=TestServer" `
                -it --user ContainerAdministrator `
                -p 8080:8080 `
                --memory=512m --cpus=2 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  # AUTOMATED STRESSING
  # Runs a stress session with the default values and exits. The default settings do
  # not enable the webserver, which requires the --user ContainerAdministrator switch.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -it `
                -p 8080:8080 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  # AUTOMATED STRESSING - CPU Only
  # Runs a stress session with the default values, but skips memory stressing, and exits.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_TEST_NoMemory=1" `
                -it `
                -p 8080:8080 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  # AUTOMATED STRESSING - Memory Only
  # Runs a stress session with the default values, but skips memory stressing, and exits.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_TEST_NoCPU=1" `
                -it `
                -p 8080:8080 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

   # MANUAL STRESSING
   # Runs a test with manually specified values. The stress values listed below are the defaults.
   # Setting CPU/Memory threads to zero automatically calculates them based on environment.
   # The web server is enabled, which requires --user ContainerAdministrator.
   # The NoExit switch is enabled so the container will not exit and will run indefinitely.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_TEST_StressDuration=10" `
                -e "PSPOD_TEST_WarmUpInterval=1" `
                -e "PSPOD_TEST_CoolDownInterval=0" `
                -e "PSPOD_TEST_StressInterval=5" `
                -e "PSPOD_TEST_RestInterval=5" `
                -e "PSPOD_TEST_CpuThreads=0" `
                -e "PSPOD_TEST_MemThreads=0" `
                -e "PSPOD_TEST_MaxIntervalDuration=1440" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_WebServerPort=8080" `
                -it --user ContainerAdministrator `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"

  # RANDOMIZED STRESSING
  # Runs a 4-hour test with randomized stress and rest cycles. The stress and rest
  # cycle intervals will range from 5 minutes (StressInterval/RestInterval) to
  # 60 minutes (MaxIntervalDuration).
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_TEST_StressDuration=240" `
                -e "PSPOD_TEST_WarmUpInterval=1" `
                -e "PSPOD_TEST_CoolDownInterval=0" `
                -e "PSPOD_TEST_StressInterval=5" `
                -e "PSPOD_TEST_RestInterval=5" `
                -e "PSPOD_TEST_RandomizeIntervals=s,r" `
                -e "PSPOD_TEST_CpuThreads=1" `
                -e "PSPOD_TEST_MemThreads=1" `
                -e "PSPOD_TEST_MaxIntervalDuration=60" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_WebServerPort=80" `
                -it --user ContainerAdministrator `
                -p 80:80 `
                mcr.microsoft.com/powershell:lts-nanoserver-1809 `
                cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"




  # Test Webserver Preset.
    docker run  --mount type=bind,source=C:\Repos\Github\psPodTester\psPodTester,target=C:\psPodTester `
                -e "PSPOD_PRESET_Webserver=1" `
                -e "PSPOD_TEST_CpuThreads=2" `
                -e "PSPOD_TEST_ShowDebugData=1" `
                -e "PSPOD_TEST_ShowPodInfo=1" `
                -it --user ContainerAdministrator `
                -p 80:80 `
     mcr.microsoft.com/powershell:lts-nanoserver-1809 `
     cmd /c pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"




  # Test dockerhub images.
    docker run -e "PSPOD_PRESET_Webserver=1" -p 80:80 seabopo/pspodtester:latest

    docker run `
                -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_NoStress=1" `
                -p 8080:8080 `
                seabopo/pspodtester:latest

    docker run `
                -e "PSPOD_TEST_ShowDebugData=1" `
                -e "PSPOD_TEST_StressDuration=10" `
                -e "PSPOD_TEST_WarmUpInterval=1" `
                -e "PSPOD_TEST_CoolDownInterval=1" `
                -e "PSPOD_TEST_StressInterval=1" `
                -e "PSPOD_TEST_RestInterval=1" `
                -e "PSPOD_TEST_RandomizeIntervals=s,r" `
                -e "PSPOD_TEST_MaxIntervalDuration=5" `
                -e "PSPOD_TEST_CpuThreads=1" `
                -e "PSPOD_TEST_MemThreads=1" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_WebServerPort=8080" `
                -e "PSPOD_TEST_EnableConsoleLogs=1" `
                -p 8080:8080 `
                seabopo/pspodtester:latest

    docker run  -e "PSPOD_TEST_EnableWebServer=1" `
                -e "PSPOD_TEST_WebServerPort=8080" `
                -e "PSPOD_TEST_SendMessages=1" `
                -e "PSPOD_TEST_MessagePrefix=UniqueMessagePrefix" `
                -e "PSPOD_TEST_EnableConsoleLogs=1" `
                -e "PSPOD_TEST_NoExit=1" `
                -e "PSPOD_TEST_ShowDebugData=1" `
                -e "PSPOD_TEST_StressDuration=10" `
                -e "PSPOD_TEST_WarmUpInterval=1" `
                -e "PSPOD_TEST_CoolDownInterval=1" `
                -e "PSPOD_TEST_StressInterval=1" `
                -e "PSPOD_TEST_RestInterval=1" `
                -e "PSPOD_TEST_MaxIntervalDuration=5" `
                -e "PSPOD_TEST_RandomizeIntervals=s,r" `
                -e "PSPOD_TEST_CpuThreads=1" `
                -e "PSPOD_TEST_MemThreads=1" `
                -e "PSPOD_TEST_NoMemory=1" `
                -p 8080:8080 `
                seabopo/pspodtester:latest

}
