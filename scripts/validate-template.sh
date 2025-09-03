#!/bin/bash
# Fast ARM Template Validation
# Quickly validate template syntax and parameters without deployment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
TEMPLATE_FILE="infrastructure/deployment.json"
PARAMETERS_FILE="infrastructure/deployment.dev.parameters.json"

# Check if parameters file exists, if not try alternatives
if [ ! -f "$PARAMETERS_FILE" ]; then
    if [ -f "infrastructure/deployment.parameters.json" ]; then
        PARAMETERS_FILE="infrastructure/deployment.parameters.json"
    elif [ -f "infrastructure/parameters-pds.json" ]; then
        PARAMETERS_FILE="infrastructure/parameters-pds.json"
    else
        echo -e "${YELLOW}⚠️  No parameters file found. Skipping parameter validation.${NC}"
        PARAMETERS_FILE=""
    fi
fi

echo -e "${GREEN}⚡ Fast ARM Template Validation${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo ""

# 1. JSON Syntax Validation
echo -e "${GREEN}1️⃣  JSON Syntax Check${NC}"
if jq empty "$TEMPLATE_FILE" 2>/dev/null; then
    echo -e "   ✅ Template JSON is valid"
else
    echo -e "   ${RED}❌ Template JSON has syntax errors${NC}"
    jq empty "$TEMPLATE_FILE"
    exit 1
fi

if jq empty "$PARAMETERS_FILE" 2>/dev/null && [ -n "$PARAMETERS_FILE" ]; then
    echo -e "   ✅ Parameters JSON is valid"
else
    if [ -n "$PARAMETERS_FILE" ]; then
        echo -e "   ${RED}❌ Parameters JSON has syntax errors${NC}"
        jq empty "$PARAMETERS_FILE"
        exit 1
    else
        echo -e "   ${YELLOW}⚠️  No parameters file to validate${NC}"
    fi
fi

# 2. ARM Template Lint
echo -e "${GREEN}2️⃣  ARM Template Structure Check${NC}"
if command -v arm-ttk >/dev/null 2>&1; then
    echo -e "   🔍 Running ARM TTK validation..."
    arm-ttk -TemplatePath "$TEMPLATE_FILE"
else
    echo -e "   ${YELLOW}⚠️  ARM TTK not installed, skipping detailed validation${NC}"
    echo -e "   💡 Install with: npm install -g arm-ttk"
fi

# 3. Azure CLI Validation
echo -e "${GREEN}3️⃣  Azure CLI Template Validation${NC}"
if az account show >/dev/null 2>&1; then
    echo -e "   🔍 Validating with Azure CLI..."
    
    # Create a temporary resource group for validation if needed
    TEMP_RG="temp-validation-$(date +%s)"
    
    # Validate template
    if [ -n "$PARAMETERS_FILE" ]; then
        if az deployment group validate \
            --resource-group "$TEMP_RG" \
            --template-file "$TEMPLATE_FILE" \
            --parameters @"$PARAMETERS_FILE" \
            --no-prompt 2>/dev/null; then
            echo -e "   ✅ Template validation passed"
        else
            echo -e "   ${RED}❌ Template validation failed${NC}"
            echo -e "   🔍 Running validation with details..."
            az deployment group validate \
                --resource-group "$TEMP_RG" \
                --template-file "$TEMPLATE_FILE" \
                --parameters @"$PARAMETERS_FILE" \
                --no-prompt
        fi
    else
        echo -e "   ${YELLOW}⚠️  Skipping Azure validation (no parameters file)${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Not logged into Azure CLI, skipping Azure validation${NC}"
fi

# 4. Quick Parameter Check
echo -e "${GREEN}4️⃣  Parameter Validation${NC}"
echo -e "   🔍 Checking parameter coverage..."

TEMPLATE_PARAMS=$(jq -r '.parameters | keys[]' "$TEMPLATE_FILE" 2>/dev/null | sort)
if [ -n "$PARAMETERS_FILE" ]; then
    PROVIDED_PARAMS=$(jq -r '.parameters | keys[]' "$PARAMETERS_FILE" 2>/dev/null | sort)
else
    PROVIDED_PARAMS=""
fi

echo -e "   📋 Template requires: ${BLUE}$(echo $TEMPLATE_PARAMS | wc -w)${NC} parameters"
if [ -n "$PARAMETERS_FILE" ]; then
    echo -e "   📋 Parameters file provides: ${BLUE}$(echo $PROVIDED_PARAMS | wc -w)${NC} parameters"
    
    # Check for missing parameters
    MISSING_PARAMS=$(comm -23 <(echo "$TEMPLATE_PARAMS") <(echo "$PROVIDED_PARAMS") 2>/dev/null || true)
    if [ -n "$MISSING_PARAMS" ]; then
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
