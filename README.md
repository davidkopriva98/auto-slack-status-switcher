# auto-slack-status-switcher
 
## Prerequisite

Create a .env file in the same directory as the ps1 file. Copy code snippet and replace placeholders with real data.

```bash
accessToken=<<tokenOfYourSlackApp>>
userID=<<yourUserId>>
commingToWorkStart=<<TimeframeWhenStatusUpdateOccursAutomatically>>
commingToWorkEnd=<<TimeframeWhenStatusUpdateOccurrsAutomatically>>
```

## Usage

Navigate to Windows Start-up folder. Press ```Win + R``` and type ```shell:startup```. Inside this folder create a new ```<<someFileName>>.cmd``` file.
```bash
powerShell -windowstyle hidden C:<<pathToFile>>\update-status.ps1 >> C:<<pathToDesiredLogsLocation>>\autorun.log
```
Restart the PC and observe the code in action.

## Contributing

No thank you.
