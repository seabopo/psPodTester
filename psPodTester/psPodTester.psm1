#==================================================================================================================
#==================================================================================================================
# psPodTester - Basic Pod Testing Module
#==================================================================================================================
#==================================================================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Stop"

Set-Variable -Scope 'Local' -Name 'MODULE_NAME' -Value $($PSScriptRoot | Split-Path -Leaf)
Set-Variable -Scope 'Local' -Name 'MODULE_ROOT' -Value $PSScriptRoot

Set-Variable -Scope 'Local' -Name 'WS_ENABLED'       -Value $false
Set-Variable -Scope 'Local' -Name 'WS_APP_LOG_PATH'  -Value $( '{0}/http/app.log'     -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'WS_USR_LOG_PATH'  -Value $( '{0}/http/usr.log'     -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'WS_MSG_LOG_PATH'  -Value $( '{0}/http/msg.log'     -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'WS_HEADER_PATH'   -Value $( '{0}/http/header.html' -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'WS_FOOTER_PATH'   -Value $( '{0}/http/footer.html' -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'WS_START_PATH'    -Value $( '{0}/webserver.ps1'    -f $PSScriptRoot )
Set-Variable -Scope 'Local' -Name 'DOCKER_PATH'      -Value $( '{0}/docker.ps1'       -f $PSScriptRoot )

# Load all of the private functions.
  Get-ChildItem -Path "$MODULE_ROOT/Private/*.ps1" -Recurse | ForEach-Object { . $($_.FullName) }

# Load and export all of the public functions and their aliases.
  Get-ChildItem -Path "$MODULE_ROOT/Public/*.ps1" -Recurse |
      ForEach-Object {
          . $($_.FullName)
          $function = $_.BaseName
          $aliases  = Get-Alias | Where-Object { $_.Source -eq $MODULE_NAME } |
                          Where-Object { $_.ReferencedCommand.Name -eq $function } |
                              Select-Object -ExpandProperty 'name'
          Export-ModuleMember -Function ($function)
          if ( $aliases ) { Export-ModuleMember -Alias $aliases }
      }

# Set the container environment variables.
  Set-Variable -Scope 'Local' -Name 'ENV_ISCONTAINER'  -Value $( Test-IsContainer )
  Set-Variable -Scope 'Local' -Name 'ENV_USERISADMIN'  -Value $( Test-UserIsAdmin )
  Set-Variable -Scope 'Local' -Name 'ENV_ISNANOSERVER' -Value $( Test-IsNanoServer )

# Set the user messages.
  Set-Variable -Scope 'Local' -Name 'USER_MESSAGES'   -Value $(
    @{
        init       = "Process started at: {0}"
        start      = "Starting ..."
        env        = "The following environment variables were found:"
        envupdated = "The following environment variables were found after applying environment profiles:"
        wspreset   = "The Webserver preset was found. Enabling settings ..."
        startingws = "Starting web server ..."
        wselevate  = "... User does not have admin rights. Attempting to elevate ..."
        startedws  = "... Web server started on port {0}."
        nostartws  = "... CANNOT START WEB SERVER. User does not have admin rights."
        container  = "... Running in Container: {0}"
        adminuser  = "... User is Admin: {0}"
        noexit     = "The NoExit switch was detected.`r`nThis process will now wait indefinitely."
        exit       = "The process is now exiting ..."
        nostress   = "The NoStress switch was detected.`r`nAll stress intervals will be skipped."
        podinfo    = "POD Information"
        startmsgs  = "The SendMessages switch was detected.`nLogging test messages with prefix '{0}' every 15 seconds ..."
  }

)
