#!/usr/bin/env pwsh

Write-Host "Starting postprovisioning..."

# Retrieve service names, resource group name, and other values from environment variables
$resourceGroupName = $env:AZURE_RESOURCE_GROUP
Write-Host "resourceGroupName: $resourceGroupName"

$openAiService = $env:AZURE_OPENAI_NAME
Write-Host "openAiService: $openAiService"

$subscriptionId = $env:AZURE_SUBSCRIPTION_ID
Write-Host "subscriptionId: $subscriptionId"

$cosmosService = $env:AZURE_COSMOS_NAME
Write-Host "cosmosServiceName: $cosmosService"

$cosmosService = $env:COSMOS_ENDPOINT
Write-Host "cosmosServiceEndpoint: $cosmosService"

$azureSearchEndpoint = $env:AZURE_SEARCH_ENDPOINT
Write-Host "azureSearchEndpoint: $azureSearchEndpoint"

# Ensure all required environment variables are set
if ([string]::IsNullOrEmpty($resourceGroupName) -or [string]::IsNullOrEmpty($openAiService) -or [string]::IsNullOrEmpty($subscriptionId)) {
    Write-Host "One or more required environment variables are not set."
    Write-Host "Ensure that AZURE_RESOURCE_GROUP, AZURE_OPENAI_NAME, AZURE_SUBSCRIPTION_ID are set."
    exit 1
}

# Set additional environment variables expected by app 
# --- Removed these since they are already set in azd env refresh ---
# azd env set AZURE_OPENAI_API_VERSION $AZURE_OPENAI_API_VERSION # 2023-03-15-preview
# azd env set AZURE_OPENAI_CHAT_DEPLOYMENT AZURE_OPENAI_API_VERSION # gpt-35-turbo
# azd env set AZURE_SEARCH_ENDPOINT $AZURE_SEARCH_ENDPOINT

# Output environment variables to .env file using azd env get-values
azd env get-values > .env
Write-Host "Script execution completed successfully."

Write-Host 'Installing dependencies from "requirements.txt"'
#python -m pip install -r ./src/api/requirements.txt > $null

# Install one by one (so error does not cause exit from all)
Get-Content ./src/api/requirements.txt | ForEach-Object {    if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {        Write-Output "Installing package: $_"        pip install $_    }}

# populate data
Write-Host "Populating data ...."
cd data/customer_info/
python create-cosmos-db.py
cd ../product_info
python create-azure-search.py

#jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/customer_info/create-cosmos-db.ipynb > $null
#jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/product_info/create-azure-search.ipynb > $null