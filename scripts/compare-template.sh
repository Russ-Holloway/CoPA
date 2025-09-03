#!/bin/bash
# Compare ARM Template Changes
# Shows what changed between versions

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
TEMPLATE_FILE="infrastructure/deployment.json"

echo -e "${GREEN}🔄 ARM Template Change Analysis${NC}"
echo -e "Template: ${YELLOW}${TEMPLATE_FILE}${NC}"
echo ""

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Get the last commit version
echo -e "${GREEN}📊 Comparing with previous version...${NC}"

# Show recent commits
echo -e "${BLUE}Recent commits:${NC}"
git log --oneline -5 | sed 's/^/   /'

echo ""

# Compare with HEAD~1 (previous commit)
if git show HEAD~1:$TEMPLATE_FILE > /tmp/previous-template.json 2>/dev/null; then
    echo -e "${GREEN}🔍 Changes since last commit:${NC}"
    
    # Resource count comparison
    OLD_COUNT=$(jq '.resources | length' /tmp/previous-template.json 2>/dev/null || echo "0")
    NEW_COUNT=$(jq '.resources | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
    
    echo -e "   📦 Resources: ${BLUE}$OLD_COUNT${NC} → ${BLUE}$NEW_COUNT${NC}"
    
    if [ "$NEW_COUNT" -gt "$OLD_COUNT" ]; then
        DIFF=$((NEW_COUNT - OLD_COUNT))
        echo -e "   ✅ Added ${GREEN}+$DIFF${NC} resources"
    elif [ "$NEW_COUNT" -lt "$OLD_COUNT" ]; then
        DIFF=$((OLD_COUNT - NEW_COUNT))
        echo -e "   🗑️  Removed ${RED}-$DIFF${NC} resources"
    else
        echo -e "   ➡️  Same number of resources"
    fi
    
    # Parameter comparison
    OLD_PARAMS=$(jq '.parameters | length' /tmp/previous-template.json 2>/dev/null || echo "0")
    NEW_PARAMS=$(jq '.parameters | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
    
    echo -e "   ⚙️  Parameters: ${BLUE}$OLD_PARAMS${NC} → ${BLUE}$NEW_PARAMS${NC}"
    
    # Variable comparison
    OLD_VARS=$(jq '.variables | length' /tmp/previous-template.json 2>/dev/null || echo "0")
    NEW_VARS=$(jq '.variables | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
    
    echo -e "   🔧 Variables: ${BLUE}$OLD_VARS${NC} → ${BLUE}$NEW_VARS${NC}"
    
    # Check for specific storage changes
    echo -e "${GREEN}🗄️  Storage Container Changes:${NC}"
    
    OLD_CONTAINERS=$(jq '[.resources[] | select(.type == "Microsoft.Storage/storageAccounts/blobServices/containers")] | length' /tmp/previous-template.json 2>/dev/null || echo "0")
    NEW_CONTAINERS=$(jq '[.resources[] | select(.type == "Microsoft.Storage/storageAccounts/blobServices/containers")] | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
    
    echo -e "   📦 Container resources: ${BLUE}$OLD_CONTAINERS${NC} → ${BLUE}$NEW_CONTAINERS${NC}"
    
    if [ "$NEW_CONTAINERS" -gt "$OLD_CONTAINERS" ]; then
        echo -e "   ✅ New storage containers added!"
        
        # Show container names
        jq -r '.resources[] | select(.type == "Microsoft.Storage/storageAccounts/blobServices/containers") | "      📁 " + .name' "$TEMPLATE_FILE" 2>/dev/null | while read container; do
            echo -e "   $container"
        done
    fi
    
    # Show git diff summary
    echo -e "${GREEN}📝 Git Diff Summary:${NC}"
    git diff --stat HEAD~1 "$TEMPLATE_FILE" | sed 's/^/   /'
    
    rm -f /tmp/previous-template.json
    
else
    echo -e "${YELLOW}⚠️  No previous version found to compare${NC}"
fi

# Compare with milestone tag if it exists
if git tag -l "v1.0.0-deployment-success" >/dev/null 2>&1; then
    echo ""
    echo -e "${GREEN}🏷️  Comparing with milestone (v1.0.0-deployment-success):${NC}"
    
    if git show v1.0.0-deployment-success:$TEMPLATE_FILE > /tmp/milestone-template.json 2>/dev/null; then
        MILESTONE_COUNT=$(jq '.resources | length' /tmp/milestone-template.json 2>/dev/null || echo "0")
        CURRENT_COUNT=$(jq '.resources | length' "$TEMPLATE_FILE" 2>/dev/null || echo "0")
        
        echo -e "   📦 Resources since milestone: ${BLUE}$MILESTONE_COUNT${NC} → ${BLUE}$CURRENT_COUNT${NC}"
        
        if [ "$CURRENT_COUNT" -gt "$MILESTONE_COUNT" ]; then
            DIFF=$((CURRENT_COUNT - MILESTONE_COUNT))
            echo -e "   ✅ Added ${GREEN}+$DIFF${NC} resources since milestone"
        fi
        
        rm -f /tmp/milestone-template.json
    fi
fi

echo ""
echo -e "${GREEN}✅ Change analysis complete!${NC}"
echo -e "${BLUE}💡 This helps you see what changed before deployment${NC}"
