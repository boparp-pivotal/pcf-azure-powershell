# PowerShell script for PCF without ARM template
This PowerShell script will create all the necessary resources in Azure and launch an Ops Manager without an ARM template

This script is equivalent of all the Azure CLI commands listed [here](http://docs.pivotal.io/pivotalcf/customizing/azure-om-deploy.html)

Unlike the page above where all the Azure CLI commands are listed step by step, this PowerShell script creates all the resources in one shot. 

## How to run this script
Here are the steps 

### 1. Login to your Azure account 
Open your PowerShell window and run this command to log into your Azure account
**_Login-AzureRmAccount_**

### 2. Download the scripts
Download _create-resources.ps1_ and _cd_ into the folder where you downloaded the scripts

### 3. Run the PowerShell script
Run the script as below passing the 10 parameters. 

Below mentioned command is an example. Make sure you change all the parameter values in bold.

.\create-resources.ps1 -resourceGroup **my_pcf_rg** -location **westus** -storageSKU **Standard_LRS** -boshStorageAccountName **myboshstorageacct** -deploymentStorageAccountNameRoot **mydeploystorageacct** -deploymentStorageAccountCount **5** -ops_mgr_vhd_pivnet_url **"https://opsmanagerwestus.blob.core.windows.net/images/ops-manager-1.10.4.vhd"** -ssh_key_path **"C:/pcf/id_rsa.pub"** -vmName **ops-manager** -environment **AzurePublicCloud**
