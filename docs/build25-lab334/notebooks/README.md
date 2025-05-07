# Code-First Evaluation with Azure AI Foundry SDKs

This section contains the list of notebooks we want to port over to use in Lab334, to support our narrative. 

## Install Dependencies

This will be done automatically (via devcontainer) later. For now, we'll use the file directly and keep it up to date with any new requirements.

1. Change directories

    ```
    cd docs/build25-lab334
    ```

1. Split the VS Code Terminal to get 2 panes
1. (Pane 1) Run `mkdocs serve` - gets you the guide
1. (Pane 2) Run `pip install -r requirements.txt` - this is our working terminal.

## Environment Variables


Now, let's set up environment variables needed for evaluations notebooks. The codefence block below will be kept updated with any new requirements. **Simply copy this into the bottom of the `.env` file and then fill the values in as specified after. Variables with a ✅ are **required**.

```bash
# Azure Open AI
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_DEPLOYMENT=
AZURE_OPENAI_API_VERSION=
# Azure AI Foundry project
AZURE_AI_CONNECTION_STRING=
AZURE_AI_INFERENCE_ENDPOINT=
# Comparison
AZURE_OPENAI_GPT4_EP=
AZURE_OPENAI_GPT4OMINI_EP=
```

> 🚨 | Contoso Chat uses 'gpt-4o' version that will be retired on Jun 29. **We will update these post MSBuild to move to latest Azure OpenAI models**. For now, we re within expiry dates and Skillable VM is locked.


**These are OpenAI model-centric env variables**

| Env Var | Get Value From |
|:---|:---|
|AZURE_OPENAI_ENDPOINT ✅ | AI Project Overview (API Key) |
|AZURE_OPENAI_API_KEY ✅ |  AI Project Overview > OpenAI Tab (Endpoint) |
|AZURE_OPENAI_DEPLOYMENT ✅ | Pick deployed model name ("gpt-4o-mini")|
|AZURE_OPENAI_API_VERSION ✅ | Look up model details page (code snippet)|
| | |

**These are Azure AI Foundry added env variables**

| Env Var | Get Value From |
|:---|:---|
|AZURE_AI_CONNECTION_STRING  ✅ | AI Project Overview (Project Connection String) |
|AZURE_AI_INFERENCE_ENDPOINT | AI Project Overview > Azure Inference Tab (Endpoint) |
| | |

## EVALUATION NOTEBOOK USAGE

**Many evaluation notebooks look for the following to be defined**
eastus2.api.azureml.ms;0bcab828-911a-4d6e-a39d-92edbc4e2798;rg-aitour;ai-project-51054003

```
azure_ai_project = {
    "subscription_id": "<your-subscription-id>",
    "resource_group_name": "<your-resource-group-name>",
    "project_name": "<your-project-name>",
}
```

We should **NOT** be hardcoding them in notebooks (in case they get checked in after a run). Instead we can derive these directly from the project connection string - which has the form: `region-id;subscription-id;resource-group;project-name`. Try snippets like this:


```python
# Project Connection String
connection_string = os.environ.get("AZURE_AI_CONNECTION_STRING")

# Extract details
region_id, subscription_id, resource_group_name, project_name = connection_string.split(";")

# Populate it
azure_ai_project = {
    "subscription_id": subscription_id,
    "resource_group_name": resource_group_name,
    "project_name": project_name,
}
```

<br/>
<br/>
<br/>

---

## 00 | Validate Setup

In this notebook, we'll explain how to setup your environment variables, install the `azure-ai-evaluation` SDK and try a simple evaluation to validate the local setup works.

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Become familiar with Azure AI Foundry portal
    - Configure local environment variables for code-first use
    - Validate azure-ai-evaluation setup with a simple test


### Code

