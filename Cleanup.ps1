param([Parameter(Mandatory=$false)][PSCredential]$Credential=$null, [Parameter(Mandatory=$true)][string]$TenantId)
Import-Module AzureAD
$ErrorActionPreference = 'Stop'


Function Cleanup
{
<#
.Description
This function removes the Azure AD applications for the sample. These applications were created by the Configure.ps1 script
#>
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage='Tenant ID (This is a GUID which represents the "Directory ID" of the AzureAD tenant into which you want to create the apps')]
        [PSCredential] $Credential,
        [string] $tenantId
    )

   process
   {
    # $tenantId is the Active Directory Tenant. This is a GUID which represents the "Directory ID" of the AzureAD tenant 
    # into which you want to create the apps. Look it up in the Azure portal in the "Properties" of the Azure AD. 

    # Login to Azure PowerShell (interactive if credentials are not already provided: 
    # you'll need to sign-in with creds enabling your to create apps in the tenant)
    if (!$Credential)
    {
        $creds = Connect-AzureAD -TenantId $tenantId
    }
    else
    {
        $creds = Connect-AzureAD -TenantId $tenantId -Credential $Credential
    }

    $tenant = Get-AzureADTenantDetail
    $tenantName =  $tenant.VerifiedDomains[0].Name

    . .\Parameters.ps1

    # Removes the applications
    Write-Host "Removing Application '$serviceAppIdURI' if needed"
    $app=Get-AzureADApplication -Filter "identifierUris/any(uri:uri eq '$serviceAppIdURI')"  
    if ($app)
    {
        Remove-AzureADApplication -ObjectId $app.ObjectId
    }

      Write-Host "Removing Application '$daemonAppIdURI' if needed"
    $app=Get-AzureADApplication -Filter "identifierUris/any(uri:uri eq '$daemonAppIdURI')"      
    if ($app)
    {
        Remove-AzureADApplication -ObjectId $app.ObjectId
    }
    
       Write-Host "Done."
   }
}

Cleanup -Credential $Credential -tenantId $TenantId
