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
     - Viewing environment and debugging information.
     - Breaking the container.
 
The full parameter list can be viewed in the 
[/public/Start-Testing.ps1](https://github.com/seabopo/psPodTester/blob/master/public/Start-Testing.ps1) 
file, which is the module's main entrypoint.

A variety of Windows and Docker usage examples are available in the 
[/psPodTester-tests.ps1](https://github.com/seabopo/psPodTester/blob/master/psPodTester-tests.ps1) file.

A Windows Nano Server image of this module is available here: 
[seabopo/pspodtester](https://hub.docker.com/r/seabopo/pspodtester)

The following docker command runs the web server:
```
docker run -e "PSPOD_PRESET_Webserver=1" -p 80:80 seabopo/pspodtester:latest
```

This is a sample AKS deployment of the webserver:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apptester
  namespace: apptester
  labels:
    app: apptester
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apptester
  template:
    metadata:
      labels:
        app: apptester
    spec:
      nodeSelector:
        kubernetes.io/os: windows
      containers:
      - name: apptester
        image: seabopo/pspodtester:latest
        resources:
          requests:
            memory: "256Mi"
            cpu: "400m"
          limits:
            memory: "384Mi"
            cpu: "500m"
        imagePullPolicy: Always
        env:
        - name: PSPOD_APP_NAME
          value: "AppTester-CD"
        - name: PSPOD_PRESET_Webserver
          value: "1"
        - name: PSPOD_TEST_MessagePrefix
          value: "AppTester-CD"
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
