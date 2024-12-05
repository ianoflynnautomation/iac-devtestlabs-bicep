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
param windowsClientVmName string = 'vm-ui'
param windowsClientImageOffer string = 'Windows-11'
param windowsClientImageSku string = 'win11-22h2-pro'
param windowsClientVmSize string = 'Standard_D2ds_v4'
param windowsClientVmCount int = 2

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
    linuxAppServerVmName: linuxAppServerVmName
    linuxAppServerVmImageOffer: linuxAppServerImageOffer
    linuxAppServerVmImageSku: linuxAppServerImageSku
    linuxAppServerVmSize: linuxAppServerVmSize
    linuxAppServerVmAdminPassword: vmUserPassword
    Agent_for_Linux_adoAccount: organisationName
    Agent_for_Linux_adoPat: agentPat
    Agent_for_Linux_adoPool: agentPool
    Agent_for_Linux_agentName: linuxAppServerVmName
    Agent_vstsPassword: agentPat
    Agent_poolName: agentPool
    Agent_windowsLogonPassword: vmUserPassword
    windowsClientVmName: windowsClientVmName
    windowsClientVmImageOffer: windowsClientImageOffer
    windowsClientVmImageSku: windowsClientImageSku
    windowsClientVmSize: windowsClientVmSize
    windowsClientVmAdminPassword: vmUserPassword
    windowsClientVmCount: windowsClientVmCount

  }
  scope: rg
}

output LAB_ID string = lab.outputs.labId
output LAB_APPLICATION_SERVER_VM_NAME string = lab.outputs.linuxAppServerVmName
output LAB_APPLICATION_SERVER_VM_ID string = lab.outputs.linuxAppServerVmId
