# psPodTester
A PowerShell module to test Windows container deployments. 

Features:
 - Configurable CPU and memory stressing.
 - Environment variables debug/dump.
 - A web server for:
     - Running a few pre-canned stress tests.
     - Ingress testing.
     - Viewing the test progress / logs.
     - Viewing user requests.
     - Viewing the HTTP headers of a user request.
 
The full parameter list can be viewed in the 
[/public/Start-Testing.ps1](https://github.com/seabopo/psPodTester/blob/master/public/Start-Testing.ps1) 
file, which is the module's main entrypoint.

A variety of Windows and Docker usage examples are available in the 
[/psPodTester-tests.ps1](https://github.com/seabopo/psPodTester/blob/master/psPodTester-tests.ps1) file.

A Windows Nano Server image of this module is available here: 
[seabopo/pspodtester](https://hub.docker.com/r/seabopo/pspodtester)
