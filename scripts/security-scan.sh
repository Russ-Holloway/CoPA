#!/bin/bash
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 CoPPA Security Scanner${NC}"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "app.py" ] || [ ! -f "requirements.txt" ]; then
    echo -e "${RED}❌ Error: Must be run from the CoPPA root directory${NC}"
    exit 1
fi

ISSUES_FOUND=0
SCAN_RESULTS="security-scan-results.txt"
echo "Security Scan Results - $(date)" > "$SCAN_RESULTS"
echo "======================================" >> "$SCAN_RESULTS"

echo -e "\n${YELLOW}1. Checking for secrets and sensitive data...${NC}"

# Check for common secrets patterns
echo "Scanning for potential secrets..." >> "$SCAN_RESULTS"
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{3,}['\"]"
    "secret\s*=\s*['\"][^'\"]{8,}['\"]"
    "key\s*=\s*['\"][^'\"]{8,}['\"]"
    "token\s*=\s*['\"][^'\"]{8,}['\"]"
    "api[_-]?key\s*=\s*['\"][^'\"]{8,}['\"]"
    "client[_-]?secret\s*=\s*['\"][^'\"]{8,}['\"]"
    "database[_-]?url\s*=\s*['\"][^'\"]{10,}['\"]"
    "connection[_-]?string\s*=\s*['\"][^'\"]{10,}['\"]"
    "azure[_-]?storage[_-]?account[_-]?key"
    "azure[_-]?subscription[_-]?key"
    "-----BEGIN.*PRIVATE.*KEY-----"
    "ssh-rsa\s+[A-Za-z0-9+/]{100,}"
)

SECRET_FOUND=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=venv --exclude="$SCAN_RESULTS" . 2>/dev/null; then
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

# Check .env files exist and are properly secured
ENV_FILES=(".env" ".env.local" ".env.production" ".env.development")
for env_file in "${ENV_FILES[@]}"; do
    if [ -f "$env_file" ]; then
        echo -e "${YELLOW}📄 Found $env_file${NC}"
        
        # Check if .env is in .gitignore
        if ! grep -q "^\.env$\|^\.env\*$\|^\.env\..*$" .gitignore 2>/dev/null; then
            echo -e "${RED}⚠️  $env_file might not be in .gitignore${NC}"
            echo "WARNING: $env_file not properly ignored" >> "$SCAN_RESULTS"
            ((ISSUES_FOUND++))
        else
            echo -e "${GREEN}✅ $env_file is properly ignored${NC}"
        fi
        
        # Check file permissions (should be 600 or 640)
        if [ -f "$env_file" ]; then
            PERMS=$(stat -c "%a" "$env_file" 2>/dev/null || stat -f "%Lp" "$env_file" 2>/dev/null)
            if [[ "$PERMS" != "600" && "$PERMS" != "640" ]]; then
                echo -e "${YELLOW}⚠️  $env_file permissions are $PERMS (should be 600 or 640)${NC}"
                echo "WARNING: $env_file permissions: $PERMS" >> "$SCAN_RESULTS"
            fi
        fi
    fi
done

echo -e "\n${YELLOW}3. Analyzing Python dependencies for vulnerabilities...${NC}"

if command -v safety >/dev/null 2>&1; then
    echo "Running safety check on Python dependencies..."
    if safety check --json > safety_results.json 2>/dev/null; then
        VULN_COUNT=$(cat safety_results.json | jq length 2>/dev/null || echo "0")
        if [ "$VULN_COUNT" -gt 0 ]; then
            echo -e "${RED}⚠️  Found $VULN_COUNT known vulnerabilities in Python dependencies${NC}"
            echo "Python vulnerabilities found: $VULN_COUNT" >> "$SCAN_RESULTS"
            safety check >> "$SCAN_RESULTS" 2>&1 || true
            ((ISSUES_FOUND++))
        else
            echo -e "${GREEN}✅ No known vulnerabilities in Python dependencies${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not run safety check${NC}"
    fi
    rm -f safety_results.json
else
    echo -e "${YELLOW}📦 Installing 'safety' for dependency vulnerability scanning...${NC}"
    pip install safety >/dev/null 2>&1 || echo -e "${YELLOW}⚠️  Could not install safety${NC}"
fi

echo -e "\n${YELLOW}4. Checking for hardcoded IP addresses and URLs...${NC}"

# Check for hardcoded IPs and sensitive URLs
IP_PATTERN="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
HARDCODED_IPS=$(grep -r -E "$IP_PATTERN" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv --exclude="$SCAN_RESULTS" . 2>/dev/null | grep -v "127.0.0.1\|0.0.0.0\|localhost" || true)

if [ -n "$HARDCODED_IPS" ]; then
    echo -e "${YELLOW}⚠️  Found potentially hardcoded IP addresses:${NC}"
    echo "$HARDCODED_IPS"
    echo "Hardcoded IPs found:" >> "$SCAN_RESULTS"
    echo "$HARDCODED_IPS" >> "$SCAN_RESULTS"
    ((ISSUES_FOUND++))
else
    echo -e "${GREEN}✅ No hardcoded IP addresses found${NC}"
fi

echo -e "\n${YELLOW}5. Checking file permissions...${NC}"

# Check for overly permissive files
SENSITIVE_FILES=("*.key" "*.pem" "*.p12" "*.pfx" "*.crt" ".env*" "id_rsa*" "*.sql")
for pattern in "${SENSITIVE_FILES[@]}"; do
    find . -name "$pattern" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            PERMS=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
            if [[ "$PERMS" =~ ^[4-7][4-7][4-7]$ ]]; then
                echo -e "${YELLOW}⚠️  $file has overly permissive permissions: $PERMS${NC}"
                echo "Overly permissive: $file ($PERMS)" >> "$SCAN_RESULTS"
            fi
        fi
    done
