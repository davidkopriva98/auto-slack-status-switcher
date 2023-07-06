Function Read-MessageBoxDialog([string]$Message, [string]$WindowTitle, [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None)
{
    return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon)
}


Function Update-Status {
    Write-Host "Updating Slack status"


    $dateTime = Get-Date
    $localTimeZone = Get-TimeZone

    $endOfDay=[DateTime]::Today.AddDays(1).AddSeconds(-1).AddSeconds($localTimeZone.GetUtcOffset($dateTime).TotalSeconds * -1)
    $endOfDayEpoch = Get-Date $endOfDay -UFormat %s


    $payload = @{
        "profile" = @{
            "status_text" = $newStatusText
            "status_emoji" = $newStatusEmoji
            "status_expiration" = $endOfDayEpoch
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

Function Get-Status {
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

Function Get-WiFiName {

    $retryCount = 0


    while ($retryCount -le 5) {

        $wifiName = (Get-NetConnectionProfile).Name
        if ($wifiName -ne "") {
            return $wifiName
        }

        $retryCount++
        Start-Sleep -Seconds 5

    }

}