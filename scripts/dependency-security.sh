#!/bin/bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔒 Dependency Security Scanner${NC}"
echo "==============================="

ISSUES_FOUND=0
SCAN_DATE=$(date)
REPORT_FILE="dependency-security-report.md"

# Initialize report
cat > "$REPORT_FILE" << EOF
# Dependency Security Report

**Generated:** $SCAN_DATE  
**Repository:** CoPPA  
**Scanner:** dependency-security.sh

## Summary

EOF

echo -e "\n${YELLOW}1. Scanning Python dependencies...${NC}"

if [ -f "requirements.txt" ]; then
    echo "📦 Analyzing Python packages in requirements.txt"
    
    # Install/update safety if not present
    if ! command -v safety >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Installing safety for Python vulnerability scanning...${NC}"
        pip install safety >/dev/null 2>&1 || {
            echo -e "${RED}❌ Failed to install safety${NC}"
            echo "⚠️ Python safety scan skipped - installation failed" >> "$REPORT_FILE"
        }
    fi
    
    if command -v safety >/dev/null 2>&1; then
        echo "🔍 Running safety check..."
        
        # Run safety check and capture output
        if safety check --json --output safety-results.json 2>/dev/null; then
            VULNS=$(cat safety-results.json 2>/dev/null | jq length 2>/dev/null || echo "0")
            
            if [ "$VULNS" -gt 0 ]; then
                echo -e "${RED}❌ Found $VULNS known vulnerabilities in Python packages${NC}"
                echo "## Python Dependencies - ❌ VULNERABILITIES FOUND" >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
                echo "**Vulnerabilities found:** $VULNS" >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
                
                # Add detailed vulnerability info
                safety check --output text >> "$REPORT_FILE" 2>&1 || true
                ((ISSUES_FOUND++))
            else
                echo -e "${GREEN}✅ No known vulnerabilities found in Python packages${NC}"
                echo "## Python Dependencies - ✅ SECURE" >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
                echo "No known vulnerabilities found in Python packages." >> "$REPORT_FILE"
            fi
        else
            echo -e "${YELLOW}⚠️  Safety check failed${NC}"
            echo "## Python Dependencies - ⚠️ CHECK FAILED" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "Safety check could not be completed." >> "$REPORT_FILE"
        fi
        
        # Cleanup
        rm -f safety-results.json
    fi
    
    # Check for outdated packages
    echo "🔍 Checking for outdated Python packages..."
    OUTDATED_PACKAGES=$(pip list --outdated --format=json 2>/dev/null | jq length 2>/dev/null || echo "0")
    
    if [ "$OUTDATED_PACKAGES" -gt 0 ]; then
        echo -e "${YELLOW}📊 Found $OUTDATED_PACKAGES outdated Python packages${NC}"
        echo "" >> "$REPORT_FILE"
        echo "### Outdated Python Packages" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "Found $OUTDATED_PACKAGES outdated packages:" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        pip list --outdated --format=columns >> "$REPORT_FILE" 2>/dev/null || echo "Could not retrieve outdated packages list" >> "$REPORT_FILE"
    fi
else
    echo -e "${YELLOW}⚠️  No requirements.txt found${NC}"
    echo "## Python Dependencies - ⚠️ NO REQUIREMENTS FILE" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

echo -e "\n${YELLOW}2. Scanning Node.js dependencies...${NC}"

