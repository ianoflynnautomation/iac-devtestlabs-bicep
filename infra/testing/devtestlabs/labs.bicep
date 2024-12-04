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

output labId string = lab.id

