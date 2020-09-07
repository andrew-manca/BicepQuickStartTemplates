param location string = resourceGroup().location
param storageName string = 'amancauniquestoragetwo' // must be globally unique
param siteName string = 'amancaBicepFunctionTest'

var storageSku = 'Standard_LRS' // declare variable and assign value
var hostingPlaneName = 'amancaASPWindows'

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
    kind: 'functionApp'
    properties: {
        name: siteName
        siteConfig: {
            appSettings:[
                {
                    name: 'FUNCTIONS_WORKER_RUNTIME'
                    value: 'dotnet'
                }
                {
                    name: 'FUNCTIONS_EXTENSION_VERSION'
                    value: '~2'
                }
                {
                    name: 'AzureWebJobsStorage'
                    value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(stg.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
                }
                {
                    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
                    value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(stg.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
                }
                {
                    name: 'WEBSITE_CONTENTSHARE'
                    value: toLower(siteName)
                }
            ]
        }
    }
}
resource asp 'Microsoft.Web/serverfarms@2019-08-01' = {
    name: hostingPlaneName
    location: location
    sku:{
        Tier:'dynamic'
        name: 'Y1'
    }
}

output storageId string = stg.id // output resourceId of storage account