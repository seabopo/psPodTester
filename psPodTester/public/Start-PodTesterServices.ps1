function Start-PodTesterServices {
    <#
    .DESCRIPTION
        Starts the core container services: WebServer, SendMessages.
    #>

    [CmdletBinding()]
    param ()

    process {

      try {

          if ( -not $PS.initialized ) {

            # Initialize the log files.
              $null | Out-File $($PS.path.msgLog)
              $null | Out-File $($PS.path.usrLog)
              $null | Out-File $($PS.path.dbgLog)
              $null | Out-File $($PS.path.appLog)

            # Write the application initialization message.
              Write-Info -p -m $($PS.usrmsg.app.init -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))

            # Write the container launch environment and PSPOD_INFO_* environment variables to the debug log.
              Write-ContainerInfo

            # Write the container environment variables to the debug log.
              Write-EnvironmentInfo

          }

        # Start the messaging service.
          if ( $PS.messages.enabled -and $PS.messages.pid -eq 0 ) {

              Write-Info -f a,m -p -ps -m $PS.usrmsg.msg.enabled
              $cmd = {
                  param( [string] $ModuleRootPath )
                  Import-Module $ModuleRootPath
                  Start-Messaging
              }
              $argList = "-command (Invoke-Command -ScriptBlock {$cmd} -ArgumentList $($PS.path.moduleRoot))"
              $PS.messages.pid = ( Start-Process -FilePath "pwsh" -ArgumentList $argList -PassThru ).id
              $env:PSPOD_MSGS_PID = $PS.messages.PID

          } elseif ( -not $PS.messages.enabled ) {
              Write-Info -f a,m -ps -ps -m $PS.usrmsg.msg.noenabled
          }

        # Let the message service start.
          Start-Sleep -Seconds 2

        # Start the web server LAST so it has access to all environment variables, including the PIDs of the
        # other services, so that it can manage them in it's process.
          if ( $PS.webServer.enabled -and $PS.webServer.pid -eq 0 ) {

              Write-Info -f a -p -ps -m $PS.usrmsg.web.enabled
              $cmd = {
                  param( [string] $ModuleRootPath )
                  Import-Module $ModuleRootPath
                  Start-WebServer
              }
              $argList = "-command (Invoke-Command -ScriptBlock {$cmd} -ArgumentList $($PS.path.moduleRoot))"

              if ( $PS.env.userCanRunWS ) {
                  $PS.webServer.PID = ( Start-Process -FilePath "pwsh" -ArgumentList $argList -PassThru ).id
                  $env:PSPOD_WEBS_PID = $PS.webServer.PID
              }
              elseif ( $isWindows -and $PS.env.userCanRunAs -and -not $PS.env.userCanRunWS ) {
                  Write-Info -f a -w -m $PS.usrmsg.web.elevate
                  $PS.webServer.PID = ( Start-Process -FilePath "pwsh" -Verb RunAs -ArgumentList $argList -PassThru ).id
                  $env:PSPOD_WEBS_PID = $PS.webServer.PID
              }
              else {
                  Write-Info -f a -e -m $PS.usrmsg.web.nostart
                  $env:PSPOD_WEBS_FailedToStart = 1
              }

          }

        # Let the webserver start.
          Start-Sleep -Seconds 2

          if ( -not $PS.initialized ) {

            # Set the initialized flag so nothing is re-initialized if services are managed from the web server.
              $PS.initialized = $true

              Write-Info -f a -p -ps -m $PS.usrmsg.app.complete

            # Pause the init process indefinitely so other processes don't fail.
              Wait-Event -1

          }

        }
        catch {
            Write-Info -f a -e -l -m $_.Exception.Message
            $_
            Start-Sleep -Seconds 10
        }

    }
}
