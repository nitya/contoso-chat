#!/usr/bin/env pwsh

Write-Host "Starting postdeploy..."

# Output environment variables to .env file using azd env get-values
azd env get-values > .env
# python -m pip install azure-identity azure-search-documents openai python-dotenv pandas
python create-azure-search.py
python create-cosmos-db.py

Write-Host "Script execution completed successfully."
