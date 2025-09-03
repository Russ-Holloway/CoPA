#!/bin/bash
# Analyze ARM Template Structure Locally
# No Azure login required!

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

echo -e "${GREEN}🔍 ARM Template Structure Analysis${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo -e "Parameters: ${YELLOW}${PARAMETERS_FILE}${NC}"
echo ""

# 1. Count resources
echo -e "${GREEN}📊 Resource Count Analysis${NC}"
RESOURCE_COUNT=$(jq '.resources | length' "$TEMPLATE_FILE")
echo -e "   📦 Total Resources: ${BLUE}$RESOURCE_COUNT${NC}"

# 2. List resource types
echo -e "${GREEN}🏗️  Resource Types${NC}"
jq -r '.resources[] | .type' "$TEMPLATE_FILE" | sort | uniq -c | sort -nr | while read count type; do
    echo -e "   ${BLUE}$count${NC}x ${YELLOW}$type${NC}"
done

# 3. Storage containers analysis
echo -e "${GREEN}🗄️  Storage Container Analysis${NC}"
STORAGE_RESOURCES=$(jq -r '.resources[] | select(.type == "Microsoft.Storage/storageAccounts") | .name' "$TEMPLATE_FILE" 2>/dev/null || echo "")
if [ -n "$STORAGE_RESOURCES" ]; then
    echo -e "   ✅ Storage account found"
    
    # Check for nested container resources
    CONTAINER_COUNT=$(jq '[.resources[] | select(.type == "Microsoft.Storage/storageAccounts/blobServices/containers")] | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
    echo -e "   📦 Container resources: ${BLUE}$CONTAINER_COUNT${NC}"
    
    if [ "$CONTAINER_COUNT" -gt 0 ]; then
        echo -e "   🔍 Container details:"
        jq -r '.resources[] | select(.type == "Microsoft.Storage/storageAccounts/blobServices/containers") | "      📁 " + .name + " (access: " + .properties.publicAccess + ")"' "$TEMPLATE_FILE" 2>/dev/null || echo "      ❌ Could not parse container details"
    fi
else
    echo -e "   ${RED}❌ No storage account found${NC}"
fi

# 4. Parameter analysis
echo -e "${GREEN}⚙️  Parameter Analysis${NC}"
if [ -f "$PARAMETERS_FILE" ]; then
    echo -e "   🔍 Checking for new storage container parameters..."
    
    AI_LIBRARY=$(jq -r '.parameters.AILibraryContainerName.value // "not set"' "$PARAMETERS_FILE")
    WEB_LOGOS=$(jq -r '.parameters.WebAppLogosContainerName.value // "not set"' "$PARAMETERS_FILE")
    
    echo -e "   📁 AI Library Container: ${BLUE}$AI_LIBRARY${NC}"
    echo -e "   📁 Web App Logos Container: ${BLUE}$WEB_LOGOS${NC}"
    
    if [ "$AI_LIBRARY" != "not set" ] && [ "$WEB_LOGOS" != "not set" ]; then
        echo -e "   ✅ New storage containers configured!"
    fi
fi

# 5. Variables analysis
echo -e "${GREEN}🔧 Variables Analysis${NC}"
VARIABLE_COUNT=$(jq '.variables | length' "$TEMPLATE_FILE")
echo -e "   📋 Total Variables: ${BLUE}$VARIABLE_COUNT${NC}"

# Check for storage-related variables
STORAGE_VARS=$(jq -r '.variables | to_entries[] | select(.key | contains("Storage") or contains("Container")) | .key' "$TEMPLATE_FILE" 2>/dev/null || echo "")
if [ -n "$STORAGE_VARS" ]; then
    echo -e "   🗄️  Storage-related variables:"
    echo "$STORAGE_VARS" | while read var; do
        echo -e "      🔧 ${YELLOW}$var${NC}"
    done
fi

# 6. Output analysis
echo -e "${GREEN}📤 Output Analysis${NC}"
if jq -e '.outputs' "$TEMPLATE_FILE" >/dev/null 2>&1; then
    OUTPUT_COUNT=$(jq '.outputs | length' "$TEMPLATE_FILE")
    echo -e "   📋 Total Outputs: ${BLUE}$OUTPUT_COUNT${NC}"
    
    echo -e "   🔍 Output variables:"
    jq -r '.outputs | to_entries[] | "      📤 " + .key + " (" + .value.type + ")"' "$TEMPLATE_FILE" 2>/dev/null || echo "      ❌ Could not parse outputs"
else
    echo -e "   ${YELLOW}⚠️  No outputs defined${NC}"
fi

# 7. Dependencies check
echo -e "${GREEN}🔗 Dependencies Analysis${NC}"
RESOURCES_WITH_DEPS=$(jq '.resources[] | select(.dependsOn != null) | .name' "$TEMPLATE_FILE" 2>/dev/null | wc -l || echo "0")
echo -e "   🔗 Resources with dependencies: ${BLUE}$RESOURCES_WITH_DEPS${NC}"

echo ""
echo -e "${GREEN}✅ Structure analysis complete!${NC}"
echo -e "${BLUE}💡 This analysis works completely offline${NC}"
echo -e "${BLUE}💡 Use this to verify your template structure before deployment${NC}"
