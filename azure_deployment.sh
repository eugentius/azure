#!/bin/bash

resourceGroupName=$1

echo "Creating resource group ${resourceGroupName}"
az group create --name ${resourceGroupName} --location westeurope

echo "Creating a Storage Account"
az group deployment create \
  --name storageAccount \
  --resource-group ${resourceGroupName} \
  --template-file arm-templates/storageAccount.json

echo "Get mygridustorageacct key"
STORAGEKEY=$(az storage account keys list \
    --resource-group "${resourceGroupName}" \
    --account-name mygridustorageacct \
    --query "[0].value" | tr -d '"')

echo "Creating a file share on mygridustorageacct"
az storage share create --name myshare \
    --quota 100 \
    --account-name mygridustorageacct \
    --account-key $STORAGEKEY


echo "Creating other resources"
az group deployment create \
  --name mainTemplateDeplyment \
  --resource-group ${resourceGroupName} \
  --template-file arm-templates/mainTemplate.json \
  --parameters @arm-templates/parameters.json \
  --parameters STORAGEKEY=$STORAGEKEY
