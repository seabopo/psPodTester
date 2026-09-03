#==================================================================================================================
#==================================================================================================================
# psPodTester - Tests
#==================================================================================================================
#==================================================================================================================

    Clear-Host

  # Clear all existing PSPOD environment variables.
    Remove-Item -Path Env:\PSPOD_*

  # Enable the WebServer preset.
    $env:PSPOD_WEBS_AppName = 'psPodTester - Webserver Preset'

  # Define the App / Banner Name
    $env:PSPOD_PRESET_Webserver = 1

  # Enable Admin/Testing mode
    $env:PSPOD_WEBS_AdminEnabled = 1
    $env:PSPOD_WEBS_AdminSubnets = '127.0.0.1/32'

  # Load the standard test initialization file.
    . $(Join-Path -Path $PSScriptRoot -ChildPath '_initialize-tests.ps1')

  # Start the webserver as a local powershell process
    Start-WebServer

    Exit

  # Run a GET command in a separate PWSH prompt.
    Clear-Host
    curl -v http://localhost/echo `
        -H "Content-Type: application/json" `
        -H "Accept: application/json, text/event-stream" `
        -H "mcp-protocol-version: 2025-11-25"

  # Run a POST command in a separate PWSH prompt.
    Clear-Host
    curl -v http://localhost/echo `
        -H "Content-Type: application/json" `
        -H "Accept: application/json, text/event-stream" `
        -H "mcp-protocol-version: 2025-11-25" `
        -d '{
          "jsonrpc": "2.0",
          "id": 1,
          "method": "initialize",
          "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {
              "tools": {},
              "resources": {},
              "prompts": {}
            },
            "clientInfo": {
              "name": "curl-client",
              "version": "1.0.0"
            }
          }
        }'
    
