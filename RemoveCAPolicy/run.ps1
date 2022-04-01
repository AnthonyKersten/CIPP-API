using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$APIName = $TriggerMetadata.FunctionName
Log-Request -user $request.headers.'x-ms-client-principal' -API $APINAME  -message "Accessed this API" -Sev "Debug"

# Interact with query parameters or the body of the request.
$TenantFilter = $Request.Query.TenantFilter
$policyId = $Request.Query.GUID
if (!$policyId) { exit }
try {
    $GraphRequest = New-GraphPostRequest -uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($policyId)" -type DELETE -tenant $TenantFilter
    Log-Request -user $request.headers.'x-ms-client-principal' -API $APINAME  -message "Deleted CA Policy $policyId" -Sev "Info" -tenant $TenantFilter
    $body = [pscustomobject]@{"Results" = "Succesfully deleted the policy" }

}
catch {
    Log-Request -user $request.headers.'x-ms-client-principal' -API $APINAME  -message "Could not delete CA policy $policyId. $($_.Exception.Message)" -Sev "Error" -tenant $TenantFilter
    $body = [pscustomobject]@{"Results" = "Could not delete policy: $($_.Exception.Message)" }

}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $body
    })

