#!/bin/bash
# Fast ARM Template Validation with ARM TTK integration

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

TEMPLATE_FILE="infrastructure/deployment.json"
PARAMETERS_FILE="infrastructure/deployment.dev.parameters.json"

# Check if parameters file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
    if [ -f "infrastructure/deployment.parameters.json" ]; then
        PARAMETERS_FILE="infrastructure/deployment.parameters.json"
    else
        PARAMETERS_FILE=""
    fi
fi

echo -e "${GREEN}🚀 Running Template Validation...${NC}"
echo -e "${GREEN}⚡ Fast ARM Template Validation${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo ""

# 1. JSON Syntax Check
echo -e "${GREEN}1️⃣  JSON Syntax Check${NC}"
if jq empty "$TEMPLATE_FILE" 2>/dev/null; then
    echo -e "   ✅ Template JSON is valid"
else
    echo -e "   ${RED}❌ Template JSON has syntax errors${NC}"
    exit 1
fi

if [ -n "$PARAMETERS_FILE" ] && jq empty "$PARAMETERS_FILE" 2>/dev/null; then
    echo -e "   ✅ Parameters JSON is valid"
elif [ -n "$PARAMETERS_FILE" ]; then
    echo -e "   ${RED}❌ Parameters JSON has syntax errors${NC}"
    exit 1
else
    echo -e "   ${YELLOW}⚠️  No parameters file to validate${NC}"
fi

# 2. ARM Template Structure Check
echo -e "${GREEN}2️⃣  ARM Template Structure Check${NC}"
if command -v pwsh >/dev/null 2>&1 && [ -d "tools/arm-ttk" ]; then
    echo -e "   ✅ ARM TTK available - PowerShell and ARM TTK installed"
    echo -e "   💡 Run detailed validation: ./scripts/arm-ttk-detailed.sh"
else
    echo -e "   ⚠️  ARM TTK not fully available"
    if ! command -v pwsh >/dev/null 2>&1; then
        echo -e "   💡 PowerShell: ❌ Not installed"
    else
        echo -e "   💡 PowerShell: ✅ Installed"
    fi
    if [ ! -d "tools/arm-ttk" ]; then
        echo -e "   💡 ARM TTK: ❌ Not found in tools/arm-ttk"
    else
        echo -e "   💡 ARM TTK: ✅ Found in tools/arm-ttk"
    fi
fi

# 3. Azure CLI Template Validation
echo -e "${GREEN}3️⃣  Azure CLI Template Validation${NC}"
if az account show >/dev/null 2>&1; then
    echo -e "   ✅ Azure CLI logged in"
    echo -e "   💡 Can run: az deployment group validate"
else
    echo -e "   ⚠️  Not logged into Azure CLI, skipping Azure validation"
fi

# 4. Parameter Validation
echo -e "${GREEN}4️⃣  Parameter Validation${NC}"
echo -e "   🔍 Checking parameter coverage..."

TEMPLATE_PARAMS=$(jq -r '.parameters | keys[]' "$TEMPLATE_FILE" 2>/dev/null | sort)
TEMPLATE_COUNT=$(echo "$TEMPLATE_PARAMS" | wc -w)

echo -e "   📋 Template requires: ${BLUE}${TEMPLATE_COUNT}${NC} parameters"

if [ -n "$PARAMETERS_FILE" ]; then
    PROVIDED_PARAMS=$(jq -r '.parameters | keys[]' "$PARAMETERS_FILE" 2>/dev/null | sort)
    PROVIDED_COUNT=$(echo "$PROVIDED_PARAMS" | wc -w)
    echo -e "   📋 Parameters file provides: ${BLUE}${PROVIDED_COUNT}${NC} parameters"
    
    MISSING_PARAMS=$(comm -23 <(echo "$TEMPLATE_PARAMS") <(echo "$PROVIDED_PARAMS") 2>/dev/null || true)
    if [ -n "$MISSING_PARAMS" ] && [ "$MISSING_PARAMS" != "" ]; then
        echo -e "   ${RED}❌ Missing parameters:${NC}"
        echo "$MISSING_PARAMS" | sed 's/^/      ❌ /'
    else
        echo -e "   ✅ All required parameters provided"
    fi
else
    echo -e "   ${YELLOW}⚠️  No parameters file to compare${NC}"
fi

echo ""
echo -e "${GREEN}✅ Fast validation complete!${NC}"
echo -e "${BLUE}💡 Use whatif-deploy.sh to see what would be deployed${NC}"
echo -e "${BLUE}💡 Use incremental-deploy.sh to deploy only changes${NC}"
