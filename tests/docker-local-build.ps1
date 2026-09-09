#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

    Clear-Host

  # Load the standard test initialization file.
    . $(Join-Path -Path $PSScriptRoot -ChildPath '_initialize-tests.ps1')

  # Start a docker container using the webserver preset and the local project folder.
    docker run -e "PSPOD_PRESET_Webserver=1" -p 80:80 seabopo/pspodtester:noble-v2.0.1

    Exit

    docker build -f ../docker/macos/dockerfile -t pspodtester:macos ../docker/macos

    docker run -e "PSPOD_PRESET_Webserver=1" -p 80:80 pspodtester:macos

