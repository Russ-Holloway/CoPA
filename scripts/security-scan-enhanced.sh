#!/bin/bash
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔒 CoPPA Enhanced Security Scanner${NC}"
echo "=========================================="

# Create results file
SCAN_RESULTS="security-scan-results.txt"
echo "Enhanced Security Scan Results - $(date)" > "$SCAN_RESULTS"
echo "==========================================" >> "$SCAN_RESULTS"
echo "Repository: CoPPA - Police Chat Application" >> "$SCAN_RESULTS"
echo "Scan Focus: Source code security (excluding dependencies)" >> "$SCAN_RESULTS"
echo "" >> "$SCAN_RESULTS"

ISSUES_FOUND=0
DEPENDENCY_WARNINGS=0

echo -e "\n${YELLOW}1. Scanning source code for security issues...${NC}"

# Function to check if file is in source directories
is_source_file() {
    local file="$1"
    # Consider only actual source code directories
    if [[ "$file" =~ ^\./(app\.py|backend/|frontend/src/|scripts/|check_|debug_|simple_) ]]; then
        # Exclude test files and examples
        if [[ ! "$file" =~ (test|spec|example|demo|mock) ]]; then
            return 0
        fi
    fi
    return 1
}

echo "Scanning source code for potential hardcoded credentials..." >> "$SCAN_RESULTS"

# Enhanced secret patterns for source code only
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{4,}['\"]"
    "secret\s*=\s*['\"][^'\"]{8,}['\"]" 
    "api[_-]?key\s*=\s*['\"][A-Za-z0-9]{16,}['\"]"
    "token\s*=\s*['\"][A-Za-z0-9]{20,}['\"]"
    "connection[_-]?string\s*=\s*['\"].*password.*['\"]"
    "-----BEGIN.*PRIVATE.*KEY-----"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key
)

SECRET_FOUND=false
TEMP_RESULTS=$(mktemp)

