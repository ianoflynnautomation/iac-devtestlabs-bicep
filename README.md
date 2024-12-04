## Summary

The main.bicep file defines the infrastructure for a DevTest Lab environment with both Linux and Windows virtual machines, designed to spin up an environment for development or testing.

## Tools we'll be using

- Bicep
- Terraform
- Github actions
- Azure pipelines
- Azure azd


## Prerequisites
The following prerequisites are required to use this application. Please ensure that you have them all installed locally.

- [Azure Developer CLI](https://aka.ms/azd-install)
- [.NET SDK 8.0](https://dotnet.microsoft.com/download/dotnet/8.0) - for the API backend

## Overview
**`Scope:`** Subscription-level deployment. \
**`Purpose: `** Provision a DevTest Lab environment with: \
    - A configurable Linux application server/ windows application server vm to deploy for example a deployment of an onprem docker enviroment. \
    - Multiple Windows client VMs for system testing where you need more control over the VM's (For example, hardware in the loop testing ).


## Key Resources
**`DevTest Lab`** \
    - Creates a DevTest Lab named devtestlab01 (default).

**`Linux Application Server:`** \
    - Single VM for application hosting. \
    - Ubuntu-based (default image: 20.04 LTS). \
    - Preinstalled artifacts such as Docker, Docker compose plugin, agent etc.

**`Windows Client VMs:`** \
    - Deploys one or more Windows VMs (up to 10). \
    - Default: Windows 11 (Pro, 22H2). \
    - Preinstalled artifacts needed for test execution such as browsers, powershell, nodejs etc.

### Quickstart
To learn how to get started with any azure azd, follow the steps in [Quickstart: Deploy an Azure Developer CLI template](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/get-started?tabs=localinstall&pivots=programming-language-nodejs) 

This quickstart will show you how to authenticate on Azure, initialize using a template, provision infrastructure and deploy code on Azure via the following commands:

```bash
# Log in to azd. Only required once per-install.
azd auth login

# First-time project setup. Initialize a project in the current directory.
azd init 

# Provision and deploy to Azure
azd up

# Clean up resources
azd down
```


