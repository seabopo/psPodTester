function Set-EnvironmentPresets {
    <#
    .DESCRIPTION
        Updates the environment variables based on any presets.
    #>

    [CmdletBinding()]
    param ( )

    $presetsUsed = @{
        'webServer' = $env:PSPOD_PRESET_Webserver ? $true : $false
    }

    if ( $presetsUsed.webServer ) {
        $env:PSPOD_WEBS_PresetUsed       = 1
        $env:PSPOD_WEBS_EnableWebServer  = 1
        $env:PSPOD_WEBS_ShowPodInfo      = 1
        $env:PSPOD_WEBS_ShowEnvVariables = 1
        $env:PSPOD_MSGS_SendMessages     = 1
        $env:PSPOD_MSGS_SendPeriod       = 300
    }

    Remove-Item -Path Env:\PSPOD_PRESET_*

}
