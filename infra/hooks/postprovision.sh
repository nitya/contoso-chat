#!/bin/bash

# Output environment variables to .env file using azd env get-values
azd env get-values >.env

echo "--- ✅ | 1. Post-deploy - nothing to do ---"