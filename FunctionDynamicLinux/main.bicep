param location string = resourceGroup().location
param storageName string = 'amancauniquestorage' // must be globally unique
param siteName string = 'amancaBicepFunctionTest'

var storageSku = 'Standard_LRS' // declare variable and assign value
var hostingPlaneName = 'amancaASP'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageName
    location: location
    kind: 'Storage'
    sku: {
        name: storageSku // reference variable
    }
}

resource function 'Microsoft.Web/sites@2019-08-01' = {
    name: siteName
    location: location
    kind: 'functionApp,linux'
    properties: {
        serverFarmId: asp.id
        name: siteName
        siteConfig: {
            appSettings:[
                {
                    name: 'FUNCTIONS_WORKER_RUNTIME'
                    value: 'python'
                }
                {
                    name: 'FUNCTIONS_EXTENSION_VERSION'
                    value: '~2'
                }
                {
                    name: 'AzureWebJobsStorage'
                    value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(stg.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
                }
            ]
        }
    }
}
resource asp 'Microsoft.Web/serverfarms@2019-08-01' = {
    name: hostingPlaneName
    location: location
    kind: 'linux'
    sku:{
        Tier:'dynamic'
        name: 'Y1'
    }
}

output storageId string = stg.id // output resourceId of storage account