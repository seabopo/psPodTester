# psPodTester
A PowerShell module to test Windows AKS pods. 

Features:
 - Configurable CPU and memory stressing.
 - A web server for:
     - Ingress testing.
     - Viewing the test logs.
     - Viewing user requests.
     - Running a few pre-canned tests, including breaking the pod.
 - Environment variables debug/dump.

The full parameter list can be viewed in the 
[/public/Start-Testing.ps1](https://github.com/seabopo/psPodTester/blob/master/public/Start-Testing.ps1) 
file, which is the module's main entrypoint.

A variety of Windows and Docker usage examples are available in the 
[/psPodTester-tests.ps1](https://github.com/seabopo/psPodTester/blob/master/psPodTester-tests.ps1) file.

A Windows Nano Server image of this module is available here: 
[seabopo/pspodtester](https://hub.docker.com/repository/docker/seabopo/pspodtester/general)](https://hub.docker.com/r/seabopo/pspodtester)
