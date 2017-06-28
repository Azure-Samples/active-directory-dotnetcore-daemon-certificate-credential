---
services: active-directory
platforms: dotnet
author: jmprieur
---
# Authenticating to Azure AD in daemon apps with certificates

![](https://identitydivision.visualstudio.com/_apis/public/build/definitions/a7934fdd-dcde-4492-a406-7fad6ac00e17/30/badge)
![](https://githuborgrepohealth.azurewebsites.net/api/TestBadge?id=3)

In this sample a .NET core console application (TodoListDaemonWithCert-core) calls an ASP.Net core web API (TodoListService-Core) using its app identity. This scenario is useful for situations where headless or unattended job or process needs to run as an application identity, instead of as a user's identity. The application uses the Active Directory Authentication Library (ADAL) to get a token from Azure AD using the OAuth 2.0 client credential flow, where the client credential is a certificate.

This sample is the equivalent in .NET core to [dotnet-daemon-certificate-credential](https://github.com/Azure-Samples/active-directory-dotnet-daemon-certificate-credential), which is proposed for the .NET desktop.

For more information about how the protocols work in this scenario and other scenarios, see [Authentication Scenarios for Azure AD](http://go.microsoft.com/fwlink/?LinkId=394414) and [Service to service calls using client credentials](https://github.com/Microsoft/azure-docs/blob/master/articles/active-directory/develop/active-directory-protocols-oauth-service-to-service.md)

> Looking for previous versions of this code sample? Check out the tags on the [releases](../../releases) GitHub page.

## How to Run this sample

To run this sample, you will need:
 - Visual Studio 2017 or another editor. See [Get Started with .NET Core](https://www.microsoft.com/net/core#windowsvs2017) for the list of tools you might want to use depending on your platform
 - An Internet connection
 - An Azure Active Directory (Azure AD) tenant. For more information on how to get an Azure AD tenant, please see [How to get an Azure AD tenant](https://azure.microsoft.com/en-us/documentation/articles/active-directory-howto-tenant/)
 - (Optional) If you want automatically create the applications in AAD corresponding to the daemon and service, and update the configuration files in their respective Visual Studio projects, you can run a script which requires Azure AD PowerShell. For details on how to install it, please see [the Azure Active Directory V2 PowerShell Module](https://www.powershellgallery.com/packages/AzureAD/).
 Alternatively, you also have the option of configuring the applications  manually through the Azure portal and by editing the code.

### Step 1:  Clone or download this repository

You can clone this repository from Visual Studio. Alternatively, from your shell or command line, use:

`git clone https://github.com/Azure-Samples/active-directory-dotnetcore-daemon-certificate-credential.git`

> Note that the names of the repository and the project are pretty long. On Windows, you probably want to clone this repository close to a disk root. 

### Step 2:  Register the sample with your Azure Active Directory tenant, create a certificate and configure the code

There are two options:
 - Option 1: you run the `Configure.ps1` PowerShell script which creates two applications in the Azure Active Directory, (one for the client and one for the service), creates a certificate on your local machine, and then updates the configuration files in the Visual Studio projects to point to the newly created apps and certificate.
 - Option 2: you do the same manually.

If you want to understand in more depth what needs to be done in the Azure portal, and how to change the code (Option 2), please have a look at [Manual-Configuration-Steps.md](./Manual-Configuration-Steps.md). Otherwise (Option 1), the steps to use the PowerShell are the following:

#### Find your tenant ID
If you have access to multiple Azure Active Directory tenants, you must specify the ID of the tenant in which you wish to create the applications. Here's how to find you tenant ID:
 1. Sign in to the [Azure portal](https://portal.azure.com).
 2. On the top bar, click on your account and under the **Directory** list, choose the Active Directory tenant where you wish to register your application.
 3. Click on **More Services** in the left hand nav, and choose **Azure Active Directory**.
 4. Click on **Properties** and copy the value of the **Directory ID** property to the clipboard. This is your tenant ID. We'll need it in the next step.

#### Run the PowerShell script
 1. Open the PowerShell command window and navigate to the root directory of the project.
 2. The default Execution Policy for scripts is usually Restricted. In order to run the PowerShell script you need to set the Execution Policy to Unrestricted. You can set this just for the current PowerShell process by running the command

 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted`
 
 3. Now run the script.

  `.\Configure.ps1 -tenantId <tenant ID>`

  Replace `<tenant ID>` with the tenant ID that you previously copied from the Azure portal.
  
 4. When requested, sign-in with the username and password of a user who has permissions to create applications in the AAD tenant.

> The script executes and provisions the AAD applications (If you look at the AAD applications in the portal after that the script has run, you'll have two additional applications). The script also updates two configuration files in the Visual Studio solution (`TodoListDaemonWithCert-core\appsettings.json` and `TodoListService-Core\appsettings.json`)
 5. If you intend to clean up the azure AD applications from the Azure AD tenant after running the sample see Step 5 below.

### Step 3:  Run the sample
#### Option 1: Run the sample from Visual Studio
Clean the solution, rebuild the solution, and run it.  You might want to go into the solution properties and set both projects as startup projects, with the service project starting first. To do this you can for instance:
 1. Right click on the solution in the solution explorer and choose **Set Startup projects** from the context menu.
 2. choose **Multiple startup projects**
  - TodoListDaemonWithCert: **Start**
  - TodoListService: Start **Start without debugging**
 3. In the Visual Studio tool bar, press the **start** button: a web window appears running the service and a console application runs the dameon application under debugger. you can set breakpoints to understand the call to ADAL.NET.

The daemon will add items to its To Do list and then read them back.

#### Option 2: Run the sample from any platform
See [Get Started with .NET Core](https://www.microsoft.com/net/core#windowsvs2017) to learn how to run the sample on Linux and Mac (```dotnet run```)


### (Optional) Step 4:  Clean up the applications in the Azure AD tenant
When you are done with running and understanding the sample, if you want to remove your Applications from AD just run:

`.\Cleanup.ps1 -tenantId <tenant ID>`

Replace with the tenant ID that you previously copied from the Azure portal.
If you do that you also probably want to undo the changes in the `appsettings.json` files.


## FAQ
- [How to use a pre-existing certificate](https://github.com/Azure-Samples/active-directory-dotnet-daemon-certificate-credential/issues/29) instead of generating a self signed certificate.
