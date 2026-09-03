#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

    Clear-Host

  # Clear all existing PSPOD environment variables.
    Remove-Item -Path Env:\PSPOD_*

  # Enable the WebServer preset.
    $env:PSPOD_WEBS_AppName      = 'psPodTester - Webserver Preset'

  # Define the App / Banner Name
    $env:PSPOD_PRESET_Webserver  = 1

  # Enable Admin/Testing mode
    $env:PSPOD_WEBS_AdminEnabled = 1
    $env:PSPOD_WEBS_AdminSubnets = '127.0.0.1/32'

  # Load the standard test initialization file.
    . $(Join-Path -Path $PSScriptRoot -ChildPath '_initialize-tests.ps1')

  # Start the webserver as a local powershell process
    Start-WebServer