- [`data.jsonl`](./../notebooks/00-validate-setup/data.jsonl) - {query, truth, answer}
- [quickstart-azureai-sdk.ipynb](./../notebooks/00-validate-setup/quickstart-azureai-sdk.ipynb) - created from [SDK quickstart](https://pypi.org/project/azure-ai-evaluation/) - 15 min 🟠


<br/>

---

## 01 | Select Model

!!! quote "BY COMPLETING THIS LAB YOU SHOULD"

    - Complete your first code-first evaluation
    - Understand the role of datasets in evaluations
    - Understand how evaluations help with model selection

### Code
- [`data.jsonl`](./01-select-model/data.jsonl) - {query, truth, answer}
- [evaluate-base-models.ipynb](./01-select-model/evaluate-base-models.ipynb) created from - [azureai-samples](https://github.com/Azure-Samples/azureai-samples/blob/main/scenarios/evaluate/Supported_Evaluation_Targets/Evaluate_Base_Model_Endpoint/Evaluate_Base_Model_Endpoint.ipynb) - 15 min - 🟠
- [Manually evaluate prompts in the Azure AI Foundry portal playground](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/evaluate-prompts-playground) - 15 min - 🟢

---

## 02 | Simulate Dataset

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD KNOW HOW TO"

    - Use Simulated datasets if you lack real data
    - Use the Simulator to generate context data
    - Use the Simulator to generate adversarial data
    - Run an evaluation with a simulated data set

### Datasets

### Notebooks
 - [simulate-from-searchindex.ipynb](./02-simulate-data/simulate-from-searchindex.ipynb) created from - [azureai-samples](https://github.com/Azure-Samples/azureai-samples/blob/main/scenarios/evaluate/Simulators/Simulate_Context-Relevant_Data/Simulate_From_Azure_Search_Index/Simulate_From_Azure_Search_Index.ipynb) - 15 mins 🔴
 - [simulate-adversarial.ipynb](./02-simulate-data/simulate-adversarial.ipynb) created from - [azureai-samples](https://github.com/Azure-Samples/azureai-samples/tree/main/scenarios/evaluate/Simulators/Simulate_Adversarial_Data) - 15 mins 🔴 

---

## 03 | Evaluate Model

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Thing 1
    - Thing 2
    - Thing 3

### Notebooks

- [ai-judge-quality.ipynb](./03-evaluate-model/ai-judge-quality.ipynb)- from [azureai-samples](https://github.com/Azure-Samples/azureai-samples/blob/main/scenarios/evaluate/Supported_Evaluation_Metrics/AI_Judge_Evaluators_Quality/AI_Judge_Evaluators_Quality.ipynb) - 15 mins 🔴
- [ai-judge-safety.ipynb](./03-evaluate-model/ai-judge-safety.ipynb)- from [azureai-samples](https://github.com/Azure-Samples/azureai-samples/blob/main/scenarios/evaluate/Supported_Evaluation_Metrics/AI_Judge_Evaluators_Safety_Risks/AI_Judge_Evaluators_Safety_Risks_Text.ipynb) - 15 mins 🔴


---

## 04 | Customize Evaluator

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Thing 1
    - Thing 2
    - Thing 3

### Notebooks

- [custom-privacy.ipynb](./04-customize-evaluator/custom-privacy.ipynb)- from [azureai-samples](https://github.com/Azure-Samples/azureai-samples/tree/main/scenarios/evaluate/Supported_Evaluation_Metrics/Custom_Evaluators/Custom_Evaluators_Blocklisting) - 15 mins 🔴

---

<br/>
<br/>

## 05 | Bonus Notebooks


### 5.1 | Red Teaming

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Thing 1
    - Thing 2
    - Thing 3

### Notebooks

---

### 5.2 | Agent Evals

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Thing 1
    - Thing 2
    - Thing 3

### Notebooks

---

### 5.3 | App Evals

!!! quote "BY COMPLETING THIS SECTION YOU SHOULD"

    - Thing 1
    - Thing 2
    - Thing 3

### Notebooks

---