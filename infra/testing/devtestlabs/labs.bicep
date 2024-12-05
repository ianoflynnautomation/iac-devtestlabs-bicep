metadata description = 'Create a DevTest Lab with a Virtual Network '

// DevTest Lab parameters
@description('The name of the DevTest Lab')
@minLength(1)
@maxLength(64)
param labName string
@description('The storage type of the lab')
@allowed([
  'Standard'
  'Premium'
])
param labStorageType string = 'Premium'
@description('The location of the DevTest Lab')
@minLength(1)
param location string = resourceGroup().location
@description('Load shared prefixes')
param labServiceName string = 'lab'
param tags object = {}
@description('The name of the VM in the DevTest Lab')
@minLength(1)
@maxLength(62)

// Linux App Server VM parameters
param linuxAppServerVmName string
@description('The size of the virtual machine.')
@allowed([
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
])
param linuxAppServerVmSize string
@description('The password of the virtual machine administrator.')
@secure()
@minLength(6)
@maxLength(72)
param linuxAppServerVmAdminPassword string
@description('The offer of the image.')
@allowed([
  '0001-com-ubuntu-server-focal'
  '0001-com-ubuntu-server-jammy'
])
param linuxAppServerVmImageOffer string
@description('The SKU of the image.')
@allowed([
  '20_04-lts'
  '22_04-lts'
])
param linuxAppServerVmImageSku string
@description('The size of the virtual machine.')
@allowed([
  'StandardSSD'
  'StandardHDD'
])
param linuxAppServerVmOsDiskType string = 'StandardSSD'
@description('Azure DevOps Account for the agent')
param Agent_for_Linux_adoAccount string
@description('Azure DevOps PAT for the agent')
@secure()
param Agent_for_Linux_adoPat string
@description('Azure DevOps Pool for the agent')
param Agent_for_Linux_adoPool string
@description('The user name of the virtual machine.')
param linuxAppServerVmUserName string = 'testuser'
@description('Path to install the agent')
param Agent_for_Linux_agentPath string = '/agent'
@description('Name of the agent')
param Agent_for_Linux_agentName string = ''
@description('Docker Compose Plugin packages')
param Apt_get_DockerComposePlugin_packages string = 'docker-compose-plugin'
@description('Docker Compose Plugin update')
param Apt_get_DockerComposePlugin_update string = 'true'
@description('Docker Compose Plugin options')
param Apt_get_DockerComposePlugin_options string = ''
param linuxVmServiceName string = 'linux-server-vm'

// Windows client VM parameters
@description('The name of the VM in the DevTest Lab')
@minLength(1)
@maxLength(15)
param windowsClientVmName string = 'c-vm'
@description('The size of the virtual machine.')
@allowed([
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
])
param windowsClientVmSize string = 'Standard_D2ds_v4'
@description('The user name of the virtual machine.')
param windowsClientVmUserName string = 'tester'
@description('The password of the virtual machine administrator.')
@secure()
@minLength(8)
@maxLength(123)
param windowsClientVmAdminPassword string
@description('The offer of the image.')
@allowed([
  'Windows-11'
  'Windows-10'
])
param windowsClientVmImageOffer string = 'Windows-11'
@description('The SKU of the image.')
@allowed([
  'win11-22h2-pro'
  'win10-22h2-pro'
])
param windowsClientVmImageSku string = 'win11-22h2-pro'
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
param windowsClientVmOsDiskType string = 'StandardSSD'
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
param windowsClientVmServiceName string = 'windows-client-vm'
param windowsClientVmCount int

var labVirtualNetwordId = resourceId('Microsoft.DevTestLab/labs/virtualnetworks', labName, labVirtualNetworkName)
// var windowsClientVmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, linuxAppServerVmName)
var linuxAppServerVmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, linuxAppServerVmName)
// var linuxAppServerVmFullVmName = '${labName}/${linuxAppServerVmName}'
// var windowsClientVmFullVmName = '${labName}/${windowsClientVmName}'
var linuxAppServerVmFullVmName = linuxAppServerVmName
var windowsClientVmFullVmName = windowsClientVmName
var labVirtualNetworkName = 'Dtl${labName}'
var labSubnetName = '${labVirtualNetworkName}Subnet'