if [ -f "frontend/package.json" ] || [ -f "package.json" ]; then
    PACKAGE_DIR="."
    [ -f "frontend/package.json" ] && PACKAGE_DIR="frontend"
    
    echo "📦 Analyzing Node.js packages in $PACKAGE_DIR/package.json"
    
    cd "$PACKAGE_DIR"
    
    # Check if npm audit is available
    if command -v npm >/dev/null 2>&1; then
        echo "🔍 Running npm audit..."
        
        if npm audit --audit-level=moderate --json > npm-audit.json 2>/dev/null; then
            VULNERABILITIES=$(cat npm-audit.json | jq '.metadata.vulnerabilities.total' 2>/dev/null || echo "0")
            
            if [ "$VULNERABILITIES" -gt 0 ]; then
                echo -e "${RED}❌ Found $VULNERABILITIES vulnerabilities in Node.js packages${NC}"
                echo "## Node.js Dependencies - ❌ VULNERABILITIES FOUND" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                echo "**Vulnerabilities found:** $VULNERABILITIES" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                
                # Add severity breakdown
                HIGH=$(cat npm-audit.json | jq '.metadata.vulnerabilities.high' 2>/dev/null || echo "0")
                MODERATE=$(cat npm-audit.json | jq '.metadata.vulnerabilities.moderate' 2>/dev/null || echo "0")
                LOW=$(cat npm-audit.json | jq '.metadata.vulnerabilities.low' 2>/dev/null || echo "0")
                
                echo "- High: $HIGH" >> "../$REPORT_FILE"
                echo "- Moderate: $MODERATE" >> "../$REPORT_FILE"
                echo "- Low: $LOW" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                
                # Add detailed audit
                npm audit >> "../$REPORT_FILE" 2>&1 || true
                ((ISSUES_FOUND++))
            else
                echo -e "${GREEN}✅ No vulnerabilities found in Node.js packages${NC}"
                echo "## Node.js Dependencies - ✅ SECURE" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                echo "No known vulnerabilities found in Node.js packages." >> "../$REPORT_FILE"
            fi
        else
            echo -e "${YELLOW}⚠️  npm audit failed${NC}"
            echo "## Node.js Dependencies - ⚠️ AUDIT FAILED" >> "../$REPORT_FILE"
            echo "" >> "../$REPORT_FILE"
            echo "npm audit could not be completed." >> "../$REPORT_FILE"
        fi
        
        rm -f npm-audit.json
        
        # Check for outdated packages
        echo "🔍 Checking for outdated Node.js packages..."
        if npm outdated --json > npm-outdated.json 2>/dev/null; then
            OUTDATED_COUNT=$(cat npm-outdated.json | jq 'keys | length' 2>/dev/null || echo "0")
            if [ "$OUTDATED_COUNT" -gt 0 ]; then
                echo -e "${YELLOW}📊 Found $OUTDATED_COUNT outdated Node.js packages${NC}"
                echo "" >> "../$REPORT_FILE"
                echo "### Outdated Node.js Packages" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                echo "Found $OUTDATED_COUNT outdated packages:" >> "../$REPORT_FILE"
                echo "" >> "../$REPORT_FILE"
                npm outdated >> "../$REPORT_FILE" 2>/dev/null || echo "Could not retrieve outdated packages list" >> "../$REPORT_FILE"
            fi
        fi
        
        rm -f npm-outdated.json
    else
        echo -e "${YELLOW}⚠️  npm not available${NC}"
        echo "## Node.js Dependencies - ⚠️ NPM NOT AVAILABLE" >> "../$REPORT_FILE"
    fi
    
    cd - >/dev/null
else
    echo -e "${YELLOW}⚠️  No package.json found${NC}"
    echo "## Node.js Dependencies - ⚠️ NO PACKAGE FILE" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

echo -e "\n${YELLOW}3. Checking license compatibility...${NC}"

echo "## License Compliance" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check Python package licenses
if command -v pip-licenses >/dev/null 2>&1 || pip install pip-licenses >/dev/null 2>&1; then
    echo "🔍 Checking Python package licenses..."
    echo "### Python Package Licenses" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Get licenses and check for problematic ones
    PROBLEMATIC_LICENSES=("GPL-3.0" "AGPL" "SSPL" "Commons Clause")
    pip-licenses --format=json > python-licenses.json 2>/dev/null || echo "[]" > python-licenses.json
    
    for license in "${PROBLEMATIC_LICENSES[@]}"; do
        if cat python-licenses.json | jq -r '.[].License' | grep -i "$license" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Found potentially problematic license: $license${NC}"
            echo "⚠️ Potentially problematic license found: $license" >> "$REPORT_FILE"
        fi
    done
    
    pip-licenses --format=markdown >> "$REPORT_FILE" 2>/dev/null || echo "Could not generate license report" >> "$REPORT_FILE"
    rm -f python-licenses.json
