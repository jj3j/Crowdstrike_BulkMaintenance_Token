# Set API endpoint URL

$TokenEndpoint = "https://api.crowdstrike.com/oauth2/token"

# Set request headers
$headers = @{
    "accept" = "application/json"
    "Content-Type" = "application/x-www-form-urlencoded"
}

# Set request parameters with API ID & Secrets
$requestParams = @{
    "client_id" = "FALCON_API_ID"
    "client_secret" = "FALCON_API_SECRET"
}

# Send API request
$AT = Invoke-RestMethod -Method POST -Uri $TokenEndpoint -Headers $headers -Body $requestParams
$MTEndpoint = "https://api.crowdstrike.com/policy/combined/reveal-uninstall-token/v1"
$MTHeaders = @{
    "accept" = "application/json"
    "Content-Type" = "application/json"
    "authorization" = "$($AT.token_type) $($AT.access_token)"
    }

#Input the AID CSV path
Import-Csv "\\Path\to\destination\AID.csv" | ForEach-Object {
$MTBody = @{
    "audit_message" = "STATE REASON FOR REMOVAL"
    "device_id" = $_.token
    }

    $MTBody = $MTBody | ConvertTo-Json
    $MT = Invoke-RestMethod -Method POST -Uri $MTEndpoint -Headers $MTHeaders -Body $MTBody | ConvertTo-Json

    #Change the path
    Write-Output $MT | ForEach-Object { $_ | Out-String | Out-File -FilePath "\\Path\to\destination\output.txt" -Encoding ASCII -Append }
    Get-Content -Path "\\Path\to\destination\output.txt" | ConvertFrom-Csv | Export-Csv -Path "\\Path\to\destination\output.csv" -NoTypeInformation
}
