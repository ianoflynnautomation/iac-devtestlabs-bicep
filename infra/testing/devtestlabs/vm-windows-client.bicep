metadata description = 'Create a Windows VM in a DevTestLab with Chocolatey packages and Azure DevOps Agent'

@description('The location of the resource.')
param location string = resourceGroup().location
@description('The name of the VM in the DevTest Lab')
@minLength(1)
@maxLength(15)
param vmName string = 'c-vm'
@description('The size of the virtual machine.')
@allowed([
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
])
param vmSize string = 'Standard_D2ds_v4'
@description('The password of the virtual machine administrator.')
@secure()
@minLength(8)
@maxLength(123)
param adminPassword string
@description('The offer of the image.')
@allowed([
  'Windows-11'
  'Windows-10'
])
param imageOffer string = 'Windows-11'
@description('The SKU of the image.')
@allowed([
  'win11-22h2-pro'
  'win10-22h2-pro'
])
param imageSku string = 'win11-22h2-pro'
@description('Azure DevOps Account for the agent')
param Agent_vstsAccount string = ''
@description('Azure DevOps PAT for the agent')
@secure()
param Agent_vstsPassword string
@description('Name of the agent')
param Agent_agentName string = ''
@description('Azure DevOps Pool for the agent')
param Agent_poolName string = ''


@description('The size of the virtual machine.')
@allowed([
  'StandardSSD'
  'StandardHDD'
])
param osDiskType string = 'StandardSSD'
@description('The name of the DevTest Lab in which to create the virtual machine.')
param labName string
@description('The name of the virtual network in the DevTest Lab.')
param labVirtualNetworkName string
@description('The lab subnet name of the virtual machine.')
param labSubnetName string
@description('The user name of the virtual machine.')
param vmUserName string = 'tester'
@description('Chocolatey packages for Chrome')
param Install_Chocolatey_Packages_chrome_package string = 'googlechrome'
@description('Version of the Chocolatey package for Chrome')
param Install_Chocolatey_Packages_chrome_packageVersion string = 'latest'
@description('Allow empty checksums for Chocolatey packages for Chrome')
param Install_Chocolatey_Packages_chrome_allowEmptyChecksums bool = true
@description('Ignore checksums for Chocolatey packages for Chrome')
param Install_Chocolatey_Packages_chrome_ignoreChecksums bool = true
@description('Chocolatey packages for Firefox')
param Install_Chocolatey_Packages_firefox_package string = 'firefox'
@description('Version of the Chocolatey package for Firefox')
param Install_Chocolatey_Packages_firefox_packageVersion string = 'latest'
@description('Allow empty checksums for Chocolatey packages for Firefox')
param Install_Chocolatey_Packages_firefox_allowEmptyChecksums bool = true
@description('Ignore checksums for Chocolatey packages for Firefox')
param Install_Chocolatey_Packages_firefox_ignoreChecksums bool = true
@description('Chocolatey packages for PowerShell')
param Install_Chocolatey_Packages_ps_packages string = 'powershell-core'
@description('Allow empty checksums for Chocolatey packages for PowerShell')
param Install_Chocolatey_Packages_ps_allowEmptyChecksums bool = true
@description('Ignore checksums for Chocolatey packages for PowerShell')
param Install_Chocolatey_Packages_ps_ignoreChecksums bool = true
@description('Chocolatey packages for Azure CLI')
param Install_Chocolatey_Packages_az_packages string = 'azure-cli'
@description('Allow empty checksums for Chocolatey packages for Azure CLI')
param Install_Chocolatey_Packages_az_allowEmptyChecksums bool = true
@description('Ignore checksums for Chocolatey packages for Azure CLI')
param Install_Chocolatey_Packages_az_ignoreChecksums bool = true
@description('Suffix for the agent name')
param Agent_agentNameSuffix string = ''
@description('Run as auto logon')
param Agent_RunAsAutoLogon bool = false
@description('Windows logon account')
param Agent_windowsLogonAccount string = ''
@description('Windows logon password')
@secure()
param Agent_windowsLogonPassword string
@description('Driver letter')
param Agent_driverLetter string = 'C'
@description('Work directory')
param Agent_workDirectory string = ''
@description('Replace agent')
param Agent_replaceAgent bool = true
param serviceName string = 'windows-client-vm'
param tags object = {}

