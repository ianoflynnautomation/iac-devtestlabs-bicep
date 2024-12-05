metadata description = 'Create a Linux VM in a DevTestLab with Docker, Docker Compose and Azure DevOps Agent'

@description('The location of the resource.')
param location string = resourceGroup().location
@description('The name of the VM in the DevTest Lab')
@minLength(1)
@maxLength(62)
param linuxAppServerVmName string
@description('The size of the virtual machine.')
@allowed([
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
])
param vmSize string
@description('The password of the virtual machine administrator.')
@secure()
@minLength(6)
@maxLength(72)
param adminPassword string
@description('The offer of the image.')
@allowed([
  '0001-com-ubuntu-server-focal'
  '0001-com-ubuntu-server-jammy'
])
param imageOffer string
@description('The SKU of the image.')
@allowed([
  '20_04-lts'
  '22_04-lts'
])
param imageSku string
@description('The size of the virtual machine.')
@allowed([
  'StandardSSD'
  'StandardHDD'
])
param osDiskType string = 'StandardSSD'
@description('Azure DevOps Account for the agent')
param Agent_for_Linux_adoAccount string
@description('Azure DevOps PAT for the agent')
@secure()
param Agent_for_Linux_adoPat string
@description('Azure DevOps Pool for the agent')
param Agent_for_Linux_adoPool string
@description('The name of the DevTest Lab in which to create the virtual machine.')
param labName string
@description('The name of the virtual network in the DevTest Lab.')
param labVirtualNetworkName string
@description('The lab subnet name of the virtual machine.')
param labSubnetName string

@description('The user name of the virtual machine.')
param vmUserName string = 'testuser'
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
param serviceName string = 'linux-server-vm'
param tags object = {}

var labVirtualNetwordId = resourceId('Microsoft.DevTestLab/labs/virtualnetworks', labName, labVirtualNetworkName)
var vmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, linuxAppServerVmName)
var fullVmName = '${labName}/${linuxAppServerVmName}'

resource vm 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = {
  name: fullVmName
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  properties: {
    labVirtualNetworkId: labVirtualNetwordId
    galleryImageReference: {
      offer: imageOffer
      publisher: 'canonical'
      sku: imageSku
      osType: 'Linux'
      version: 'latest'
    }
    size: vmSize
    userName: vmUserName
    password: adminPassword
    isAuthenticationWithSshKey: false
    artifacts: defaultArtifacts
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

var defaultArtifacts = [
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

output labVMId string = vmId
output labVMName string = vm.name
