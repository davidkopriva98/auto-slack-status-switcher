param (
    [string]$logFilePath
)

if (-not (Test-Path $logFilePath)) {
    Write-Host "Error: Log file not found at $logFilePath"
    exit
}

# Clear the contents of the log file
Clear-Content -Path $logFilePath

python -i .\update-status.py

exit
