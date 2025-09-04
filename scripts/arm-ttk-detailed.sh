#!/bin/bash
# Detailed ARM TTK Validation Report
# Provides comprehensive ARM Template Toolkit validation results

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
TEMPLATE_FILE="infrastructure/deployment.json"

echo -e "${GREEN}🔍 Detailed ARM TTK Validation Report${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo ""

if ! command -v pwsh >/dev/null 2>&1; then
    echo -e "${RED}❌ PowerShell not installed${NC}"
    echo -e "   💡 PowerShell is required for ARM TTK"
    exit 1
fi

if [ ! -d "tools/arm-ttk" ]; then
    echo -e "${RED}❌ ARM TTK not found${NC}"
    echo -e "   💡 ARM TTK should be in tools/arm-ttk directory"
    exit 1
fi

# Run full ARM TTK validation
echo -e "${GREEN}🔧 Running comprehensive ARM TTK validation...${NC}"
echo ""

pwsh -c "
Import-Module ./tools/arm-ttk/arm-ttk/arm-ttk.psd1
Test-AzTemplate -TemplatePath ./$TEMPLATE_FILE
"

echo ""
echo -e "${GREEN}✅ ARM TTK validation complete!${NC}"
echo -e "${BLUE}💡 Review the results above for recommendations${NC}"
