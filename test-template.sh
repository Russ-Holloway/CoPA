#!/bin/bash

TEMPLATE_FILE="infrastructure/deployment.json"
LOCATION="eastus"

echo "Validating ARM template: $TEMPLATE_FILE"

# Create a validation resource group
VALIDATION_RG="validation-test-rg-$RANDOM"
az group create --name $VALIDATION_RG --location $LOCATION

# Validate the template
echo "Running validation..."
az deployment group validate \
  --resource-group $VALIDATION_RG \
  --template-file $TEMPLATE_FILE \
  --parameters HostingPlanName=test-hosting-plan \
               WebsiteName=test-web-app \
               ApplicationInsightsName=test-app-insights

# Clean up
echo "Cleaning up temporary resource group..."
az group delete --name $VALIDATION_RG --yes --no-wait
