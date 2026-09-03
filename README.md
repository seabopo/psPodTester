# About psPodTester
psPodTester is a PowerShell 7 module to test container deployments.


## Features:
 - A web server for:
     - An ingress testing destination.
     - Viewing the HTTP Request headers of a GET request.
     - Viewing the HTTP Request headers and body of a POST request.
     - Viewing environment and debugging information.
     - Running network connectivity tests.
     - Running pre-defined CPU or memory stress tests.
     - Breaking the container (killing services or breaking healthz responses).
 - A message service to validate container logging.
 - Custom CPU and Memory stress tests (without the web server).


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
 - PSPOD_WEBS_AdminEnabled        = 1               :: Enables stress, connectivity and failure tests.
 - PSPOD_WEBS_AdminIpAddresses    = '127.0.0.1/32'  :: A comma-separated list of IP addresses or CIDRs that are
                                                       allowed to use the admin/testing functions.
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

**Stress Testing Options**
 - PSPOD_TEST_EnableTesting             :: Switch. Enables running the defined stress test when the pod starts.
                                           This does not need to be enabled to run the pre-defined stress tests
                                           presented in the web server.
 - PSPOD_TEST_NoExit                    :: Switch. Prevents the container from exiting after the stress tests 
                                           complete or the web server process exits. If a stress test is the 
                                           only service that was run the container will exit, the scheduler will restart the container and the tests will repeat. If the message 
                                           service or web server are also run they will prevent the container from exiting/restarting after the tests.

 - PSPOD_TEST_NoCPU               = 1   :: Switch: Do not run CPU tests.
 - PSPOD_TEST_NoMemory            = 1   :: Switch: Do not run Memory tests.
 - PSPOD_TEST_CpuThreads          = 1   :: The number of CPU threads to use for the stress test. Default = 1
 - PSPOD_TEST_MemThreads          = 1   :: The number of memory threads to use for the stress test. Default = 1

 - PSPOD_TEST_StressDuration      = 10  :: The total time, in minutes, that the test should run. Default = 10.
                                           Stress test are run in a repeated stress/rest cycle for this many minutes.
                                           A test with a StressInterval of 2 and a RestInterval of 2 would do the
                                           following: stress 2m, rest 2m, stress 2m, rest 2m, stress 2m, exit.
 - PSPOD_TEST_StressInterval      = 5   :: The period of time, in minutes, to run stress processes. Default = 5.
 - PSPOD_TEST_RestInterval        = 5   :: The period of time, in minutes, to run no stress processes. Default = 5.
 - PSPOD_TEST_WarmUpInterval      = 1   :: The time to wait, in minutes, before starting the tests after the pod 
                                           starts. The default is 1.
 - PSPOD_TEST_CoolDownInterval    = 0   :: The time to wait, in minutes, before exiting the stopping the testing
                                           service after the tests are complete. The default is 0.
 - PSPOD_TEST_RandomizeIntervals  = s,r :: Generate random interval times, in minutes. 's' indicates random stress
                                           times. 'r' indicates random rest times. 's,r' randomizes both.
 - PSPOD_TEST_MaxIntervalDuration = 30  :: Determines the maximum interval time, in minutes, that the random 
                                           interval generator should use. Default = 30.

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
- name: PSPOD_TEST_ShowPodInfo
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
