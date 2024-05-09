#!/bin/sh

# Check if running in GitHub Workspace
if [ -z "$GITHUB_WORKSPACE" ]; then
      echo "Running in a GitHub Workspace"
    # The GITHUB_WORKSPACE is not set, meaning this is not running in a GitHub Action
    DIR=$(dirname "$(realpath "$0")")
#    "$DIR/login.sh"
fi

# Checks if $CODESPACES is defined - if empty, we must be running local.
if [ -z "$EXPIRED_TOKEN" ]; then
    echo "No Azure user signed in. Please login."
    if [ -z "$CODESPACES" ]; then
        echo "Running in Local Env: Use standard login flow."
        az login -o none
    else
        echo "Running in Codespaces: Force device code flow."
        az login --use-device-code
    fi
fi

# Retrieve service names, resource group name, and other values from environment variables
resourceGroupName=$AZURE_RESOURCE_GROUP
searchService=$AZURE_SEARCH_NAME
openAiService=$AZURE_OPENAI_NAME
cosmosService=$AZURE_COSMOS_NAME
subscriptionId=$AZURE_SUBSCRIPTION_ID
mlProjectName=$AZUREAI_PROJECT_NAME

# Ensure all required environment variables are set
if [ -z "$resourceGroupName" ] || [ -z "$searchService" ] || [ -z "$openAiService" ] || [ -z "$cosmosService" ] || [ -z "$subscriptionId" ] || [ -z "$mlProjectName" ]; then
    echo "One or more required environment variables are not set."
    echo "Ensure that AZURE_RESOURCE_GROUP, AZURE_SEARCH_NAME, AZURE_OPENAI_NAME, AZURE_COSMOS_NAME, AZURE_SUBSCRIPTION_ID, and AZUREAI_PROJECT_NAME are set."
    exit 1
fi

# Retrieve the keys
searchKey=$(az search admin-key show --service-name $searchService --resource-group $resourceGroupName --query primaryKey --output tsv)
apiKey=$(az cognitiveservices account keys list --name $openAiService --resource-group $resourceGroupName --query key1 --output tsv)
cosmosKey=$(az cosmosdb keys list --name $cosmosService --resource-group $resourceGroupName --query primaryMasterKey --output tsv)

# Set the environment variables using azd env set
azd env set AZURE_SEARCH_KEY $searchKey
azd env set AZURE_OPENAI_KEY $apiKey
azd env set COSMOS_KEY $cosmosKey
azd env set AZURE_OPENAI_API_VERSION 2023-03-15-preview
azd env set AZURE_OPENAI_CHAT_DEPLOYMENT gpt-35-turbo
azd env set CONTOSO_SEARCH_ENDPOINT $AZURE_SEARCH_ENDPOINT
azd env set CONTOSO_SEARCH_KEY $AZURE_SEARCH_KEY 


# Output environment variables to .env file using azd env get-values
azd env get-values > .env

# NN: Re-added this to support local development notebooks & workshop
# Create config.json with the environment variable values
echo "{\"subscription_id\": \"$subscriptionId\", \"resource_group\": \"$resourceGroupName\", \"workspace_name\": \"$mlProjectName\"}" > config.json

# Run 
echo "Script execution completed successfully."

# Run eval script
#echo "===========> Running eval script next"
#sh "./run-eval.sh"