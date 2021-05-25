using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$file = $Request.Query.file
if (-not $file) {
    $file = $Request.Body.file
}

if ($file) {

    $saname = Get-ChildItem env:APPSETTING_saname
    $containername = Get-ChildItem env:APPSETTING_containername
    $key = Get-ChildItem env:APPSETTING_sakey
    Write-Host $key    
    $ctx = New-AzStorageContext -StorageAccountName $saname -StorageAccountKey $key
    


    $StartTime = Get-Date
    $EndTime = $startTime.AddMinutes(2.0)
    
    $location = New-AzStorageBlobSASToken -Container $containername -Blob $file -Permission r -StartTime $StartTime -ExpiryTime $EndTime -FullUri -Context $ctx
    
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::Redirect
    Headers = @{Location = $location}
})
