#!/usr/bin/env pwsh

Write-Host "Starting postdeploy..."

# Output environment variables to .env file using azd env get-values
azd env get-values > .env

# Output environment variables to .env file using azd env get-values
azd env get-values >.env
echo "--- ✅ | 1. Post-provisioning - env configured ---"

# Setup to run notebooks
echo 'Installing dependencies from "requirements.txt"'
python -m pip install -r ./src/api/requirements.txt > /dev/null
python -m pip install ipython ipykernel > /dev/null      # Install ipython and ipykernel
ipython kernel install --name=python3 --user > /dev/null # Configure the IPython kernel
jupyter kernelspec list > /dev/null                      # Verify kernelspec list isn't empty
echo "--- ✅ | 2. Post-provisioning - ready execute notebooks ---"

echo "Populating data ...."
jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/customer_info/create-cosmos-db.ipynb > /dev/null
jupyter nbconvert --execute --to python --ExecutePreprocessor.timeout=-1 data/product_info/create-azure-search.ipynb > /dev/null

#echo "--- ✅ | 3. Post-provisioning - populated data ---"
Write-Host "Script execution completed successfully."