var fullVmName = '${labName}/${vmName}'
var labVirtualNetwordId = resourceId('Microsoft.DevTestLab/labs/virtualnetworks', labName, labVirtualNetworkName)
var vmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, vmName)


resource vm 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = {
  name: fullVmName
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  properties: {
    labVirtualNetworkId: labVirtualNetwordId
    galleryImageReference: {
      offer: imageOffer
      publisher: 'microsoftwindowsdesktop'
      sku: imageSku
      osType: 'Windows'
      version: 'latest'
    }
    size: vmSize
    userName: vmUserName
    password: adminPassword
    isAuthenticationWithSshKey: false
    artifacts: union(chromebrowserArtifacts, firefoxBrowserArtifacts, defaultArtifacts)
    labSubnetName: labSubnetName
    disallowPublicIpAddress: true
    storageType: osDiskType
    allowClaim: false
    // networkInterface: {
    //   sharedPublicIpAddressConfiguration: {
    //     useInboundNatRules: [
    //       {
    //       transportRuleName: 'tcp'
    //       backendPort: 3389
    //       }
    //     ]
    //   }
    // }
  }
}

var chromebrowserArtifacts = [
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'windows-chocolatey'
    )
    parameters: [
      {
        name: 'packages'
        value: Install_Chocolatey_Packages_chrome_package
      }
      {
        name: 'packageVersion'
        value: Install_Chocolatey_Packages_chrome_packageVersion
      }
      {
        name: 'allowEmptyChecksums'
        value: Install_Chocolatey_Packages_chrome_allowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: Install_Chocolatey_Packages_chrome_ignoreChecksums
      }
    ]
  }
]

var firefoxBrowserArtifacts = [
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'windows-chocolatey'
    )
    parameters: [
      {
        name: 'packages'
        value: Install_Chocolatey_Packages_firefox_package
      }
      {
        name: 'packageVersion'
        value: Install_Chocolatey_Packages_firefox_packageVersion
      }
      {
        name: 'allowEmptyChecksums'
        value: Install_Chocolatey_Packages_firefox_allowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: Install_Chocolatey_Packages_firefox_ignoreChecksums
      }
    ]
  }
]

var defaultArtifacts = [
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'windows-chocolatey'
    )
    parameters: [
      {
        name: 'packages'
        value: Install_Chocolatey_Packages_ps_packages
      }
      {
        name: 'allowEmptyChecksums'
        value: Install_Chocolatey_Packages_ps_allowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: Install_Chocolatey_Packages_ps_ignoreChecksums
      }
    ]
  }
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'windows-chocolatey'
    )
    parameters: [
      {
        name: 'packages'
        value: Install_Chocolatey_Packages_az_packages
      }
      {
        name: 'allowEmptyChecksums'
        value: Install_Chocolatey_Packages_az_allowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: Install_Chocolatey_Packages_az_ignoreChecksums
      }
    ]
  }
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'windows-vsts-build-agent'
    )
    parameters: [
      {
        name: 'vstsAccount'
        value: Agent_vstsAccount
      }
      {
        name: 'vstsPassword'
        value: Agent_vstsPassword
      }
      {
        name: 'agentName'
        value: Agent_agentName
      }
      {
        name: 'agentNameSuffix'
        value: Agent_agentNameSuffix
      }
      {
        name: 'poolName'
        value: Agent_poolName
      }
      {
        name: 'RunAsAutoLogon'
        value: Agent_RunAsAutoLogon
      }
      {
        name: 'windowsLogonAccount'
        value: Agent_windowsLogonAccount
      }
      {
        name: 'windowsLogonPassword'
        value: Agent_windowsLogonPassword
      }
      {
        name: 'driverLetter'
        value: Agent_driverLetter
      }
      {
        name: 'workDirectory'
        value: Agent_workDirectory
      }
      {
        name: 'replaceAgent'
        value: Agent_replaceAgent
      }
    ]
  }
]

output labVMId string = vmId
output labVMName string = vm.name
