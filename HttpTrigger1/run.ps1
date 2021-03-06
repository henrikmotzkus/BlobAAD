using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
# Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$file = $Request.Query.file
if (-not $file) {
    $file = $Request.Body.file
}

try{
    if ($file) {
        
        # Getting settings
        $saname = $env:APPSETTING_saname
        $containername = $env:APPSETTING_containername
        $key = $env:APPSETTING_sakey

        #Generating a context for using in subsequent calls
        $ctx = New-AzStorageContext -StorageAccountName $saname -StorageAccountKey $key

        # Check if blob exists
        $blob = Get-AzStorageBlob -Blob $file -Container $containername -Context $ctx -ErrorAction Stop

        # Creating the SAS token
        $StartTime = Get-Date
        $EndTime = $startTime.AddMinutes(2.0)
        $location = New-AzStorageBlobSASToken -Container $containername -Blob $file -Permission r -StartTime $StartTime -ExpiryTime $EndTime -FullUri -Context $ctx
        
    }
}
Catch {
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::BadRequest
        Body = "Nothing found"
    })
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::Redirect
    Headers = @{Location = $location}
})
