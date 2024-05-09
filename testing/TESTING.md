## Testing With Flex Flow and Prompty

## Provisioning 

1. Login: `azd auth login`
1. Set environment: `azd env new msbuild-flexflow-test`
1. Provision it: `azd provision`
    - Provide valid subscription
    - Provide valid location (e.g., `swedencentral`)
1. Postprovsion hooks: `azd hooks run postprovision`
1. Deploy: `azd deploy`

> Env vars should have these values

```bash
AZUREAI_HUB_NAME="ai-hub-gcdx#########"
AZUREAI_PROJECT_NAME="ai-project-gcdx#########"
AZURE_CONTAINER_REGISTRY_ENDPOINT="crgcdx#########.azurecr.io"
AZURE_CONTAINER_REGISTRY_NAME="crgcdx#########"
AZURE_COSMOS_NAME="cosmos-gcdx#########"
AZURE_ENV_NAME="msbuild-flexflow-test"
AZURE_KEY_VAULT_ENDPOINT="https://kv-gcdx#########.vault.azure.net/"
AZURE_KEY_VAULT_NAME="kv-gcdx#########"
AZURE_LOCATION="swedencentral"
AZURE_OPENAI_API_VERSION="2023-03-15-preview"
AZURE_OPENAI_CHAT_DEPLOYMENT="gpt-35-turbo"
AZURE_OPENAI_ENDPOINT="https://aoai-gcdx#########.openai.azure.com/"
AZURE_OPENAI_KEY="#########"
AZURE_OPENAI_NAME="aoai-gcdx#########"
AZURE_RESOURCE_GROUP="rg-#########"
AZURE_SEARCH_ENDPOINT="https://srch-gcdx#########.search.windows.net/"
AZURE_SEARCH_KEY="#########"
AZURE_SEARCH_NAME="srch-gcdxl#########"
AZURE_SUBSCRIPTION_ID="#########"
AZURE_TENANT_ID="#########"
CONTOSO_SEARCH_ENDPOINT="https://srch-gcdx#########.search.windows.net/"
COSMOS_ENDPOINT="https://cosmos-gcdx#########.documents.azure.com:443/"
COSMOS_KEY="#########"

```

> Errors to fix

1. Post provisioning script errors indicating KEY env vars are not set.
    - Likely cause: `az` authentication did not succeed so the relevant `az` commands to retrieve keys failed
    - Likely cause: `login.sh` script prevents az runs in GitHub Codespaces - try this in Docker Desktop or manually step through commands
1. 

## Azure test

Use `{"question": "Tell me about hiking shoes", "customerId": "2", "chat_history": []}` as test question

> Errors to fix

1. Get this error
    ```bash
    [2024-05-09 13:46:58,245][flowinvoker][INFO] - Validating flow input with data {'question': 'Tell me about hiking shoes', 'customerId': '2', 'chat_history': []}
    [2024-05-09 13:46:58,245][flowinvoker][INFO] - Execute flow with data {'question': 'Tell me about hiking shoes', 'customerId': '2', 'chat_history': []}
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout> inputs:
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout>  
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout> 2
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout>  
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout> Tell me about hiking shoes
    2024-05-09 13:46:58 +0000      22 execution.flow     INFO     [Flex in line None (index starts from 0)] stdout> Error retrieving customer: 'COSMOS_ENDPOINT'
    [2024-05-09 13:46:58,249][flowinvoker][ERROR] - Flow run failed with error: {'message': "Execution failure in 'get_response': (KeyError) 'AZURE_EMBEDDING_NAME'", 'messageFormat': "Execution failure in '{func_name}': {error_type_and_message}", 'messageParameters': {'func_name': 'get_response', 'error_type_and_message': "(KeyError) 'AZURE_EMBEDDING_NAME'"}, ....
    ```


## Local test with Provisioned environment

1. Complete steps 1-4 above.
1. Validate environment variables
    ```bash
    ```
1. Explore prompts locally
    ```bash
    pf flow test --flow ./contoso-chat --inputs question="Tell me about your backpacks" chat_history=[] customerId="2"
    ```
1. Test flow locally
    ```bash
    pf flow test --flow ./contoso-chat --inputs question="Tell me about your backpacks" chat_history=[] customerId="2" --ui
    ```
1. Deploy flow with pf
    ```bash
    ```
1. Test flow locally
1. Test flow locally