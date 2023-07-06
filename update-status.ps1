Add-Type -AssemblyName System.Windows.Forms

. .\update-status-utils.ps1

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

$currentTime = Get-Date -Format "dd/MM/yyyy HH:mm"
Write-Host "Current datetime: $currentTime"

$homeWifiName = "Error 404"


$officeWifiName1 = "Orange Black"
$officeWifiName2 = "House of Cards"

$wifiName = Get-WiFiName

Write-Host "Connected Wi-Fi Network: $wifiName"

$slackStatusUrl = "https://slack.com/api/users.profile.set"

$officeStatusText = "Office"
$officeStatusEmoji = ":office:"

$homeStatusText = "Working remotely"
$homeStatusEmoji = ":house_with_garden:"


if ($wifiName -eq $homeWifiName) {
    $newStatusText = $homeStatusText
    $newStatusEmoji = $homeStatusEmoji
} elseif ($wifiName -eq $officeWifiName1 -or $wifiName -eq $officeWifiName2) {
    $newStatusText = $officeStatusText
    $newStatusEmoji = $officeStatusEmoji
} else {
    Write-Host "Wi-Fi not recognised."
	Write-Host ('-'*20)
    return
}


$currentHour = (Get-Date).Hour
$isCurrentlyStatusSet = Get-Status

if ($currentHour -ge $commingToWorkStart -and $currentHour -lt $commingToWorkEnd -and -not $isCurrentlyStatusSet) {
    Update-Status
} else {

    if ($isCurrentlyStatusSet) {
        $buttonClicked = Read-MessageBoxDialog -Message "Slack status is already set. Do you wish to override this?" -WindowTitle "Update Slack status?" -Buttons YesNo -Icon Exclamation
    } else {
        $buttonClicked = Read-MessageBoxDialog -Message "Do you want to update Slack status? Current time is outside of comming to work hours." -WindowTitle "Update Slack status?" -Buttons YesNo -Icon Exclamation        
    }

    if ($buttonClicked -eq "Yes") { 
        Update-Status
		Write-Host ('-'*20)
    }
    else { 
        Write-Host 'Action canceled, bye.'
		Write-Host ('-'*20)
    }
}