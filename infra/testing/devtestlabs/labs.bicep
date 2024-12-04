metadata description = 'Create a DevTest Lab with a Virtual Network '

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
param serviceName string = 'lab'
param tags object = {}

// var labSubnetName = '${labVirtualNetworkName}Subnet'
// var labVirtualNetworkId = labVirtualNetwork.id
var labVirtualNetworkName = 'Dtl${labName}'

resource lab 'Microsoft.DevTestLab/labs@2018-09-15' = {
  name: labName
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
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

// resource labVirtualMachine 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = {
//   parent: lab
//   name: 'vmName01'
//   location: location
//   properties: {
//     userName: 'userName'
//     password: 'Password1234!'
//     labVirtualNetworkId: labVirtualNetworkId
//     labSubnetName: labSubnetName
//     size: 'Standard_D4_v3'
//     allowClaim: false
//     galleryImageReference: {
//       offer: 'WindowsServer'
//       publisher: 'MicrosoftWindowsServer'
//       sku: '2019-Datacenter'
//       osType: 'Windows'
//       version: 'latest'
//     }
//   }
// }

output labId string = lab.id

