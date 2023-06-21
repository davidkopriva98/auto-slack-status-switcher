Add-Type -AssemblyName System.Windows.Forms


function Read-MessageBoxDialog([string]$Message, [string]$WindowTitle, [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None)
{
    return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon)
}


function UpdateStatus {
    Write-Host "Updating Slack status"
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

function GetStatus {
    Write-Host "Getting slack status for user: $userID"

    $apiUrl = "https://slack.com/api/users.profile.get?user=$userID"
    $response = Invoke-RestMethod -Uri $apiUrl -Headers @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    if ($response.ok) {
        $statusEmoji = $response.profile.status_emoji
        $statusMessage = $response.profile.status_text
        #Write-Host "Status emoji: $statusEmoji and status message: $statusMessage"

        return ![string]::IsNullOrEmpty($statusMessage) -or ![string]::IsNullOrEmpty($statusEmoji)
    }
    else {
        Write-Host "Error: $($response.error)"
        return true
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
$isCurrentlyStatusSet = GetStatus

if ($currentHour -ge $commingToWorkStart -and $currentHour -lt $commingToWorkEnd -and -not $isCurrentlyStatusSet) {
    UpdateStatus
} else {

    if ($isCurrentlyStatusSet) {
        $buttonClicked = Read-MessageBoxDialog -Message "Slack status is already set. Do you wish to override this?" -WindowTitle "Update Slack status?" -Buttons YesNo -Icon Exclamation
    } else {
        $buttonClicked = Read-MessageBoxDialog -Message "Do you want to update Slack status? Current time is outside of comming to work hours." -WindowTitle "Update Slack status?" -Buttons YesNo -Icon Exclamation        
    }

    if ($buttonClicked -eq "Yes") { 
        UpdateStatus
    }
    else { 
        Write-Host 'Ok, bye.'
    }
}