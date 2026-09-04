#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

    Clear-Host

  # Load the standard test initialization file.
    . $(Join-Path -Path $PSScriptRoot -ChildPath '_initialize-tests.ps1')

  # Start a docker container using the webserver preset and the local project folder.
    docker run --mount type=bind,source=/Users/sean/Repos/@psModules/psPodTester/psPodTester,target=/psPodTester `
                -e "PSPOD_WEBS_AppName=psPodTester Docker" `
                -e "PSPOD_PRESET_Webserver=1" `
                -it `
                -p 80:80 `
                mcr.microsoft.com/dotnet/sdk:10.0-noble `
                pwsh -ExecutionPolicy Bypass -command "/psPodTester/docker.ps1"


exit

docker run -it mcr.microsoft.com/dotnet/sdk:10.0-noble uname -m

docker run -it mcr.microsoft.com/dotnet/sdk:10.0-noble uname -m

docker image inspect mcr.microsoft.com/dotnet/sdk:10.0-noble --format '{{.Architecture}}'