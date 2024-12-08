metadata description = 'Create a DevTest Lab with a Virtual Network '

@description('The location of the DevTest Lab')
@minLength(1)
param location string = resourceGroup().location
@description('The name of the environment')
@allowed([
  'dev'
  'staging'
])
param environmentName string
@description('The deployment type of the DevTest Lab')
@allowed([
  'on-prem'
  'saas'
])
param deploymentType string
@description('The name of the DevTest Lab')
@minLength(1)
@maxLength(64)
param labName string
@description('The tags for the DevTest Lab')
param tags object = {}
@description('The name of the agent')
@minValue(1)
@maxValue(10)
param windowsClientVmCount int
@description('The name of Azure DevOps account')
@secure()
param adoAccountName string
@description('The Azure DevOps PAT token')
@secure()
param adoPatToken string
@description('The name of the Azure DevOps pool')
@secure()
param adoPoolName string
@description('The password of the virtual machine administrator.')
@secure()
@minLength(6)
@maxLength(72)
param linuxAppServerVmAdminPassword string
@description('The password of the virtual machine administrator.')
@secure()
@minLength(8)
@maxLength(123)
param windowsClientVmAdminPassword string

@description('Configuration for Linux app server VMs')
param linuxAppServerVmConfig object = {
  dev: {
    imageOffer: '0001-com-ubuntu-server-focal'
    imageSku: '20_04-lts'
    storageType: 'StandardSSD'
    vmSize: 'Standard_D2ds_v4'
  }
  staging: {
    imageOffer: '0001-com-ubuntu-server-focal'
    imageSku: '20_04-lts'
    storageType: 'StandardSSD'
    vmSize: 'Standard_D8ds_v4'
  }
}

@description('Configuration for Windows client VMs')
param windowsClientVmConfig object = {
  dev: {
    imageOffer: 'Windows-11'
    imageSku: 'win11-22h2-pro'
    storageType: 'StandardSSD'
    vmSize: 'Standard_D2ds_v4'
  }
  staging: {
    imageOffer: 'Windows-11'
    imageSku: 'win11-22h2-pro'
    storageType: 'StandardSSD'
    vmSize: 'Standard_D8ds_v4'
  }
}


var labVirtualNetwordId = resourceId('Microsoft.DevTestLab/labs/virtualnetworks', labName, labVirtualNetworkName)
// var windowsClientVmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, linuxAppServerVmName)
var linuxAppServerVmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, linuxAppServerVmName)
// var linuxAppServerVmFullVmName = '${labName}/${linuxAppServerVmName}'
// var windowsClientVmFullVmName = '${labName}/${windowsClientVmName}'
var linuxAppServerVmFullVmName = linuxAppServerVmName
var windowsClientVmFullVmName = windowsClientVmName
var labVirtualNetworkName = 'Dtl${labName}'
var labSubnetName = '${labVirtualNetworkName}Subnet'
var labServiceName = 'lab'
var labStorageType = 'Standard'

var linuxAppServerVmUserName = 'testuser'
var linuxAppServerVmName = 'vm-las'
var linuxVmServiceName = 'linux-server-vm'

var agentForLinuxAgentPath = '/agent'
var agentForLinuxAgentName = ''
var aptGetDockerComposePluginPackages = 'docker-compose-plugin'
var aptGetDockerComposePluginUpdate = 'true'
var aptGetDockerComposePluginOptions = ''

var windowsClientVmServiceName = 'windows-client-vm'
var agentForWindowsAgentName = ''
var windowsClientVmUserName = 'tester'
var windowsClientVmName = 'vm-ui'

var agentWindowsLogonPassword = ''
var agentReplaceAgent = true
var agentWorkDirectory = ''
var agentDriverLetter = 'C'
var agentWindowsLogonAccount = ''
var agentRunAsAutoLogon = false
var agentNameSuffix = ''
var installChocolateyPackagesChromePackage = 'googlechrome'
var installChocolateyPackagesChromePackageVersion = 'latest'
var installChocolateyPackagesChromeAllowEmptyChecksums = true
var installChocolateyPackagesChromeIgnoreChecksums = true
var installChocolateyPackagesFirefoxPackage = 'firefox'
var installChocolateyPackagesFirefoxPackageVersion = 'latest'
var installChocolateyPackagesFirefoxAllowEmptyChecksums = true
var installChocolateyPackagesFirefoxIgnoreChecksums = true
var installChocolateyPackagesPsPackages = 'powershell-core'
var installChocolateyPackagesPsAllowEmptyChecksums = true
var installChocolateyPackagesPsIgnoreChecksums = true
var installChocolateyPackagesAzPackages = 'azure-cli'
var installChocolateyPackagesAzAllowEmptyChecksums = true
var installChocolateyPackagesAzIgnoreChecksums = true


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

