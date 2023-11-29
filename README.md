# auto-slack-status-switcher
 
## Prerequisite

Create a .env file in the same directory as the ps1 file. Copy code snippet and replace placeholders with real data.

```bash
ACCESS_TOKEN=<<tokenOfYourSlackApp>>
USER_ID=<<yourUserId>>
CHANGE_STATUS_BETWEEN_HOURS=5-14
WORK_WIFI=<<officeWiFiSSID>>
HOME_WIFI=<<homeWiFiSSID>>
```

Make sure that you have PowerShell 7 or greater installed.

## Usage

Navigate to Windows Start-up folder. Press ```Win + R``` and type ```shell:startup```. Inside this folder create a new ```<<someFileName>>.cmd``` file.
```bash
cd <<pathToDirectory>>
pwsh -WindowStyle Hidden .\run_on_startup.ps1 -logFilePath ".\python.log"
```
Restart the PC and observe the code in action.

## Contributing

No thank you.
