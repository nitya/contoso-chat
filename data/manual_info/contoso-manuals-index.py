#!/usr/bin/env python
# coding: utf-8

# In[ ]:


get_ipython().run_line_magic('pip', 'install azure-ai-generative[evaluate,index,prompty]==1.0.0b3')


# In[ ]:


import os
from azure.ai.resources.client import AIClient
from azure.ai.resources.operations._index_data_source import (
    LocalSource,
    ACSOutputConfig,
)
from azure.ai.generative.index import build_index
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

load_dotenv()

contoso_search = os.environ["SEARCH_SERVICE"]
index_name = "contoso-manuals-index"

os.environ["OPENAI_API_TYPE"] = "azure"
os.environ["OPENAI_API_BASE"] = os.environ["AZURE_OPENAI_ENDPOINT"]
openai_deployment = "text-embedding-ada-002"

path_to_data = "./manuals"


# In[ ]:





# In[ ]:


# Set up environment variables for cog search SDK
os.environ["AZURE_AI_SEARCH_ENDPOINT"] = contoso_search

client = AIClient.from_config(credential = DefaultAzureCredential())

# Use the same index name when registering the index in AI Foundry
index = build_index(
    output_index_name=index_name,
    vector_store="azure_cognitive_search",
    embeddings_model=f"azure_open_ai://deployment/{openai_deployment}/model/{openai_deployment}",
    data_source_url="/products",
    index_input_config=LocalSource(input_data=path_to_data),
    acs_config=ACSOutputConfig(
        acs_index_name=index_name,
    ),
)


# In[ ]:


# register the index so that it shows up in the project
cloud_index = client.indexes.create_or_update(index)

print(f"Created index '{cloud_index.name}'")
print(f"Local Path: {index.path}")
print(f"Cloud Path: {cloud_index.path}")


# In[ ]:


get_ipython().run_line_magic('pip', 'uninstall azure-ai-generative[evaluate,index,prompty]==1.0.0b3 -y')


# In[ ]:


get_ipython().run_line_magic('pip', 'install azure-search-documents==11.4.0')