done

echo -e "\n${YELLOW}6. Checking Docker configuration security...${NC}"

if [ -f "WebApp.Dockerfile" ] || [ -f "Dockerfile" ]; then
    DOCKERFILE="WebApp.Dockerfile"
    [ -f "Dockerfile" ] && DOCKERFILE="Dockerfile"
    
    echo "Analyzing $DOCKERFILE for security issues..."
    
    # Check for running as root
    if ! grep -q "USER.*[^0]" "$DOCKERFILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Dockerfile may run as root (no USER directive found)${NC}"
        echo "Docker security: No USER directive" >> "$SCAN_RESULTS"
    fi
    
    # Check for COPY with broad wildcards
    if grep -q "COPY \. \." "$DOCKERFILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Dockerfile uses broad COPY . . (consider using specific files)${NC}"
        echo "Docker security: Broad COPY directive" >> "$SCAN_RESULTS"
    fi
    
    echo -e "${GREEN}✅ Docker configuration checked${NC}"
fi

echo -e "\n${YELLOW}7. Checking for debug/development settings in production code...${NC}"

DEBUG_PATTERNS=(
    "DEBUG\s*=\s*True"
    "debug\s*=\s*true"
    "FLASK_ENV\s*=\s*development"
    "NODE_ENV\s*=\s*development"
    "console\.log\("
    "print\("
    "debugger;"
)

DEBUG_FOUND=false
for pattern in "${DEBUG_PATTERNS[@]}"; do
    if grep -r -E "$pattern" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv --exclude="$SCAN_RESULTS" . 2>/dev/null | grep -v ".example\|.sample\|README\|\.md$" | head -5; then
        echo -e "${YELLOW}⚠️  Found potential debug code: $pattern${NC}"
        echo "Debug code found: $pattern" >> "$SCAN_RESULTS"
        DEBUG_FOUND=true
    fi
done

if [ "$DEBUG_FOUND" = false ]; then
    echo -e "${GREEN}✅ No obvious debug code found${NC}"
fi

echo -e "\n${YELLOW}8. Checking Git configuration...${NC}"

# Check if .git/config has any suspicious remotes
if [ -f ".git/config" ]; then
    REMOTES=$(git remote -v 2>/dev/null || echo "")
    if echo "$REMOTES" | grep -q "http://"; then
        echo -e "${YELLOW}⚠️  Git remote uses HTTP instead of HTTPS${NC}"
        echo "Git security: HTTP remote found" >> "$SCAN_RESULTS"
    fi
    
    # Check for accidentally committed .git/config
    if git ls-files | grep -q "\.git/config"; then
        echo -e "${RED}⚠️  .git/config is tracked in Git (security risk!)${NC}"
        echo "CRITICAL: .git/config is tracked" >> "$SCAN_RESULTS"
        ((ISSUES_FOUND++))
    fi
fi

echo -e "\n${YELLOW}9. Checking for backup and temporary files...${NC}"

BACKUP_PATTERNS=("*.bak" "*.backup" "*.old" "*~" "*.tmp" "*.temp" "*.swp" ".DS_Store")
BACKUP_FOUND=false
for pattern in "${BACKUP_PATTERNS[@]}"; do
    if find . -name "$pattern" -type f 2>/dev/null | grep -v ".git" | head -1 >/dev/null; then
        echo -e "${YELLOW}⚠️  Found backup/temp files matching: $pattern${NC}"
        find . -name "$pattern" -type f 2>/dev/null | grep -v ".git" | head -3
        BACKUP_FOUND=true
    fi
done

if [ "$BACKUP_FOUND" = false ]; then
    echo -e "${GREEN}✅ No backup/temp files found${NC}"
fi

echo -e "\n${YELLOW}10. Checking Azure configuration security...${NC}"

# Check for Azure-specific security issues
if [ -f "azure.yaml" ]; then
    echo "Checking Azure configuration..."
    
    # Look for potential issues in azure.yaml
    if grep -q "password\|secret\|key" azure.yaml 2>/dev/null; then
        echo -e "${YELLOW}⚠️  azure.yaml contains password/secret/key references${NC}"
        echo "Azure config contains secrets references" >> "$SCAN_RESULTS"
    fi
fi

# Check ARM templates for security
if [ -f "infrastructure/deployment.json" ]; then
    echo "Checking ARM template security..."
    
    # Check for hardcoded secrets in ARM template
    if grep -q "defaultValue.*[A-Za-z0-9]{16,}" infrastructure/deployment.json 2>/dev/null; then
        echo -e "${YELLOW}⚠️  ARM template may contain hardcoded values${NC}"
        echo "ARM template security concern" >> "$SCAN_RESULTS"
    fi
fi

echo -e "\n${BLUE}🔒 Security Scan Summary${NC}"
echo "========================="
echo -e "Scan completed: $(date)"
echo -e "Issues found: ${RED}$ISSUES_FOUND${NC}"
echo -e "Results saved to: ${BLUE}$SCAN_RESULTS${NC}"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 No critical security issues found!${NC}"
    echo "✅ SCAN PASSED - No critical issues" >> "$SCAN_RESULTS"
    exit 0
else
    echo -e "${YELLOW}⚠️  Please review the $ISSUES_FOUND issue(s) found${NC}"
    echo "❌ SCAN COMPLETED WITH ISSUES: $ISSUES_FOUND" >> "$SCAN_RESULTS"
    exit 1
fi