else
    echo -e "${YELLOW}⚠️  pip-licenses not available${NC}"
    echo "Python license check not available" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

echo -e "\n${YELLOW}4. Scanning for known malicious packages...${NC}"

echo "## Malicious Package Check" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# List of known malicious package patterns
MALICIOUS_PATTERNS=(
    "bitcoin-miner"
    "crypto-miner" 
    "cryptojacker"
    "password-stealer"
    "keylogger"
    "backdoor"
)

MALICIOUS_FOUND=false

# Check Python requirements
if [ -f "requirements.txt" ]; then
    for pattern in "${MALICIOUS_PATTERNS[@]}"; do
        if grep -i "$pattern" requirements.txt >/dev/null 2>&1; then
            echo -e "${RED}❌ Potentially malicious package pattern found: $pattern${NC}"
            echo "❌ Potentially malicious package: $pattern" >> "$REPORT_FILE"
            MALICIOUS_FOUND=true
            ((ISSUES_FOUND++))
        fi
    done
fi

# Check Node.js packages
if [ -f "package.json" ] || [ -f "frontend/package.json" ]; then
    for file in "package.json" "frontend/package.json"; do
        if [ -f "$file" ]; then
            for pattern in "${MALICIOUS_PATTERNS[@]}"; do
                if grep -i "$pattern" "$file" >/dev/null 2>&1; then
                    echo -e "${RED}❌ Potentially malicious package pattern found in $file: $pattern${NC}"
                    echo "❌ Potentially malicious package in $file: $pattern" >> "$REPORT_FILE"
                    MALICIOUS_FOUND=true
                    ((ISSUES_FOUND++))
                fi
            done
        fi
    done
fi

if [ "$MALICIOUS_FOUND" = false ]; then
    echo -e "${GREEN}✅ No known malicious package patterns found${NC}"
    echo "✅ No known malicious package patterns detected" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

echo -e "\n${YELLOW}5. Generating security recommendations...${NC}"

echo "## Security Recommendations" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Generate recommendations based on findings
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "### ✅ Good Security Posture" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "No critical security issues found in dependencies. Consider:" >> "$REPORT_FILE"
    echo "- Regular dependency updates" >> "$REPORT_FILE"
    echo "- Automated security scanning in CI/CD" >> "$REPORT_FILE"
    echo "- Dependency pinning for production" >> "$REPORT_FILE"
else
    echo "### ⚠️ Action Required" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "$ISSUES_FOUND security issues found. Recommended actions:" >> "$REPORT_FILE"
    echo "- Update vulnerable packages immediately" >> "$REPORT_FILE"
    echo "- Review and test updates in staging environment" >> "$REPORT_FILE"
    echo "- Consider alternative packages for high-risk dependencies" >> "$REPORT_FILE"
    echo "- Implement dependency scanning in CI/CD pipeline" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "### Automated Tools Setup" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Consider setting up these automated tools:" >> "$REPORT_FILE"
echo "- **Dependabot/Renovate:** Automated dependency updates" >> "$REPORT_FILE"
echo "- **Snyk/WhiteSource:** Continuous dependency monitoring" >> "$REPORT_FILE"
echo "- **GitHub Security Advisories:** Repository vulnerability alerts" >> "$REPORT_FILE"
echo "- **Pre-commit hooks:** Local security scanning before commits" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*Report generated by CoPPA dependency security scanner*" >> "$REPORT_FILE"

echo -e "\n${BLUE}🔒 Dependency Security Scan Complete${NC}"
echo "===================================="
echo -e "Issues found: ${RED}$ISSUES_FOUND${NC}"
echo -e "Detailed report: ${BLUE}$REPORT_FILE${NC}"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 No critical dependency security issues found!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Please review and address the $ISSUES_FOUND issue(s) found${NC}"
    echo -e "Run ${BLUE}cat $REPORT_FILE${NC} to see the full report"
    exit 1
fi
