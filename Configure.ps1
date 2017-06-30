# This script creates the Azure AD applications needed for this sample and updates the configuration files
# for the visual Studio projects from the data in the Azure AD applications.
#
# Before running this script you need to install the AzureAD cmdlets as an administrator.
# For this:
# 1) Run Powershell as an administrator
# 2) in the PowerShell window, type: Install-Module AzureAD
# 3) Set the ExecutionPolicy to Unrestricted: Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
#
# To run this script
# 4) With the Azure portal (https://portal.azure.com), choose your active directory tenant, then go to the Properties of the tenant and copy
#    the DirectoryID. This is what we'll use in this script for the tenant ID
#
# To configure the applications
# 5) Run the following command in the project root:
#      $apps = ConfigureApplications -tenantId [place here the GUID representing the tenant ID]
#    You will be prompted by credentials, be sure to enter credentials for a user who can create applications
#    in the tenant
#
# To execute the samples
# 5) Build and execute the applications. This just works
#
# To cleanup
# 6) Optionaly if you want to cleanup the applications in the Azure AD, run:
#      CleanUp $apps
#    The applications are un-registered
param([Parameter(Mandatory=$false)][PSCredential]$Credential=$null, [Parameter(Mandatory=$true)][string]$TenantId)
Import-Module AzureAD
$ErrorActionPreference = 'Stop'


# Updates the config file for a client application
Function UpdateClientConfigFile([string] $configFilePath, [string] $tenantId, [string] $clientId, [string] $appUri, [string] $baseAddress, [string] $certificateName)
{
	$settings = (Get-Content $configFilePath -Raw) | ConvertFrom-Json;
	$settings.Tenant = $tenantId
	$settings.ClientId = $clientId
	$settings.TodoListResourceId = $appUri
	$settings.TodoListBaseAddress = $baseAddress
    if ($certificateName)
    {
		$settings.CertName = $certificateName
    }
	ConvertTo-Json -InputObject $settings | Out-File $configFilePath
}


# Updates the config file for a client application
Function UpdateServiceConfigFile([string] $configFilePath, [string] $tenantId, [string] $clientId, [string] $domain, [string] $audience)
{
	$settings = (Get-Content $configFilePath -Raw) | ConvertFrom-Json;
	$settings.Authentication.AzureAd.Audience = $audience
	$settings.Authentication.AzureAd.ClientId = $clientId
	$settings.Authentication.AzureAd.Domain = $domain
	$settings.Authentication.AzureAd.TenantId = $tenantId
	ConvertTo-Json -InputObject $settings | Out-File $configFilePath
}

Function ConfigureApplications
{
<#
.Description
This function creates the Azure AD applications for the sample in the provided Azure AD tenant and updates the
configuration files in the client and service project  of the visual studio solution (App.Config and Web.Config)
so that they are consistent with the Applications parameters
#>
    [CmdletBinding()]
    param(
        [PSCredential] $Credential,
        [Parameter(HelpMessage='Tenant ID (This is a GUID which represents the "Directory ID" of the AzureAD tenant into which you want to create the apps')]
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

    # Create the Azure Active Directory Application and it's service principal
    Write-Host "Creating the service appplication ($serviceAadAppName)"
    $serviceApplication = New-AzureADApplication -DisplayName $serviceAadAppName `
                                                 -HomePage $serviceHomePage `
                                                 -IdentifierUris $serviceAppIdURI `
											     -ReplyUrls $serviceHomePage'/signin-oidc'
    $serviceservicePrincipal = New-AzureADServicePrincipal -AppId $serviceApplication.AppId

    # Create the daemon application
    $daemonApplication = New-AzureADApplication -DisplayName $daemonAadAppName `
                                                -HomePage $daemonHomePage `
                                                -IdentifierUris $daemonAppIdURI
    $daemonservicePrincipal = New-AzureADServicePrincipal  -AppId $daemonApplication.AppId

    # Generate a certificate
    Write-Host "Creating the client appplication ($daemonAadAppName)"
    $certificate=New-SelfSignedCertificate -Subject $certificateName `
                                           -CertStoreLocation "Cert:\CurrentUser\My" `
                                           -KeyExportPolicy Exportable `
                                           -KeySpec Signature
    $certKeyId = [Guid]::NewGuid()
    $certBase64Value = [System.Convert]::ToBase64String($certificate.GetRawCertData())
    $certBase64Thumbprint = [System.Convert]::ToBase64String($certificate.GetCertHash())

    # Add a Azure Key Credentials from the certificate for the daemon application
    $applicationKeyCredentials = New-AzureADApplicationKeyCredential -ObjectId $daemonApplication.ObjectId `
                                                                     -CustomKeyIdentifier $certificateName `
                                                                     -Type AsymmetricX509Cert `
                                                                     -Usage Verify `
                                                                     -Value $certBase64Value `
                                                                     -StartDate $certificate.NotBefore `
                                                                     -EndDate $certificate.NotAfter

    # Update the config file in the daemon application
    $configFile = $pwd.Path + "\TodoListDaemonWithCert-core\appsettings.json"
    Write-Host "Updating the configuration file for the client ($configFile)"
    UpdateClientConfigFile -configFilePath $configFile `
       -tenantId $tenantId `
       -clientId $daemonApplication.AppId `
       -appUri $serviceAppIdURI `
       -baseAddress $serviceHomePage `
       -certificateName $certificateName

    # Update the config file in the service application
    $configFile = $pwd.Path + "\TodoListService-Core\appsettings.json"
    Write-Host "Updating the client sample ($configFile)"
    UpdateServiceConfigFile -configFilePath $configFile `
                            -tenantId $tenantId `
                            -audience $serviceAppIdURI `
                            -clientId $serviceApplication.AppId `
	                        -domain $tenantName

    # Completes
    Write-Host "Done."
   }
}

# Run interactively (will ask you for the tenant ID)
ConfigureApplications -Credential $Credential -tenantId $TenantId

# you can also provide the tenant ID and the credentials
# $tenantId = "ID of your AAD directory"
# $apps = ConfigureApplications -tenantId $tenantId


# When you have built your Visual Studio solution and ran the code, if you want to clean up the Azure AD applications, just
# run the following command in the same PowerShell window as you ran ConfigureApplications
# . .\CleanUp -Credentials $Credentials
