# Instructor TODOs

1. Capture steps to be taken to complete this lab over here as you go.
1. These will be added into the "guide" docs at the right places.
1. Once done, they can be removed from here.

---

## Working with Skillable

> **Launch a new private browser before navigating to portals** - this will minimize conflicts


1. Launch their VM (ignore onscreen instructions for now - we will update)
1. Visit [Azure Portal](https://portal.azure.com) - use Skillable credentials
    - Visit Resource Groups (should see rg-AITOUR) - click for details
    - Verify **Deployments** shows _35 succeeded_ - else wait (its provisioning)
1. Visit [Azure AI Foundry Portal](https://ai.azure.com)
    - "Sign in" should just work - uses previous auth credential
    - Verify you have a single project - click for details
    - Check "Models + Deployments" - should have gpt-4o & gpt-4o-mini
1. Click "Tracing" - should be activated
1. Click "Evaluations" - should be ready for new evaluation
1. Click "Overview" - should have required environment variables.

---

## Using Contoso Chat

> **The [learner instructions](https://microsoft.github.io/aitour-build-a-copilot-on-azure-ai/2-Workshop/01-Setup/2-Provisioning/02-Skillable/#31-azure-cli-login) will be updated later**. For now these are instructor focused.

1. Navigate to [Contoso-Chat working branch](https://github.com/nitya/contoso-chat/tree/msbuild25-lab334-refactor) - launch Codespaces
1. Wait till ready - then `az login --use-device-code` to authenticate with Azure
1. Run: `azd auth login --use-device-code` - to authenticate with Azure Developer CLI
1. Run: `azd env set AZURE_LOCATION eastus2 -e AITOUR --no-prompt` - creates `.azure/`
1. Run: `azd env refresh -e AITOUR` - populates `.azure/AITOUR/.env`

Your Codespaces environment now has the environment variables needed to work with Contoso Chat. But we need to do 2 more things:

1. Run: `bash ./docs/workshop/src/0-setup/azd-update-roles.sh` - set user RBAC 
1. Run: `azd hooks run postdeploy` - upload data, copy .env to root

You can now visit the Container Apps endpoint in the Azure Portal, visit the `/docs` route on that service to get the Swagger UI for testing our chatbot ("Try it out")
1. question: "tell me about your tents"
1. customer id: 1
1. chat_history: []
1. Response should start "Hey John!..."

You are now ready to switch to the [build25-lab334 notebooks](./../build25-lab334/notebooks/README.md) folder to take steps specific to evaluation setup.


---

## Tasks To Do

- [ ] Add `docs/build-lab334/requirements.txt` to devcontainer
- [ ] Create prebuild for specific branch
- [ ] Update Skillable instructions to use prebuild branch
- [ ] Update Contoso setup to use EastUS2
- [ ] Update Contoso setup to run Lab334 requirements.txt
- [ ] Search index needs to support keys for use in manual eval
- [ ] Copy model-specific EP for convenience for now