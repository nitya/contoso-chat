#!/usr/bin/env pwsh

Write-Host "Starting postdeploy..."

# Output environment variables to .env file using azd env get-values
azd env get-values > .env

# Output environment variables to .env file using azd env get-values
azd env get-values >.env
echo "--- ✅ | 1. Post-provisioning - env configured ---"

# Setup to run notebooks
echo 'Installing dependencies from "requirements.txt"'

Get-Content ./src/api/requirements.txt | ForEach-Object {   
     if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {        
        Write-Output "Installing package: $_"        pip install $_    }}
echo "--- ✅ | 2. Post-provisioning - ready execute scripts ---"

echo "Populating data ...."
python data/customer_info/create-cosmos-db.py  > /dev/null
python data/product_info/create-azure-search.py  > /dev/null

#echo "--- ✅ | 3. Post-provisioning - populated data ---"
Write-Host "Script execution completed successfully."
