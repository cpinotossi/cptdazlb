targetScope='resourceGroup'

//var parameters = json(loadTextContent('parameters.json'))
param location string
var username = 'chpinoto'
var password = 'demo!pass123'
param prefix string
param myobjectid string
param myip string

module hubvnetmodule 'azbicep/bicep/vnethubbasic.bicep' = {
  name: 'hubvnetdeploy'
  params: {
    prefix: prefix
    postfix: 'hub'
    location: location
    cidervnet: '10.0.0.0/16'
    cidersubnet: '10.0.0.0/24'
    ciderbastion: '10.0.1.0/24'
  }
}

module spoke1vnetmodule 'azbicep/bicep/vnetspoke.bicep' = {
  name: 'spoke1vnetdeploy'
  params: {
    prefix: prefix
    postfix: 'spoke1'
    location: location
    cidervnet: '10.1.0.0/16'
    cidersubnet: '10.1.0.0/24'
  }
}

module spoke2vnetmodule 'azbicep/bicep/vnetspoke.bicep' = {
  name: 'spoke2vnetdeploy'
  params: {
    prefix: prefix
    postfix: 'spoke2'
    location: location
    cidervnet: '10.2.0.0/16'
    cidersubnet: '10.2.0.0/24'
    isnatgateway: true
  }
}

module hubvmmodule 'azbicep/bicep/vm.bicep' = {
  name: 'hubvmdeploy'
  params: {
    prefix: prefix
    postfix: 'hubvm'
    vnetname: hubvnetmodule.outputs.vnetname
    location: location
    username: username
    password: password
    myObjectId: myobjectid
    privateip: '10.0.0.4'
    imageRef: 'linux'
    customData: loadTextContent('vmiperf.yaml')
  }
  dependsOn:[
    hubvnetmodule
  ]
}

module spoke1vmmodule 'azbicep/bicep/vm.bicep' = {
  name: 'spoke1vmdeploy'
  params: {
    prefix: prefix
    postfix: 'spoke1'
    vnetname: spoke1vnetmodule.outputs.vnetname
    location: location
    username: username
    password: password
    myObjectId: myobjectid
    privateip: '10.1.0.4'
    imageRef: 'linux'
    customData: loadTextContent('vmiperf.yaml')
  }
  dependsOn:[
    spoke1vnetmodule
  ]
}

module spoke2vmmodule 'azbicep/bicep/vm.bicep' = {
  name: 'spoke2vmdeploy'
  params: {
    prefix: prefix
    postfix: 'spoke2'
    vnetname: spoke2vnetmodule.outputs.vnetname
    location: location
    username: username
    password: password
    myObjectId: myobjectid
    privateip: '10.2.0.4'
    imageRef: 'linux'
    customData: loadTextContent('vmiperf.yaml')
  }
  dependsOn:[
    spoke2vnetmodule
  ]
}

module peering1module 'azbicep/bicep/vpeer.bicep' = {
  name: 'peering1deploy'
  params: {
    vnethubname: hubvnetmodule.outputs.vnetname
    vnetspokename: spoke1vnetmodule.outputs.vnetname
    spokeUseRemoteGateways: false
  }
}

module peering2module 'azbicep/bicep/vpeer.bicep' = {
  name: 'peering2deploy'
  params: {
    vnethubname: hubvnetmodule.outputs.vnetname
    vnetspokename: spoke2vnetmodule.outputs.vnetname
    spokeUseRemoteGateways: false
  }
}

module spoke1lb 'azbicep/bicep/pslb.bicep' = {
  name: 'spoke1lbdeploy'
  params:{
    location:location
    postfix:'spoke1'
    prefix: prefix
    vmip: '10.1.0.4'
  }
}

module spoke2lb 'azbicep/bicep/pslb.bicep' = {
  name: 'spoke2lbdeploy'
  params:{
    location:location
    postfix:'spoke2'
    prefix: prefix
    vmip: '10.2.0.4' 
  }
}
