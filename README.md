# About psPodTester
psPodTester is a PowerShell 7 module to test container deployments.


## Features:
 - A web server for:
     - An ingress testing destination.
     - Viewing the HTTP Request headers of a GET request.
     - Echoing the HTTP Request properties of a GET or POST.
     - Viewing environment and debugging information.
     - Running network connectivity tests.
 - A message service to validate container logging.

  Note: the icons used by the web application are freely provided by 
 [IconScout](https://iconscout.com/) from their [Unicons](https://iconscout.com/unicons) collection.


## Presets

**PSPOD_PRESET_Webserver**

psPodTester has a web server preset to enable a basic web application test container. The preset is enabled
by setting the "PSPOD_PRESET_Webserver" environment variable to any value (it just needs to exist).
This is a switch. If this variable exists (no matter the value) the web server is enabled and overwrites the 
following environment variables with these values:
 - PSPOD_WEBS_EnableWebServer  = 1   :: Enables the web server using the default port (80).
 - PSPOD_WEBS_ShowPodInfo      = 1   :: Displays pod and host information.
 - PSPOD_WEBS_ShowEnvVariables = 1   :: Displays environment variables.
 - PSPOD_MSGS_SendMessages     = 1   :: Enables sending log messages if not already enabled.
 - PSPOD_MSGS_SendPeriod       = 300 :: Sets the log message sending rate to one message every 5 minutes.

Examples:
```
PowerShell:
    $env:PSPOD_PRESET_Webserver=1

Kubernetes/Docker
  env:
  - name: PSPOD_PRESET_Webserver
    value: "1"
```


## Parameters

The full parameter list can be viewed in the 
[/public/Start-Testing.ps1](https://github.com/seabopo/psPodTester/blob/master/public/Start-Testing.ps1) 
file, which is the module's main entrypoint.

**Note:** Parameter descriptions prefixed with 'Switch:' will be enabled if they exist in the environment. 
          The value does not matter.

**Web Server Options**
 - PSPOD_WEBS_EnableWebServer     = 1               :: Switch: Enables the web server.
 - PSPOD_WEBS_WebServerPort       = 80              :: The port the Web Server runs on. Defaults to port of 80.
 - PSPOD_WEBS_AppName             = PodTester       :: The app name / web page banner to set. Default = PodTester
 - PSPOD_WEBS_ShowPodInfo         = 1               :: Switch: Displays pod information. Pod information is defined
                                                       in environment variables that have a 'PSPOD_INFO_' prefix.
                                                       See the 'Information Options' section below for more details.
 - PSPOD_WEBS_ShowEnvVariables    = 1               :: Switch: Displays environment variables.
 - PSPOD_WEBS_IgnoreEnvVariables  = value,value     :: A comma-separated list of environment variable to ignore.
                                                       Use a specific environment variable name or use 
                                                       asterisks (*) to perform wild-card matching. The default
                                                       values are: '*SCRT*','*SECRET*','*PASS*','*KEY*','*TOKEN*'

**Message Service Options**
 - PSPOD_MSGS_SendMessages  = 1           :: Switch: Enables sending log messages every <SendPeriod> seconds.
 - PSPOD_MSGS_SendPeriod    = 300         :: How often to send the messages. 300 seconds is the default.
 - PSPOD_MSGS_MessagePrefix = 'PodTester' :: The prefix to append to the messages so that they can easily
                                             be found in the logging system. The default prefix is 'PodTester'.

**Information Options**
Any environment variables you create that use the 'PSPOD_INFO_' prefix will be displayed in the web server's 
debugging section if you enable the 'PSPOD_WEBS_ShowPodInfo' environment variable. Use these variables to capture
information about your deployments.  

Example:
```
env:
- name: PSPOD_WEBS_AppName
  value: "MyTestApp"
- name: PSPOD_PRESET_Webserver
  value: "1"
- name: PSPOD_WEBS_ShowPodInfo
  value: "1"
- name: PSPOD_INFO_NODE_IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: PSPOD_INFO_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: PSPOD_INFO_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: PSPOD_INFO_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: PSPOD_INFO_POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
```


## Examples

A variety of Windows and Docker usage examples are available in the 
[/tests/](https://github.com/seabopo/psPodTester/blob/v2.x/tests) folder.


## Docker Images

Docker images are available at 
[hub.docker.com/repository/docker/seabopo/pspodtester/](https://hub.docker.com/repository/docker/seabopo/pspodtester)

Docker images are built monthly using the following base images:
 - mcr.microsoft.com/dotnet/sdk:10.0-noble (Ubuntu 24.04 Noble)
 - mcr.microsoft.com/dotnet/sdk:10.0-azurelinux3.0
 - mcr.microsoft.com/dotnet/sdk:10.0-nanoserver-ltsc2025
 - mcr.microsoft.com/dotnet/sdk:10.0-nanoserver-ltsc2022