resource linuxAppServerVm 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = if (deploymentType == 'on-prem') {
  parent: lab
  name: linuxAppServerVmFullVmName
  location: location
  tags: union(tags, { 'azd-service-name': linuxVmServiceName })
  properties: {
    labVirtualNetworkId: labVirtualNetwordId
    galleryImageReference: {
      offer: linuxAppServerVmConfig[environmentName].imageOffer
      publisher: 'canonical'
      sku: linuxAppServerVmConfig[environmentName].imageSku
      osType: 'Linux'
      version: 'latest'
    }
    size: linuxAppServerVmConfig[environmentName].vmSize
    userName: linuxAppServerVmUserName
    password: linuxAppServerVmAdminPassword
    isAuthenticationWithSshKey: false
    artifacts: linuxVmDefaultArtifacts
    labSubnetName: labSubnetName
    disallowPublicIpAddress: true
    storageType: linuxAppServerVmConfig[environmentName].storageType
    allowClaim: false
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
        offer: windowsClientVmConfig[environmentName].imageOffer
        publisher: 'microsoftwindowsdesktop'
        sku: windowsClientVmConfig[environmentName].imageSku
        osType: 'Windows'
        version: 'latest'
      }
      size: windowsClientVmConfig[environmentName].vmSize
      userName: windowsClientVmUserName
      password: windowsClientVmAdminPassword
      isAuthenticationWithSshKey: false
      artifacts: union(chromebrowserArtifacts, firefoxBrowserArtifacts, windowsClientVmDefaultArtifacts)
      labSubnetName: labSubnetName
      disallowPublicIpAddress: true
      storageType: windowsClientVmConfig[environmentName].storageType
      allowClaim: false
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
        value: aptGetDockerComposePluginPackages
      }
      {
        name: 'update'
        value: aptGetDockerComposePluginUpdate
      }
      {
        name: 'options'
        value: aptGetDockerComposePluginOptions
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
        value: adoAccountName
      }
      {
        name: 'adoPat'
        value: adoPatToken
      }
      {
        name: 'adoPool'
        value: adoPoolName
      }
      {
        name: 'agentPath'
        value: agentForLinuxAgentPath
      }
      {
        name: 'agentName'
        value: agentForLinuxAgentName
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
        value: installChocolateyPackagesChromePackage
      }
      {
        name: 'packageVersion'
        value: installChocolateyPackagesChromePackageVersion
      }
      {
        name: 'allowEmptyChecksums'
        value: installChocolateyPackagesChromeAllowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: installChocolateyPackagesChromeIgnoreChecksums
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
        value: installChocolateyPackagesFirefoxPackage
      }
      {
        name: 'packageVersion'
        value: installChocolateyPackagesFirefoxPackageVersion
      }
      {
        name: 'allowEmptyChecksums'
        value: installChocolateyPackagesFirefoxAllowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: installChocolateyPackagesFirefoxIgnoreChecksums
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
        value: installChocolateyPackagesPsPackages
      }
      {
        name: 'allowEmptyChecksums'
        value: installChocolateyPackagesPsAllowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: installChocolateyPackagesPsIgnoreChecksums
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
        value: installChocolateyPackagesAzPackages
      }
      {
        name: 'allowEmptyChecksums'
        value: installChocolateyPackagesAzAllowEmptyChecksums
      }
      {
        name: 'ignoreChecksums'
        value: installChocolateyPackagesAzIgnoreChecksums
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
        value: adoAccountName
      }
      {
        name: 'vstsPassword'
        value: adoPatToken
      }
      {
        name: 'agentName'
        value: agentForWindowsAgentName
      }
      {
        name: 'agentNameSuffix'
        value: agentNameSuffix
      }
      {
        name: 'poolName'
        value: adoPoolName
      }
      {
        name: 'RunAsAutoLogon'
        value: agentRunAsAutoLogon
      }
      {
        name: 'windowsLogonAccount'
        value: agentWindowsLogonAccount
      }
      {
        name: 'windowsLogonPassword'
        value: agentWindowsLogonPassword
      }
      {
        name: 'driverLetter'
        value: agentDriverLetter
      }
      {
        name: 'workDirectory'
        value: agentWorkDirectory
      }
      {
        name: 'replaceAgent'
        value: agentReplaceAgent
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
