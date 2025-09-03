#!/bin/bash
# Quick ARM Template What-If Analysis
# This shows you what changes would be made WITHOUT actually deploying

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="rg-btp-uks-dev-ai-coppa-test"
TEMPLATE_FILE="infrastructure/deployment.json"
PARAMETERS_FILE="infrastructure/deployment.dev.parameters.json"

echo -e "${GREEN}🔍 ARM Template What-If Analysis${NC}"
echo -e "Resource Group: ${YELLOW}${RESOURCE_GROUP}${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo ""

# Check if resource group exists
echo -e "${GREEN}📋 Checking resource group...${NC}"
if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo -e "✅ Resource group exists"
else
    echo -e "${RED}❌ Resource group does not exist${NC}"
    exit 1
fi

# Run what-if analysis
echo -e "${GREEN}🎯 Running What-If analysis...${NC}"
echo -e "${YELLOW}This will show what changes would be made without actually deploying${NC}"
echo ""

az deployment group what-if \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$TEMPLATE_FILE" \
    --parameters @"$PARAMETERS_FILE" \
    --result-format FullResourcePayloads

echo ""
echo -e "${GREEN}✅ What-If analysis complete!${NC}"
echo -e "${YELLOW}💡 No actual changes were made. Run deploy.sh to apply changes.${NC}"
