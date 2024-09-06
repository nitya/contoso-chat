# Part 0: Provision Infrastructure

For instructor-guided sessions, the infrastructure will have been pre-provisioned for you (learners). You can skip ahead to the next section to **Get Started**.

Continue here only if you are a self-guided learner or a workshop organizer setting up the workshop resources for your session. For workshops with multiple users, each participant will need an Azure account - so you will need to follow these instructions once for each one.


## 1. Resource Requirements

The workshop requires these resources to be provisioned:
- Azure AI hub resource
- Azure AI project resource
- Azure AI search resource - the product index
- Azure CosmosDB resource - the customer database
- Azure Open AI resource - the model deployments
   - `text-embedding-ada-002` = for embeddings
   - `gpt-35-turbo` = for chat completion
   - `gpt-4` = for chat evaluation
- Azure Application insights - for monitoring

**TODO**: _Provide links to cost and pricing options for resources_.

## 2. Setup Environment

The project suppports _infrastructure-as-code_ configuration with a Bicep template that can be deployed using the [Azure Developer CLI](https://aka.ms/azd) with a single command. But before we can do this, we need to setup the development environment to run the command.

The project supports _configuration-as-code_ with a `devcontainer.json` file that can be activated with Docker Desktop (local device) or GitHub Codespaces (cloud hosted) to give you a pre-built development container with no added effort.

**We recommend using GitHub Codespaces** for 3 reasons:
 - Gives a quick start with minimal effort
 - Ensures the development environment has latest codebase & tools
 - Ensures all attendees get the same development experience

To get started
 1. Open a browser log into your personal GitHub account.
 1. Fork the [Contoso Chat](https://aka.ms/aitour/contoso-chat) repo - uncheck `main only` to get all branches.
 1. Open your fork and switch to the `aitour-fy25` branch
 1. Click `Code` dropdown, and select `Codespaces` tab.
 1. Click `Create Codespaces on aitour-fy25` to launch a codespace.

This will open a new browser tab with a Visual Studio Code IDE in the browser that already has the codebases loaded in, and has the relevant tools, extensions and libraries installed. **Wait for the loading process to complete** - you should see a VS Code terminal with a live cursor. 

## 3. Connect VS Code to Azure

Since we are running in GitHub Codespaces, we will need to use the `--use-device-code` flag to trigger the authentication flow via the browser. Note that you will need to run both the commands below to ensure both tools are authenticated with Azure.

```bash
# Login with Azure Developer CLI
azd auth login --use-device-code

# Login with Azure CLI
az login --use-device-code
```

## 4. Provision & Deploy with AZD

### 4.1 **Create Azure environment**

First, we'll create an [AZD environment](https://learn.microsoft.com/azure/developer/azure-developer-cli/manage-environment-variables#environment-specific-env-file) called `AITOUR` for our deployment. 

- This creates a _resource group_ (`rg-AITOUR`) and provisions the resources specified in our AZD template to the specified _location_ (region) on Azure. 
- It also creates a local `.azure/AITOUR/` folder to store configuration information locally, with a `.azure\AITOUR\.env` file that will be updated later to reflect Azure environment variables required for local development.

To get started, follow one of these options:

1. Choose a **region** that provides the required resources and in which the subscriptions have sufficient quote available. In the example below, we use the `--location` parameter to select the region **`francecentral`**.

   ```
   azd env new AITOUR --location francecentral --subscription $(az account show --query id --output tsv)
   ```
1. Alternatively try this with `azd` directly. `🚨 TODO:` _See if this works - then we won't need the `az login` step_
   ```
   azd env new AITOUR --location francecentral --subscription $(azd env get-value AZURE_SUBSCRIPTION_ID)
   ```

### 4.2 Provision & Deploy Resources

Once the environment is setup, use the following command to provision Azure infrastructure and deploy relevant resources from the commandline:

```
azd up -e AITOUR --no-prompt
```

Wait for provisioning to complete. This can take 30-40 minutes depending on region and load. 

You can monitor the deployment status via the VS Code terminal (console output) or by visiting the Azure Portal and looking at the `Deployments` page for the `rg-AITOUR` resource group in your subscription.


### 4.3 Troubleshooting

#### 4.3.1 Failed: Key Vault

If you get an error like this:

```
  (x) Failed: Key Vault: kv-ga6xwbwbqulka
```

during `azd up`, it may be because a prior deployment in the same region used the same name, and the key-vault has been soft-deleted but not purged. You will need to purge the keyvault:

```
az keyvault purge -n kv-ga6xwbwbqulka
```

Once the purge completes, run the `azd up` command again.

#### 4.3.2 InvalidTemplateDeployment

You might see a message like this: `InvalidTemplateDeployment: The template deployment 'cognitiveServices' is not valid according to the validation procedure.`

This is typically due to insufficient quota for deploying required models. Either increase available quota and retry - or see if you can release existing quota for reuse.

If you get an error like:

```
FlagMustBeSetForRestore: An existing resource with ID '/subscriptions/<snipped>/resourceGroups/rg-AITOUR/providers/Microsoft.CognitiveServices/accounts/aoai-ga6xwbwbqulka' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first.
```

Purge the resource as follows:
* Go to the portal - search for "Azure AI Service" 
* Select the one with the logo (not the one with the cloud)
* click Manage Deleted Resources
* select the named resource - click purge.

`🚨 TODO:` _See if this works - you should be able to purge with this command, but it has not been validated.

```
az resource delete --ids /subscriptions/265d8bce-3441-475d-8ee1-a1037b8c3eae/resourceGroups/rg-AITOUR/providers/Microsoft.CognitiveServices/accounts/aoai-ga6xwbwbqulka
```


## 5. Validate Environment

The `azd deploy` command should have executed postprovisioning scripts that create two files in your local directory:
 - `config.json`  - capturing your Azure subscription & environment info
 - `.env` - capturing deployment-specific environment variables

These files will be used later for code-first interactions from the local development environment, with our Azure backend.

## 6. Refresh Environment

You may encounter a situation where the deployment is done in one environment (e.g., workshop organizer) and the development is done in another (e.g., learner Codespace) later. We need a way for the _learner_ environment to be retrieve and save the above configuration information from the provisioned infrastructure.

To do this, learner should do the following:

1. Launch GitHub Codespaces to get a development environment from repo
1. `azd auth login --use-device-code` to autenticate with Azure
1. `azd env refresh -e AITOUR` to recreate the `.azure/AITOUR/.env` file 
1. `azd provision` to re-run provision and post-provision steps

Note that since the Azure resources are already provisioned, this last step simply refreshes timestamps then completes post-provisioning to recreate the `.env` and `config.json` files in the new Codespaces environment.

You can now run `azd deploy` on any changes to codebase, to redeploy the application or infrastructure changes as relevant.

`🚨 TODO:` _Verify this works_


## Next step

Congratulations!! You just finished provisioning the Azure infrastructure for developing our Contoso Chat application - and configured your local development environment to work with the Azure backend.

- Continue to [1-GetStarted.md](1-GetStarted.md) to start the workshop experience.
- Don't forget to visit [3-CleanUp.md](3-CleanUp.md) on workshop completion, to delete resources.
