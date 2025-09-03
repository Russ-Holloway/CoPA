#!/bin/bash
# Test specific resources without full deployment
# Useful for testing storage containers, app settings, etc.

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP="rg-btp-uks-prod-ai-coppa-automation-test"
STORAGE_ACCOUNT_NAME="stouksprodaicoppa"

show_usage() {
    echo -e "${GREEN}Usage: $0 <test-type>${NC}"
    echo -e "${YELLOW}Available test types:${NC}"
    echo -e "  ${BLUE}storage${NC}     - Test storage account and containers"
    echo -e "  ${BLUE}webapp${NC}      - Test web app configuration"
    echo -e "  ${BLUE}search${NC}      - Test search service"
    echo -e "  ${BLUE}openai${NC}      - Test OpenAI service"
    echo -e "  ${BLUE}all${NC}         - Test all resources"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 storage"
    echo -e "  $0 webapp"
    echo -e "  $0 all"
}

test_storage() {
    echo -e "${GREEN}🗄️  Testing Storage Account${NC}"
    
    # Check if storage account exists
    if az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
        echo -e "✅ Storage account exists: ${BLUE}$STORAGE_ACCOUNT_NAME${NC}"
        
        # Test containers
        echo -e "${YELLOW}📦 Checking containers...${NC}"
        CONTAINERS=$(az storage container list --account-name "$STORAGE_ACCOUNT_NAME" --query "[].name" --output tsv 2>/dev/null || echo "")
        
        if [ -n "$CONTAINERS" ]; then
            echo -e "✅ Found containers:"
            echo "$CONTAINERS" | while read container; do
                echo -e "   📁 ${BLUE}$container${NC}"
                
                # Check container access level
                ACCESS_LEVEL=$(az storage container show --name "$container" --account-name "$STORAGE_ACCOUNT_NAME" --query "properties.publicAccess" --output tsv 2>/dev/null || echo "none")
                echo -e "      🔒 Access Level: ${YELLOW}$ACCESS_LEVEL${NC}"
            done
        else
            echo -e "${RED}❌ No containers found${NC}"
        fi
    else
        echo -e "${RED}❌ Storage account not found: $STORAGE_ACCOUNT_NAME${NC}"
    fi
}

test_webapp() {
    echo -e "${GREEN}🌐 Testing Web App${NC}"
    
    # Find web apps in resource group
    WEBAPPS=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" --output tsv 2>/dev/null || echo "")
    
    if [ -n "$WEBAPPS" ]; then
        echo "$WEBAPPS" | while read webapp; do
            echo -e "✅ Found web app: ${BLUE}$webapp${NC}"
            
            # Check app settings
            echo -e "${YELLOW}⚙️  Checking app settings...${NC}"
            SETTINGS_COUNT=$(az webapp config appsettings list --name "$webapp" --resource-group "$RESOURCE_GROUP" --query "length(@)" --output tsv 2>/dev/null || echo "0")
            echo -e "   📋 App settings: ${BLUE}$SETTINGS_COUNT${NC} configured"
            
            # Check if app is running
            STATE=$(az webapp show --name "$webapp" --resource-group "$RESOURCE_GROUP" --query "state" --output tsv 2>/dev/null || echo "unknown")
            echo -e "   🔄 State: ${BLUE}$STATE${NC}"
        done
    else
        echo -e "${RED}❌ No web apps found${NC}"
    fi
}

test_search() {
    echo -e "${GREEN}🔍 Testing Search Service${NC}"
    
    # Find search services
    SEARCH_SERVICES=$(az search service list --resource-group "$RESOURCE_GROUP" --query "[].name" --output tsv 2>/dev/null || echo "")
    
    if [ -n "$SEARCH_SERVICES" ]; then
        echo "$SEARCH_SERVICES" | while read service; do
            echo -e "✅ Found search service: ${BLUE}$service${NC}"
            
            # Check status
            STATUS=$(az search service show --name "$service" --resource-group "$RESOURCE_GROUP" --query "status" --output tsv 2>/dev/null || echo "unknown")
            echo -e "   🔄 Status: ${BLUE}$STATUS${NC}"
        done
    else
        echo -e "${RED}❌ No search services found${NC}"
    fi
}

test_openai() {
    echo -e "${GREEN}🤖 Testing OpenAI Service${NC}"
    
    # Find cognitive services (OpenAI)
    OPENAI_SERVICES=$(az cognitiveservices account list --resource-group "$RESOURCE_GROUP" --query "[?kind=='OpenAI'].name" --output tsv 2>/dev/null || echo "")
    
    if [ -n "$OPENAI_SERVICES" ]; then
        echo "$OPENAI_SERVICES" | while read service; do
            echo -e "✅ Found OpenAI service: ${BLUE}$service${NC}"
            
            # Check status
            STATE=$(az cognitiveservices account show --name "$service" --resource-group "$RESOURCE_GROUP" --query "properties.provisioningState" --output tsv 2>/dev/null || echo "unknown")
            echo -e "   🔄 Provisioning State: ${BLUE}$STATE${NC}"
        done
    else
        echo -e "${RED}❌ No OpenAI services found${NC}"
    fi
}

# Main script
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

TEST_TYPE="$1"

echo -e "${GREEN}🧪 Resource-Specific Testing${NC}"
echo -e "Resource Group: ${YELLOW}$RESOURCE_GROUP${NC}"
echo -e "Test Type: ${BLUE}$TEST_TYPE${NC}"
echo ""

case "$TEST_TYPE" in
    storage)
        test_storage
        ;;
    webapp)
        test_webapp
        ;;
    search)
        test_search
        ;;
    openai)
        test_openai
        ;;
    all)
        test_storage
        echo ""
        test_webapp
        echo ""
        test_search
        echo ""
        test_openai
        ;;
    *)
        echo -e "${RED}❌ Unknown test type: $TEST_TYPE${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Testing complete!${NC}"
