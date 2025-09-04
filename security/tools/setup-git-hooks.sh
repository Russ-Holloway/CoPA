#!/bin/bash
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔒 Setting up Git Security Hooks${NC}"
echo "================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not in a Git repository${NC}"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

echo -e "${YELLOW}📝 Creating pre-commit security hook...${NC}"

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit security hook for CoPPA
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔒 Running pre-commit security checks...${NC}"

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}✅ No files staged for commit${NC}"
    exit 0
fi

SECURITY_ISSUES=0

# Check for secrets in staged files
echo -e "${YELLOW}Checking staged files for secrets...${NC}"

# Patterns to check for secrets
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{3,}['\"]"
    "secret\s*=\s*['\"][^'\"]{8,}['\"]"
    "key\s*=\s*['\"][^'\"]{8,}['\"]"
    "token\s*=\s*['\"][^'\"]{8,}['\"]"
    "api[_-]?key\s*=\s*['\"][^'\"]{8,}['\"]"
    "client[_-]?secret\s*=\s*['\"][^'\"]{8,}['\"]"
    "-----BEGIN.*PRIVATE.*KEY-----"
    "ssh-rsa\s+[A-Za-z0-9+/]{100,}"
    "AKIA[0-9A-Z]{16}"
    "AIza[0-9A-Za-z\\-_]{35}"
)

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            if grep -E "$pattern" "$file" >/dev/null 2>&1; then
                echo -e "${RED}❌ Potential secret found in $file${NC}"
                echo -e "   Pattern: $pattern"
                ((SECURITY_ISSUES++))
            fi
        done
        
        # Check for large files (>1MB)
        if [ $(wc -c < "$file") -gt 1048576 ]; then
            echo -e "${YELLOW}⚠️  Large file detected: $file ($(du -h "$file" | cut -f1))${NC}"
        fi
        
        # Check for binary files that shouldn't be committed
        if file "$file" | grep -q "binary\|executable" && ! echo "$file" | grep -q "\.png$\|\.jpg$\|\.jpeg$\|\.gif$\|\.ico$\|\.pdf$"; then
            echo -e "${YELLOW}⚠️  Binary file detected: $file${NC}"
        fi
    fi
done

# Check for .env files
for file in $STAGED_FILES; do
    if [[ "$file" == .env* ]] && [[ "$file" != *.example ]] && [[ "$file" != *.sample ]]; then
        echo -e "${RED}❌ Environment file should not be committed: $file${NC}"
        ((SECURITY_ISSUES++))
    fi
done

# Check for debug code
DEBUG_PATTERNS=(
    "console\.log\("
    "debugger;"
    "print\("
    "var_dump\("
    "DEBUG\s*=\s*True"
)

for file in $STAGED_FILES; do
    if [ -f "$file" ] && [[ "$file" =~ \.(py|js|ts|php)$ ]]; then
        for pattern in "${DEBUG_PATTERNS[@]}"; do
            if grep -E "$pattern" "$file" >/dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Debug code found in $file${NC}"
                echo -e "   Pattern: $pattern"
                echo -e "   ${YELLOW}Consider removing debug code before committing${NC}"
            fi
done
    fi
done

if [ $SECURITY_ISSUES -gt 0 ]; then
    echo -e "${RED}❌ Security issues found. Commit aborted.${NC}"
    echo -e "Please fix the issues above before committing."
    echo -e "If you're sure you want to commit anyway, use: git commit --no-verify"
    exit 1
else
    echo -e "${GREEN}✅ Security checks passed${NC}"
    exit 0
fi
EOF

# Make pre-commit hook executable
chmod +x .git/hooks/pre-commit

echo -e "${YELLOW}📝 Creating pre-push security hook...${NC}"

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Pre-push security hook for CoPPA
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔒 Running pre-push security validation...${NC}"

# Run full security scan if available
if [ -f "scripts/security-scan.sh" ]; then
    echo -e "${YELLOW}Running comprehensive security scan...${NC}"
    if bash scripts/security-scan.sh; then
        echo -e "${GREEN}✅ Security scan passed${NC}"
    else
        echo -e "${RED}❌ Security scan failed${NC}"
        echo -e "Fix security issues before pushing, or use: git push --no-verify"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Security scan script not found, running basic checks...${NC}"
    
    # Basic checks if security-scan.sh is not available
    if git log --oneline -n 10 | grep -i "password\|secret\|key"; then
        echo -e "${YELLOW}⚠️  Commit messages contain security-related terms${NC}"
    fi
    
    echo -e "${GREEN}✅ Basic security checks passed${NC}"
fi

exit 0
EOF

# Make pre-push hook executable
chmod +x .git/hooks/pre-push

echo -e "${YELLOW}📝 Creating commit-msg hook for security...${NC}"

# Create commit-msg hook to check commit messages for sensitive info
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# Commit message security hook
COMMIT_MSG_FILE=$1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check commit message for potential secrets
SENSITIVE_PATTERNS=(
    "password"
    "secret" 
    "key.*[A-Za-z0-9]{8,}"
    "token.*[A-Za-z0-9]{8,}"
    "api.*key"
)

COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$COMMIT_MSG" | grep -i -E "$pattern" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Commit message contains potentially sensitive term: $pattern${NC}"
        echo -e "Consider rephrasing your commit message to avoid exposing sensitive information"
        # Don't block commit for this, just warn
    fi
done

exit 0
EOF

chmod +x .git/hooks/commit-msg

echo -e "${GREEN}✅ Git security hooks installed successfully!${NC}"
echo -e "\nInstalled hooks:"
echo -e "  • ${BLUE}pre-commit${NC}: Checks for secrets and sensitive files"
echo -e "  • ${BLUE}pre-push${NC}: Runs comprehensive security scan"
echo -e "  • ${BLUE}commit-msg${NC}: Warns about sensitive terms in commit messages"
echo -e "\n${YELLOW}Note: You can bypass hooks with --no-verify if absolutely necessary${NC}"
echo -e "${YELLOW}But please ensure security issues are addressed!${NC}"
