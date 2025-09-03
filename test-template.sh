#!/bin/bash
# CoPPA ARM Template Testing Helper
# Your one-stop tool for testing ARM templates locally

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${GREEN}🛠️  CoPPA ARM Template Testing Helper${NC}"
    echo ""
    echo -e "${YELLOW}Available Commands:${NC}"
    echo -e "  ${BLUE}validate${NC}    - Quick template validation (JSON syntax, parameters)"
    echo -e "  ${BLUE}analyze${NC}     - Detailed template structure analysis"
    echo -e "  ${BLUE}compare${NC}     - Compare with previous versions"
    echo -e "  ${BLUE}test${NC}        - Test deployed resources (requires Azure login)"
    echo -e "  ${BLUE}whatif${NC}      - See what would be deployed (requires Azure login)"
    echo -e "  ${BLUE}deploy${NC}      - Incremental deployment (requires Azure login)"
    echo -e "  ${BLUE}all-local${NC}   - Run all local tests (validate + analyze + compare)"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 validate      # Quick validation"
    echo -e "  $0 all-local     # All local tests"
    echo -e "  $0 analyze       # Structure analysis"
    echo ""
    echo -e "${GREEN}💡 Local tools work without Azure login!${NC}"
}

case "${1:-help}" in
    validate)
        echo -e "${GREEN}🚀 Running Template Validation...${NC}"
        ./scripts/validate-template.sh
        ;;
    analyze)
        echo -e "${GREEN}🚀 Running Template Analysis...${NC}"
        ./scripts/analyze-template.sh
        ;;
    compare)
        echo -e "${GREEN}🚀 Running Template Comparison...${NC}"
        ./scripts/compare-template.sh
        ;;
    test)
        echo -e "${GREEN}🚀 Testing Resources...${NC}"
        ./scripts/test-resources.sh all
        ;;
    whatif)
        echo -e "${GREEN}🚀 Running What-If Analysis...${NC}"
        ./scripts/whatif-deploy.sh
        ;;
    deploy)
        echo -e "${GREEN}🚀 Running Incremental Deployment...${NC}"
        ./scripts/incremental-deploy.sh
        ;;
    all-local)
        echo -e "${GREEN}🚀 Running All Local Tests...${NC}"
        echo ""
        echo -e "${BLUE}=== 1. Template Validation ===${NC}"
        ./scripts/validate-template.sh
        echo ""
        echo -e "${BLUE}=== 2. Template Analysis ===${NC}"
        ./scripts/analyze-template.sh
        echo ""
        echo -e "${BLUE}=== 3. Template Comparison ===${NC}"
        ./scripts/compare-template.sh
        echo ""
        echo -e "${GREEN}✅ All local tests complete!${NC}"
        echo -e "${YELLOW}💡 Use 'whatif' and 'deploy' commands when you have Azure access${NC}"
        ;;
    help|*)
        show_help
        ;;
esac
