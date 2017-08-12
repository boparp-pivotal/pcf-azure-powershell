param
(
    [string]$resourceGroup,
    [string]$location,
    [string]$deploymentStorageAccountNameRoot,
    [string]$deploymentStorageAccountCount
)

$DebugPreference = 'SilentlyContinue'

function Create-DeploymentStorageContainers {
    [CmdletBinding()]
    param 
    (
       [string]$resourceGroup,
       [string]$deploymentStorageAccountNameRoot,
       [string]$deploymentStorageAccountCount
    )
    for ($i=1; $i -le $deploymentStorageAccountCount; $i++) {
        Write-Verbose 'Creating Containers inside ***** '
        $acct = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -StorageAccountName $deploymentStorageAccountNameRoot$i
        New-AzureStorageContainer -Name stemcell -Context $acct.Context
        New-AzureStorageContainer -Name bosh -Context $acct.Context 
    }
}



function Create-NetworkAssets {

    [CmdletBinding()]
    param 
    (
        [string]$resourceGroup,
        [string]$location
    )

    # nsg rule
    $nsgRuleInternetToLB = New-AzureRmNetworkSecurityRuleConfig -Name internet-to-lb  -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange * -Access Allow

    #nsg
    $nsgInternetToLB = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name 'pcf-nsg' -SecurityRules $nsgRuleInternetToLB
}


# Call the function to create Containers inside the Deployment Storage Accounts.
Create-DeploymentStorageContainers -resourceGroup $resourceGroup -deploymentStorageAccountNameRoot $deploymentStorageAccountNameRoot -deploymentStorageAccountCount $deploymentStorageAccountCount

# Call the function to create the Network Security Group and its Rule
Create-NetworkAssets -resourceGroup $resourceGroup -location $location

$DebugPreference = "SilentlyContinue"
