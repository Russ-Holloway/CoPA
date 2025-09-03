#!/bin/bash
# Incremental ARM Template Deployment
# Deploy only specific resources or updates without recreating everything

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="rg-btp-uks-prod-ai-coppa-automation-test"
TEMPLATE_FILE="infrastructure/deployment.json"
PARAMETERS_FILE="infrastructure/deployment.parameters.json"

echo -e "${GREEN}🔄 Incremental ARM Template Deployment${NC}"
echo -e "Resource Group: ${YELLOW}${RESOURCE_GROUP}${NC}"
echo -e "Mode: ${BLUE}Incremental (only changes applied)${NC}"
echo ""

# Check if resource group exists
echo -e "${GREEN}📋 Checking resource group...${NC}"
if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo -e "✅ Resource group exists"
else
    echo -e "${YELLOW}⚠️  Resource group doesn't exist. Creating it...${NC}"
    az group create --name "$RESOURCE_GROUP" --location "uksouth"
    echo -e "✅ Resource group created"
fi

# Run incremental deployment
echo -e "${GREEN}🚀 Starting incremental deployment...${NC}"
echo -e "${YELLOW}This will only apply changes/additions, not recreate existing resources${NC}"
echo ""

DEPLOYMENT_NAME="coppa-incremental-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$TEMPLATE_FILE" \
    --parameters @"$PARAMETERS_FILE" \
    --mode Incremental \
    --name "$DEPLOYMENT_NAME" \
    --verbose

echo ""
echo -e "${GREEN}✅ Incremental deployment complete!${NC}"
echo -e "${BLUE}Deployment name: ${DEPLOYMENT_NAME}${NC}"

# Show what was deployed
echo ""
echo -e "${GREEN}📊 Checking deployment status...${NC}"
az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.{ProvisioningState:provisioningState,Timestamp:timestamp,Duration:duration}" \
    --output table