resource lab 'Microsoft.DevTestLab/labs@2018-09-15' = {
  name: labName
  location: location
  tags: union(tags, { 'azd-service-name': labServiceName })
  properties: {
    environmentPermission: 'Contributor'
    extendedProperties: {}
    labStorageType: labStorageType
    mandatoryArtifactsResourceIdsLinux: []
    mandatoryArtifactsResourceIdsWindows: []
    premiumDataDisks: 'Disabled'
  }
}

resource labVirtualNetwork 'Microsoft.DevTestLab/labs/virtualnetworks@2018-09-15' = {
  parent: lab
  name: labVirtualNetworkName
}

resource linuxAppServerVm 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = {
  parent: lab
  name: linuxAppServerVmFullVmName
  location: location
  tags: union(tags, { 'azd-service-name': linuxVmServiceName })
  properties: {
    labVirtualNetworkId: labVirtualNetwordId
    galleryImageReference: {
      offer: linuxAppServerVmImageOffer
      publisher: 'canonical'
      sku: linuxAppServerVmImageSku
      osType: 'Linux'
      version: 'latest'
    }
    size: linuxAppServerVmSize
    userName: linuxAppServerVmUserName
    password: linuxAppServerVmAdminPassword
    isAuthenticationWithSshKey: false
    artifacts: linuxVmDefaultArtifacts
    labSubnetName: labSubnetName
    disallowPublicIpAddress: true
    storageType: linuxAppServerVmOsDiskType
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

resource windowsClientVm 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = [
  for i in range(0, windowsClientVmCount): {
    parent: lab
    name: '${windowsClientVmFullVmName}${i}'
    location: location
    tags: union(tags, { 'azd-service-name': windowsClientVmServiceName })
    properties: {
      labVirtualNetworkId: labVirtualNetwordId
      galleryImageReference: {
        offer: windowsClientVmImageOffer
        publisher: 'microsoftwindowsdesktop'
        sku: windowsClientVmImageSku
        osType: 'Windows'
        version: 'latest'
      }
      size: windowsClientVmSize
      userName: windowsClientVmUserName
      password: windowsClientVmAdminPassword
      isAuthenticationWithSshKey: false
      artifacts: union(chromebrowserArtifacts, firefoxBrowserArtifacts, windowsClientVmDefaultArtifacts)
      labSubnetName: labSubnetName
      disallowPublicIpAddress: true
      storageType: windowsClientVmOsDiskType
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
]

var linuxVmDefaultArtifacts = [
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'linux-install-docker'
    )
  }
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'linux-apt-package'
    )
    parameters: [
      {
        name: 'packages'
        value: Apt_get_DockerComposePlugin_packages
      }
      {
        name: 'update'
        value: Apt_get_DockerComposePlugin_update
      }
      {
        name: 'options'
        value: Apt_get_DockerComposePlugin_options
      }
    ]
  }
  {
    artifactId: resourceId(
      'Microsoft.DevTestLab/labs/artifactSources/artifacts',
      labName,
      'public repo',
      'linux-vsts-build-agent'
    )
    parameters: [
      {
        name: 'adoAccount'
        value: Agent_for_Linux_adoAccount
      }
      {
        name: 'adoPat'
        value: Agent_for_Linux_adoPat
      }
      {
        name: 'adoPool'
        value: Agent_for_Linux_adoPool
      }
      {
        name: 'agentPath'
        value: Agent_for_Linux_agentPath
      }
      {
        name: 'agentName'
        value: Agent_for_Linux_agentName
      }
    ]
  }
]

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

var windowsClientVmDefaultArtifacts = [
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


output windowsClientVm array = [
  for i in range(1, windowsClientVmCount): {
    id: windowsClientVm[i - 1].id
    name: windowsClientVm[i - 1].name
  }
]

output linuxAppServerVmId string = linuxAppServerVmId
output linuxAppServerVmName string = linuxAppServerVm.name
output labId string = lab.id
