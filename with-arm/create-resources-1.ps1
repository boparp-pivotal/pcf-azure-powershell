param
(
    [string]$resourceGroup,
    [string]$location,
    [string]$storageSKU,
    [string]$boshStorageAccountName,
    [string]$ops_mgr_vhd_pivnet_url
)

$DebugPreference = 'SilentlyContinue'

function New-Storage-Assets {

    [CmdletBinding()]
    param 
    (
        [string]$resourceGroup,
        [string]$location,
        [hashtable]$opts
    )

    $boshAcct = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -AccountName $boshStorageAccountName -Location $location -SkuName $opts.storageSKU -Kind "Storage"
    New-AzureStorageContainer -Name stemcell -Context $boshAcct.Context -Permission Blob
    New-AzureStorageContainer -Name opsmanager -Context $boshAcct.Context 
    New-AzureStorageContainer -Name bosh -Context $boshAcct.Context 
    New-AzureStorageContainer -Name opsman-image -Context $boshAcct.Context 
    New-AzureStorageContainer -Name vhds -Context $boshAcct.Context 
    New-AzureStorageTable -Name stemcells -Context $boshAcct.Context
    
    Start-AzureStorageBlobCopy -AbsoluteUri $opts.ops_mgr_vhd_pivnet_url -DestBlob 'image.vhd' -DestContainer 'opsman-image' -DestContext $boshAcct.Context -Verbose
    
    Write-Verbose 'Copying VHD - this will take about 10 minutes.'
    do {
        Start-Sleep -s 30
        $status = Get-AzureStorageBlobCopyState -Blob image.vhd -Container 'opsman-image' -Context $boshAcct.context -Verbose
        Write-Verbose 'Copying...'
    } until ($status.Status -eq 'Success')
}

# fail fast if storage names are not globally unique
if (-not ((Get-AzureRmStorageAccountNameAvailability -Name $boshStorageAccountName).NameAvailable)) {
    Write-Host "Not all storage names are available."
    return
}

# test if the resource group name is available and if not, create it
$ErrorActionPreference = 'SilentlyContinue'
$testRg = Get-AzureRmResourceGroup -name $resourceGroup
if ($testRg -eq $Null) {
    New-AzureRmResourceGroup -Name $resourceGroup -Location $location
}
$ErrorActionPreference = 'Continue'

$storageOptions = @{}
$storageOptions.storageSKU = $storageSKU
$storageOptions.boshStorageAccountName = $boshStorageAccountName
$storageOptions.deploymentStorageAccountNameRoot = $deploymentStorageAccountNameRoot
$storageOptions.deploymentStorageAccountCount = $deploymentStorageAccountCount
$storageOptions.ops_mgr_vhd_pivnet_url = $ops_mgr_vhd_pivnet_url
$storageOptions.storageDomain = $storageDomain

New-Storage-Assets -resourceGroup $resourceGroup -location $location -opts $storageOptions 

$DebugPreference = "SilentlyContinue"
