function Read-MessageBoxDialog([string]$Message, [string]$WindowTitle, [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None)
{
    return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon)
}


function UpdateStatus {
    $payload = @{
        "profile" = @{
            "status_text" = $newStatusText
            "status_emoji" = $newStatusEmoji
        }
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $slackStatusUrl -Method POST -Headers @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    } -Body $payload
   
    if ($response.ok) {
        Write-Host "Slack status updated successfully."
    } else {
        Write-Host "Failed to update Slack status. Error: $($response.error)"
    }
}

$envFilePath = Join-Path -Path $PSScriptRoot -ChildPath ".env"
$envVariables = Get-Content $envFilePath

foreach ($envVariable in $envVariables) {
    if ($envVariable -match '^([^=]+)=(.*)$') {
        $variableName = $Matches[1]
        $variableValue = $Matches[2]

        # Assign the variable value to the corresponding variable name
        Set-Variable -Name $variableName -Value $variableValue
    }
}


$homeWifiName = "Error 404"


$officeWifiName1 = "Orange Black"
$officeWifiName2 = "House of Cards"

$wifiName = (Get-NetConnectionProfile).Name

Write-Host "Connected Wi-Fi Network: $wifiName"

$slackStatusUrl = "https://slack.com/api/users.profile.set"

$officeStatusText = "Office"
$officeStatusEmoji = ":office:"

$homeStatusText = "Working remotely"
$homeStatusEmoji = ":home:"


if ($wifiName -eq $homeWifiName) {
    $newStatusText = $homeStatusText
    $newStatusEmoji = $homeStatusEmoji
} elseif ($wifiName -eq $officeWifiName1 -or $wifiName -eq $officeWifiName2) {
    $newStatusText = $officeStatusText
    $newStatusEmoji = $officeStatusEmoji
} else {
    Write-Host "Wi-Fi not recognised."
    return
}


$currentHour = (Get-Date).Hour

if ($currentHour -ge 5 -and $currentHour -lt 8) {
    UpdateStatus
} else {
    $buttonClicked = Read-MessageBoxDialog -Message "Do you want to update Slack status?" -WindowTitle "Update Slack status?" -Buttons YesNo -Icon Exclamation
    if ($buttonClicked -eq "Yes") { 
        UpdateStatus
    }
    else { 
        Write-Host 'Ok, bye.'
    }
}