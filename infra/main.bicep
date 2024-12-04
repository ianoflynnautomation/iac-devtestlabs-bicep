targetScope = 'subscription'

param organisationName string
@secure()
param vmUserPassword string
@description(' Azure Devops PAT for register agent')
@secure()
param agentPat string
param agentPool string
param location string
@minLength(1)
@maxLength(64)
param environmentName string
param labName string = 'devtestlab01'
param labsDeploymentName string = 'lab-deploy'

param linuxAppServerVmName string = 'vm-las'
param linuxAppServerImageOffer string = '0001-com-ubuntu-server-focal'
param linuxAppServerImageSku string = '20_04-lts'
param linuxAppServerVmSize string = 'Standard_D2ds_v4'
param linuxAppServerDeploymentName string = 'las-vm-deploy'
param windowsClientVmName string = 'vm-ui'
param windowsClientImageOffer string = 'Windows-11'
param windowsClientImageSku string = 'win11-22h2-pro'
param windowsClientVmSize string = 'Standard_D2ds_v4'
param windowsClientDeploymentName string = 'wc-vm-deploy'
@description('Amount of UI System Test VMs')
@minValue(1)
@maxValue(10)
param windowsClientVmCount int = 1
param chromeVersion string = 'latest'
param firefoxVersion string = 'latest'


@description('Load shared prefixes')
var namingPrefixes = loadJsonContent('abbreviations.json')
var labVirtualNetworkName = 'Dtl${labName}'
var labSubnetName = '${labVirtualNetworkName}Subnet'
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module lab 'testing/devtestlabs/labs.bicep' = {
  name: labsDeploymentName
  params: {
    labName: labName
    location: rg.location
    tags: tags
  }
  scope: rg
}

module applicationServerVm 'testing/devtestlabs/vm-linux-server.bicep' = {
  name: linuxAppServerDeploymentName
  params: {
    linuxAppServerVmName: '${namingPrefixes.labVirtualMachinePrefix}-${linuxAppServerVmName}'
    location: rg.location
    tags: tags
    imageOffer: linuxAppServerImageOffer
    imageSku: linuxAppServerImageSku
    vmSize: linuxAppServerVmSize
    labName: labName
    labVirtualNetworkName: labVirtualNetworkName
    labSubnetName: labSubnetName
    adminPassword: vmUserPassword
    Agent_for_Linux_adoAccount: organisationName
    Agent_for_Linux_adoPat: agentPat
    Agent_for_Linux_adoPool: agentPool
    Agent_for_Linux_agentName: linuxAppServerVmName
  }
  scope: rg
  dependsOn: [
    lab
  ]
}

module uiVm 'testing/devtestlabs/vm-windows-client.bicep' = [
  for i in range(1, windowsClientVmCount): {
    name: '${windowsClientDeploymentName}${i}'
    params: {
      vmName: '${namingPrefixes.labVirtualMachinePrefix}-${windowsClientVmName}${i}'
      imageOffer: windowsClientImageOffer
      imageSku: windowsClientImageSku
      location: rg.location
      tags: tags
      vmSize: windowsClientVmSize
      labName: labName
      labVirtualNetworkName: labVirtualNetworkName
      labSubnetName: labSubnetName
      adminPassword: vmUserPassword
      Install_Chocolatey_Packages_chrome_packageVersion: chromeVersion
      Install_Chocolatey_Packages_firefox_packageVersion: firefoxVersion
      Agent_vstsAccount: organisationName
      Agent_vstsPassword: agentPat
      Agent_poolName: agentPool
      Agent_agentName: '${windowsClientVmName}${i}'
      Agent_RunAsAutoLogon: false
      Agent_windowsLogonPassword: vmUserPassword
    }
    scope: rg
    dependsOn: [
      lab
    ]
  }
]

output LAB_ID string = lab.outputs.labId
output LAB_UI_VM_NAME array = [
  for i in range(1, windowsClientVmCount): {
    id: uiVm[i - 1].outputs.labVMId
    name: uiVm[i - 1].outputs.labVMName
  }
]
output LAB_APPLICATION_SERVER_VM_NAME string = applicationServerVm.outputs.labVMName
output LAB_APPLICATION_SERVER_VM_ID string = applicationServerVm.outputs.labVMId