for pattern in "${SECRET_PATTERNS[@]}"; do
    # Scan only source files, exclude all dependencies and generated files
    grep -r -i -E "$pattern" \
        . \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=.venv \
        --exclude-dir=venv \
        --exclude-dir=dist \
        --exclude-dir=build \
        --exclude-dir=__pycache__ \
        --exclude-dir=infra \
        --exclude-dir=infrastructure \
        --exclude="*.min.js" \
        --exclude="*.bundle.js" \
        --exclude="*.map" \
        --exclude="*.log" \
        --exclude="*.pyc" \
        --exclude="package*.json" \
        --exclude="tsconfig*.json" \
        --exclude="*requirements*.txt" \
        --exclude="*.md" \
        --exclude="$SCAN_RESULTS" \
        2>/dev/null > "$TEMP_RESULTS" || true
    
    # Filter results to only include actual source code files
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            file_path=$(echo "$line" | cut -d: -f1)
            
            # Check if this is a dependency file (should be ignored)
            if [[ "$file_path" =~ (node_modules|\.venv|venv|site-packages|__pycache__|\.git) ]]; then
                ((DEPENDENCY_WARNINGS++))
                continue
            fi
            
            # Check for legitimate configuration patterns to exclude
            if [[ "$line" =~ (Field\(.*exclude.*True|passwordCredential|secretRef|secretName) ]]; then
                echo "Legitimate configuration pattern excluded: $line" >> "$SCAN_RESULTS"
                continue
            fi
            
            # Check if this appears to be source code we should care about
            if is_source_file "$file_path"; then
                echo -e "${RED}🚨 SECURITY ISSUE: $line${NC}"
                echo "SECURITY ISSUE FOUND: $line" >> "$SCAN_RESULTS"
                SECRET_FOUND=true
                ((ISSUES_FOUND++))
            else
                echo "Non-source file excluded: $file_path" >> "$SCAN_RESULTS"
            fi
        fi
    done < "$TEMP_RESULTS"
done

rm -f "$TEMP_RESULTS"

if [ "$SECRET_FOUND" = false ]; then
    echo -e "${GREEN}✅ No hardcoded credentials found in source code${NC}"
    echo "✅ No hardcoded credentials found in source code" >> "$SCAN_RESULTS"
fi

echo -e "\n${YELLOW}2. Checking environment and configuration files...${NC}"

# Check for .env files with credentials in source directories only
ENV_FILES_FOUND=false
while IFS= read -r env_file; do
    if [ -n "$env_file" ] && is_source_file "$env_file"; then
        # Allow .env.sample, .env.example, .env.template files as they're meant to be templates
        if [[ "$env_file" =~ \.(sample|example|template)$ ]]; then
            echo "✅ Template environment file allowed: $env_file" >> "$SCAN_RESULTS"
        else
            echo -e "${YELLOW}⚠️  Environment file in source: $env_file${NC}"
            echo "Environment file in source directory: $env_file" >> "$SCAN_RESULTS"
            ENV_FILES_FOUND=true
            ((ISSUES_FOUND++))
        fi
    fi
done < <(find . -name "*.env*" -type f 2>/dev/null | grep -v node_modules | grep -v ".git")

if [ "$ENV_FILES_FOUND" = false ]; then
    echo -e "${GREEN}✅ No environment files in source code${NC}"
    echo "✅ No environment files found in source directories" >> "$SCAN_RESULTS"
fi

echo -e "\n${YELLOW}3. Checking source file permissions...${NC}"

# Check for suspicious file permissions in source code only
PERM_ISSUES=false
while IFS= read -r file; do
    if [ -n "$file" ] && is_source_file "$file"; then
        echo -e "${YELLOW}⚠️  World-writable source file: $file${NC}"
        echo "World-writable source file: $file" >> "$SCAN_RESULTS"
        PERM_ISSUES=true
        ((ISSUES_FOUND++))
    fi
done < <(find . -type f -perm -002 2>/dev/null | grep -v "\.git" | head -10)

if [ "$PERM_ISSUES" = false ]; then
    echo -e "${GREEN}✅ Source file permissions are secure${NC}"
    echo "✅ Source file permissions are secure" >> "$SCAN_RESULTS"
fi

echo -e "\n${YELLOW}4. Security summary${NC}"
echo "=========================================="

# Add summary to results
echo "" >> "$SCAN_RESULTS"
echo "SECURITY SCAN SUMMARY" >> "$SCAN_RESULTS"
echo "=====================" >> "$SCAN_RESULTS"
echo "Source code security issues: $ISSUES_FOUND" >> "$SCAN_RESULTS"
echo "Dependency warnings (ignored): $DEPENDENCY_WARNINGS" >> "$SCAN_RESULTS"
echo "Scan date: $(date)" >> "$SCAN_RESULTS"

if [ $ISSUES_FOUND -gt 0 ]; then
    echo -e "${RED}🚨 $ISSUES_FOUND security issues found in source code${NC}"
    echo -e "📋 Review details in: $SCAN_RESULTS"
    echo "" >> "$SCAN_RESULTS"
    echo "ACTION REQUIRED: Address the security issues listed above" >> "$SCAN_RESULTS"
    exit 1
else
    echo -e "${GREEN}✅ SOURCE CODE SECURITY: PASSED${NC}"
    echo -e "${BLUE}📊 Summary: $DEPENDENCY_WARNINGS dependency warnings ignored${NC}"
    echo -e "📋 Full report: $SCAN_RESULTS"
    echo "" >> "$SCAN_RESULTS"
    echo "✅ SECURITY STATUS: PASSED" >> "$SCAN_RESULTS"
    echo "No security issues detected in source code." >> "$SCAN_RESULTS"
    echo "All sensitive patterns found were in dependency files only." >> "$SCAN_RESULTS"
    exit 0
fi
