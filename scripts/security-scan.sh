#!/bin/bash
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔒 CoPPA Security Scanner${NC}"
echo "=================================="

# Create results file
SCAN_RESULTS="security-scan-results.txt"
echo "Security Scan Results - $(date)" > "$SCAN_RESULTS"
echo "======================================" >> "$SCAN_RESULTS"
ISSUES_FOUND=0

echo -e "\n${YELLOW}1. Checking for secrets and sensitive data...${NC}"

# Check for common secrets patterns
echo "Scanning for potential secrets..." >> "$SCAN_RESULTS"
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{4,}['\"]"
    "secret\s*=\s*['\"][^'\"]{8,}['\"]" 
    "api[_-]?key\s*=\s*['\"][^'\"]{10,}['\"]"
    "token\s*=\s*['\"][^'\"]{15,}['\"]"
    "access[_-]?token\s*=\s*['\"][^'\"]{15,}['\"]"
    "client[_-]?secret\s*=\s*['\"][^'\"]{15,}['\"]"
    "database[_-]?url\s*=\s*['\"][^'\"]{15,}['\"]"
    "connection[_-]?string\s*=\s*['\"][^'\"]{15,}['\"]"
    "private[_-]?key\s*=\s*['\"][^'\"]{20,}['\"]"
    "-----BEGIN.*PRIVATE.*KEY-----"
    "ssh-rsa\s+[A-Za-z0-9+/]{100,}"
)

SECRET_FOUND=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    # Scan for secrets but exclude compiled assets and common false positives
    if grep -r -i -E "$pattern" \
        . \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=.venv \
        --exclude-dir=venv \
        --exclude-dir=dist \
        --exclude-dir=build \
        --exclude-dir=__pycache__ \
        --exclude-dir=static \
        --exclude-dir=infra \
        --exclude="*.min.js" \
        --exclude="*.bundle.js" \
        --exclude="*.map" \
        --exclude="*.log" \
        --exclude="*.pyc" \
        --exclude="*security*" \
        --exclude="$SCAN_RESULTS" \
        2>/dev/null | \
        grep -v "binary file" | \
        grep -v "secretRef" | \
        grep -v "secretName" | \
        grep -v "SECRET_" | \
        grep -v "SECURITY_" | \
        grep -v "/venv/" | \
        grep -v "/.venv/" | \
        grep -v "site-packages/" | \
        grep -v "__pycache__/" | \
        grep -v "Field(exclude=True)" | \
        grep -v "Field(.*exclude.*True" | \
        grep -v "example" | \
        grep -v "placeholder" | \
        grep -v "passwordCredential" | \
        head -1; then
        echo -e "${RED}⚠️  Potential secret found matching pattern: $pattern${NC}"
        echo "POTENTIAL SECRET: $pattern" >> "$SCAN_RESULTS"
        SECRET_FOUND=true
        ((ISSUES_FOUND++))
    fi
done

if [ "$SECRET_FOUND" = false ]; then
    echo -e "${GREEN}✅ No obvious secrets found in code${NC}"
    echo "✅ No obvious secrets found" >> "$SCAN_RESULTS"
fi

echo -e "\n${YELLOW}2. Checking environment files and configuration...${NC}"

# Check for .env files with credentials
if find . -name "*.env*" -type f 2>/dev/null | grep -v node_modules | head -5; then
    echo -e "${YELLOW}⚠️  Environment files found - ensure they contain no secrets${NC}"
    echo "Environment files detected" >> "$SCAN_RESULTS"
    ((ISSUES_FOUND++))
fi

# Check for suspicious file permissions
echo -e "\n${YELLOW}3. Checking file permissions...${NC}"
find . -type f -perm -002 2>/dev/null | grep -v "\.git" | head -5 | while read -r file; do
    echo -e "${YELLOW}⚠️  World-writable file: $file${NC}"
    echo "World-writable file: $file" >> "$SCAN_RESULTS"
    ((ISSUES_FOUND++))
done

echo -e "\n${YELLOW}4. Security scan complete${NC}"
echo "=================================="
echo "Issues found: $ISSUES_FOUND"
echo "" >> "$SCAN_RESULTS"
echo "Total issues found: $ISSUES_FOUND" >> "$SCAN_RESULTS"

if [ $ISSUES_FOUND -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $ISSUES_FOUND potential security issues found${NC}"
    echo -e "Review the results in: $SCAN_RESULTS"
    exit 1
else
    echo -e "${GREEN}✅ No security issues detected${NC}"
    exit 0
fi
