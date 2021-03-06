param location string = resourceGroup().location
param storageName string = 'amancauniquestoragetwo' // must be globally unique
param siteName string = 'amancaBicepFunctionTest'
param appInsightsName string = 'amancaInsights'

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
        serverFarmId: asp.id
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
                {
                    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                    value: reference(insights.id).InstrumentationKey
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
        name: 'EP1'
    }
}

resource insights 'Microsoft.insights/components@2018-05-01-preview' = {
    name: appInsightsName
    location: location
    properties: {
        ApplicationId: appInsightsName
        Request_Source: 'IbizaWebAppExtensionCreate'
    }
}

output storageId string = stg.id // output resourceId of storage account