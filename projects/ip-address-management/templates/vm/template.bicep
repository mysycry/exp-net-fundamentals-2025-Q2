// Core configuration
param location string = resourceGroup().location
param vmName string
param vmSize string = 'Standard_B2s'
param adminUsername string
@secure()
param adminPassword string

// Network configuration
param vnetName string = '${vmName}-vnet'
param subnetName string = 'default'
param nsgName string = '${vmName}-nsg'
param nicName string = '${vmName}-nic'
param pipName string = '${vmName}-pip'

// Network settings with defaults
param addressPrefixes array = ['10.0.0.0/16']
param subnets array = [
  {
    name: subnetName
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]
param nsgRules array = [
  {
    name: 'RDP'
    properties: {
      priority: 1000
      protocol: 'Tcp'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]

// Storage and security defaults
param osDiskType string = 'Premium_LRS'
param publicIpSku string = 'Standard'
param deleteOptionsEnabled bool = true
param securityType string = 'TrustedLaunch'
param secureBoot bool = true
param vTPM bool = true

// Windows Update settings
param patchMode string = 'AutomaticByPlatform'
param enableHotpatching bool = false
param rebootSetting string = 'IfRequired'

// Public IP
resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: pipName
  location: location
  sku: { name: publicIpSku }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgRules
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: addressPrefixes }
    subnets: subnets
  }
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: '${vnet.id}/subnets/${subnetName}' }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { 
            id: pip.id
            properties: deleteOptionsEnabled ? { deleteOption: 'Delete' } : {}
          }
        }
      }
    ]
    networkSecurityGroup: { id: nsg.id }
  }
}

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: osDiskType }
        deleteOption: deleteOptionsEnabled ? 'Delete' : 'Detach'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
    }
    
    networkProfile: {
      networkInterfaces: [{
        id: nic.id
        properties: deleteOptionsEnabled ? { deleteOption: 'Delete' } : {}
      }]
    }
    
    securityProfile: {
      securityType: securityType
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
    }
    
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: patchMode
          assessmentMode: 'ImageDefault'
          enableHotpatching: enableHotpatching
          automaticByPlatformSettings: {
            rebootSetting: rebootSetting
          }
        }
      }
    }
    
    diagnosticsProfile: {
      bootDiagnostics: { enabled: true }
    }
  }
}

// Outputs
output vmName string = vm.name
output publicIpAddress string = pip.properties.ipAddress
output adminUsername string = adminUsername
