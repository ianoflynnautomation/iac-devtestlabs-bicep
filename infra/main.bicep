targetScope = 'subscription'

param location string
@minLength(1)
@maxLength(64)
param environmentName string
param deploymentType string = 'on-prem'
param windowsClientVmCount int = 2

var tags = {
  'azd-env-name': environmentName
}
var labName = 'devtestlab01'
var labsDeploymentName = 'lab-deploy'

resource kv 'Microsoft.KeyVault/vaults@2023-05-01' existing = {
  name: 'kv-test-terraform'
  scope: resourceGroup('test-terraform-rg')
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
    environmentName: environmentName
    deploymentType: deploymentType
    windowsClientVmCount: windowsClientVmCount
    adoAccountName: kv.getSecret('ADO-ACCOUNT-NAME')
    adoPatToken: kv.getSecret('ADO-PAT-TOKEN')
    adoPoolName: kv.getSecret('ADO-POOL-NAME')
    windowsClientVmAdminPassword: 'P@ssw0rd1234'
    linuxAppServerVmAdminPassword: 'P@ssw0rd1234'
    // windowsClientVmAdminPassword: kv.getSecret('WINDOWS-CLIENT-VM-ADMIN-PASSWORD')
    // linuxAppServerVmAdminPassword: kv.getSecret('LINUX-APP-SERVER-VM-ADMIN-PASSWORD')
    tags: tags

  }
  scope: rg
}

output LAB_ID string = lab.outputs.labId
output LAB_APPLICATION_SERVER_VM_NAME string = lab.outputs.linuxAppServerVmName
output LAB_APPLICATION_SERVER_VM_ID string = lab.outputs.linuxAppServerVmId
