#!/bin/bash

# CoPPA Security Audit Script
# Comprehensive security audit and compliance check for the CoPPA repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Audit results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
log() {
    echo -e "${BLUE}[AUDIT] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[✓ PASS] $1${NC}"
    ((PASSED_CHECKS++))
}

log_fail() {
    echo -e "${RED}[✗ FAIL] $1${NC}"
    ((FAILED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[⚠ WARN] $1${NC}"
    ((WARNING_CHECKS++))
}

log_info() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

check_start() {
    ((TOTAL_CHECKS++))
}

# Create audit report
AUDIT_REPORT="audit-report-$(date +%Y%m%d-%H%M%S).md"

init_report() {
    cat > "$AUDIT_REPORT" << EOF
# CoPPA Security Audit Report

**Audit Date**: $(date)  
**Audit Version**: 1.0  
**Repository**: CoPPA Police Chat Application  
**Auditor**: Automated Security Audit Tool  

## Executive Summary

This report provides a comprehensive security audit of the CoPPA repository, evaluating security controls, compliance measures, and potential vulnerabilities.

---

## Detailed Findings

EOF
}

add_to_report() {
    echo "$1" >> "$AUDIT_REPORT"
}

# Security checks

check_file_permissions() {
    log "Checking file permissions..."
    add_to_report "### File Permissions Audit"
    add_to_report ""
    
    # Check for world-writable files
    check_start
    if find . -type f -perm -o+w -not -path "./.git/*" | head -1 | grep -q .; then
        log_fail "World-writable files found"
        add_to_report "- ❌ **CRITICAL**: World-writable files detected"
        find . -type f -perm -o+w -not -path "./.git/*" | head -10 | while read file; do
            add_to_report "  - $file"
        done
    else
        log_success "No world-writable files found"
        add_to_report "- ✅ No world-writable files detected"
    fi
    
    # Check for files with execute permissions in sensitive directories
    check_start
    sensitive_dirs=("config" "data" "secrets")
    for dir in "${sensitive_dirs[@]}"; do
        if [ -d "$dir" ] && find "$dir" -type f -perm -u+x | grep -q .; then
            log_warning "Executable files found in sensitive directory: $dir"
            add_to_report "- ⚠️ Executable files in sensitive directory: $dir"
        fi
    done
    
    # Check SSH key permissions
    check_start
    if find . -name "*id_rsa*" -o -name "*id_dsa*" -o -name "*.key" | grep -q .; then
        bad_perms=false
        find . -name "*id_rsa*" -o -name "*id_dsa*" -o -name "*.key" | while read keyfile; do
            if [ -f "$keyfile" ]; then
                perms=$(stat -f "%A" "$keyfile" 2>/dev/null || stat -c "%a" "$keyfile" 2>/dev/null || echo "000")
                if [ "$perms" != "600" ]; then
                    log_fail "Insecure permissions on key file: $keyfile ($perms)"
                    add_to_report "- ❌ Insecure key file permissions: $keyfile ($perms)"
                    bad_perms=true
                fi
            fi
        done
        if [ "$bad_perms" = false ]; then
            log_success "SSH keys have secure permissions"
            add_to_report "- ✅ SSH keys have secure permissions"
        fi
    else
        log_success "No SSH keys found in repository"
        add_to_report "- ✅ No SSH keys found in repository"
    fi
    
    add_to_report ""
}

check_secrets_and_credentials() {
    log "Scanning for secrets and credentials..."
    add_to_report "### Secrets and Credentials Audit"
    add_to_report ""
    
    # Define secret patterns
    secret_patterns=(
        "password\\s*=\\s*['\"][^'\"]{3,}['\"]"
        "secret\\s*=\\s*['\"][^'\"]{8,}['\"]"
        "api[_-]?key\\s*=\\s*['\"][^'\"]{8,}['\"]"
        "-----BEGIN.*PRIVATE.*KEY-----"
        "ssh-rsa\\s+[A-Za-z0-9+/]{100,}"
        "DefaultEndpointsProtocol=https;AccountName="
        "postgres://[^@]+:[^@]+@"
        "mysql://[^@]+:[^@]+@"
    )
    
    secrets_found=false
    for pattern in "${secret_patterns[@]}"; do
        check_start
        if grep -r -l "$pattern" . --exclude-dir=.git --exclude="*.md" --exclude="audit-report-*" 2>/dev/null | head -1 | grep -q .; then
            log_fail "Potential secrets found matching pattern: $pattern"
            add_to_report "- ❌ **HIGH RISK**: Potential secrets detected"
            grep -r -l "$pattern" . --exclude-dir=.git --exclude="*.md" --exclude="audit-report-*" 2>/dev/null | head -5 | while read file; do
                add_to_report "  - Pattern: \`$pattern\` in $file"
            done
            secrets_found=true
        fi
    done
    
    if [ "$secrets_found" = false ]; then
        log_success "No obvious secrets detected in code"
        add_to_report "- ✅ No obvious secrets detected in code"
    fi
    
    # Check for .env files
    check_start
    if find . -name ".env*" -type f | grep -q .; then
        log_warning "Environment files found - ensure they're not committed"
        add_to_report "- ⚠️ Environment files detected (ensure not committed):"
        find . -name ".env*" -type f | while read envfile; do
            add_to_report "  - $envfile"
        done
    else
        log_success "No .env files found in repository"
        add_to_report "- ✅ No .env files found in repository"
    fi
    
    add_to_report ""
}

check_dependency_security() {
    log "Checking dependency security..."
    add_to_report "### Dependency Security Audit"
    add_to_report ""
    
    # Python dependencies
    if [ -f "requirements.txt" ]; then
        check_start
        if command -v safety &> /dev/null; then
            log "Scanning Python dependencies with safety..."
            if safety check -r requirements.txt --json > safety_report.json 2>/dev/null; then
                vuln_count=$(jq '.vulnerabilities | length' safety_report.json 2>/dev/null || echo "0")
                if [ "$vuln_count" -gt 0 ]; then
                    log_fail "Python dependencies have $vuln_count vulnerabilities"
                    add_to_report "- ❌ **HIGH RISK**: $vuln_count Python dependency vulnerabilities found"
                else
                    log_success "No Python dependency vulnerabilities found"
                    add_to_report "- ✅ No Python dependency vulnerabilities detected"
                fi
                rm -f safety_report.json
            else
                log_warning "Could not scan Python dependencies"
                add_to_report "- ⚠️ Python dependency scan failed"
            fi
        else
            log_warning "Safety tool not available for Python dependency scanning"
            add_to_report "- ⚠️ Safety tool not installed - Python dependencies not scanned"
        fi
    fi
    
    # Node.js dependencies
    if [ -f "package.json" ] || [ -f "frontend/package.json" ]; then
        check_start
        if command -v npm &> /dev/null; then
            log "Scanning Node.js dependencies with npm audit..."
            audit_dirs=("." "frontend")
            for dir in "${audit_dirs[@]}"; do
                if [ -f "$dir/package.json" ]; then
                    cd "$dir"
                    if npm audit --json > npm_audit.json 2>/dev/null; then
                        vuln_count=$(jq '.metadata.vulnerabilities.total' npm_audit.json 2>/dev/null || echo "0")
                        if [ "$vuln_count" -gt 0 ]; then
                            log_fail "Node.js dependencies in $dir have $vuln_count vulnerabilities"
                            add_to_report "- ❌ **HIGH RISK**: $vuln_count Node.js vulnerabilities in $dir"
                        else
                            log_success "No Node.js dependency vulnerabilities in $dir"
                            add_to_report "- ✅ No Node.js vulnerabilities in $dir"
                        fi
                        rm -f npm_audit.json
                    else
                        log_warning "Could not scan Node.js dependencies in $dir"
                        add_to_report "- ⚠️ Node.js dependency scan failed in $dir"
                    fi
                    cd - > /dev/null
                fi
            done
        else
            log_warning "npm not available for Node.js dependency scanning"
            add_to_report "- ⚠️ npm not installed - Node.js dependencies not scanned"
        fi
    fi
    
    add_to_report ""
}

check_git_security() {
    log "Checking Git security configuration..."
    add_to_report "### Git Security Audit"
    add_to_report ""
    
    # Check for .gitignore
    check_start
    if [ -f ".gitignore" ]; then
        log_success ".gitignore file exists"
        add_to_report "- ✅ .gitignore file present"
        
        # Check if sensitive files are ignored
        sensitive_patterns=(".env" "*.key" "*.pem" "id_rsa" "config.json" "secrets.json")
        for pattern in "${sensitive_patterns[@]}"; do
            if ! grep -q "$pattern" .gitignore; then
                log_warning ".gitignore missing pattern: $pattern"
                add_to_report "- ⚠️ .gitignore missing pattern: $pattern"
            fi
        done
    else
        log_fail ".gitignore file missing"
        add_to_report "- ❌ **MEDIUM RISK**: .gitignore file missing"
    fi
    
    # Check Git hooks
    check_start
    if [ -d ".git/hooks" ]; then
        if [ -f ".git/hooks/pre-commit" ] || [ -f ".git/hooks/pre-push" ]; then
            log_success "Git security hooks installed"
            add_to_report "- ✅ Git security hooks installed"
        else
            log_warning "No Git security hooks found"
            add_to_report "- ⚠️ No Git security hooks installed"
        fi
    else
        log_warning "Not a Git repository or hooks directory missing"
        add_to_report "- ⚠️ Git hooks directory not found"
    fi
    
    # Check for large files
    check_start
    large_files=$(find . -type f -size +10M -not -path "./.git/*" 2>/dev/null)
    if [ -n "$large_files" ]; then
        log_warning "Large files found (>10MB)"
        add_to_report "- ⚠️ Large files detected (>10MB):"
        echo "$large_files" | head -5 | while read file; do
            size=$(du -h "$file" | cut -f1)
            add_to_report "  - $file ($size)"
        done
    else
        log_success "No large files found"
        add_to_report "- ✅ No large files detected"
    fi
    
    add_to_report ""
}

check_docker_security() {
    log "Checking Docker security..."
    add_to_report "### Docker Security Audit"
    add_to_report ""
    
    # Check Dockerfile security
    dockerfiles=$(find . -name "Dockerfile*" -type f)
    if [ -n "$dockerfiles" ]; then
        echo "$dockerfiles" | while read dockerfile; do
            log "Auditing $dockerfile..."
            add_to_report "#### $dockerfile"
            add_to_report ""
            
            # Check for root user
            check_start
            if grep -q "USER root" "$dockerfile" || ! grep -q "USER " "$dockerfile"; then
                log_fail "$dockerfile: Running as root user"
                add_to_report "- ❌ **HIGH RISK**: Container runs as root"
            else
                log_success "$dockerfile: Non-root user specified"
                add_to_report "- ✅ Non-root user specified"
            fi
            
            # Check for COPY . .
            check_start
            if grep -q "COPY \. \." "$dockerfile"; then
                log_warning "$dockerfile: Broad COPY operation detected"
                add_to_report "- ⚠️ Broad COPY operation (COPY . .) - consider specific files"
            else
                log_success "$dockerfile: No broad COPY operations"
                add_to_report "- ✅ No broad COPY operations"
            fi
            
            # Check for specific base image versions
            check_start
            if grep -q ":latest" "$dockerfile"; then
                log_warning "$dockerfile: Using :latest tag"
                add_to_report "- ⚠️ Using :latest tag - specify exact versions"
            else
                log_success "$dockerfile: Specific image versions used"
                add_to_report "- ✅ Specific image versions specified"
            fi
            
            # Check for exposed ports
            check_start
            if grep -q "EXPOSE" "$dockerfile"; then
                exposed_ports=$(grep "EXPOSE" "$dockerfile" | awk '{print $2}')
                log_info "$dockerfile: Exposes ports: $exposed_ports"
                add_to_report "- ℹ️ Exposed ports: $exposed_ports"
            fi
            
            add_to_report ""
        done
    else
        log_success "No Dockerfiles found"
        add_to_report "- ✅ No Dockerfiles to audit"
    fi
    
    add_to_report ""
}

check_azure_security() {
    log "Checking Azure security configuration..."
    add_to_report "### Azure Security Audit"
    add_to_report ""
    
    # Check ARM templates
    arm_templates=$(find . -name "*.json" -path "*/infra*" -o -name "*.bicep" 2>/dev/null)
    if [ -n "$arm_templates" ]; then
        echo "$arm_templates" | while read template; do
            log "Auditing Azure template: $template"
            add_to_report "#### $template"
            add_to_report ""
            
            # Check for hardcoded values
            check_start
            if [[ "$template" == *.json ]]; then
                if grep -q '"[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"' "$template"; then
                    log_warning "$template: Hardcoded IP addresses found"
                    add_to_report "- ⚠️ Hardcoded IP addresses detected"
                else
                    log_success "$template: No hardcoded IP addresses"
                    add_to_report "- ✅ No hardcoded IP addresses"
                fi
                
                # Check for secure string usage
                if grep -q '"type": "string"' "$template" && grep -q -i "password\|secret\|key" "$template"; then
                    if ! grep -q '"type": "secureString"' "$template"; then
                        log_fail "$template: Sensitive parameters not using secureString"
                        add_to_report "- ❌ **HIGH RISK**: Sensitive parameters not using secureString"
                    else
                        log_success "$template: Secure strings used for sensitive data"
                        add_to_report "- ✅ secureString used for sensitive parameters"
                    fi
                fi
            fi
            
            add_to_report ""
        done
    else
        log_info "No Azure templates found"
        add_to_report "- ℹ️ No Azure templates to audit"
    fi
    
    # Check azure.yaml
    check_start
    if [ -f "azure.yaml" ]; then
        log_success "Azure deployment configuration found"
        add_to_report "- ✅ Azure deployment configuration present"
    else
        log_warning "No azure.yaml found"
        add_to_report "- ⚠️ No azure.yaml deployment configuration"
    fi
    
    add_to_report ""
}

check_code_security() {
    log "Checking code security patterns..."
    add_to_report "### Code Security Audit"
    add_to_report ""
    
    # Debug code patterns
    debug_patterns=(
        "console\.log\("
        "debugger;"
        "print\("
        "var_dump\("
        "DEBUG\s*=\s*True"
        "debug\s*=\s*true"
    )
    
    debug_found=false
    for pattern in "${debug_patterns[@]}"; do
        check_start
        if grep -r "$pattern" . --include="*.py" --include="*.js" --include="*.ts" --exclude-dir=.git --exclude="audit-report-*" 2>/dev/null | head -1 | grep -q .; then
            log_warning "Debug code found: $pattern"
            add_to_report "- ⚠️ Debug code pattern detected: \`$pattern\`"
            debug_found=true
        fi
    done
    
    if [ "$debug_found" = false ]; then
        log_success "No debug code patterns found"
        add_to_report "- ✅ No debug code patterns detected"
    fi
    
    # TODO/FIXME patterns
    check_start
    todo_count=$(grep -r "TODO\|FIXME\|XXX\|HACK" . --include="*.py" --include="*.js" --include="*.ts" --exclude-dir=.git --exclude="audit-report-*" 2>/dev/null | wc -l)
    if [ "$todo_count" -gt 0 ]; then
        log_warning "$todo_count TODO/FIXME comments found"
        add_to_report "- ⚠️ $todo_count TODO/FIXME comments (review for security implications)"
    else
        log_success "No TODO/FIXME comments found"
        add_to_report "- ✅ No TODO/FIXME comments"
    fi
    
    add_to_report ""
}

check_backup_files() {
    log "Checking for backup and temporary files..."
    add_to_report "### Backup and Temporary Files Audit"
    add_to_report ""
    
    # Backup file patterns
    backup_patterns=("*.bak" "*.backup" "*.old" "*.orig" "*~" "*.swp" "*.swo" "*.tmp" "*.temp")
    backup_found=false
    
    for pattern in "${backup_patterns[@]}"; do
        check_start
        if find . -name "$pattern" -type f -not -path "./.git/*" | head -1 | grep -q .; then
            log_warning "Backup files found: $pattern"
            add_to_report "- ⚠️ Backup files detected: $pattern"
            find . -name "$pattern" -type f -not -path "./.git/*" | head -3 | while read file; do
                add_to_report "  - $file"
            done
            backup_found=true
        fi
    done
    
    if [ "$backup_found" = false ]; then
        log_success "No backup files found"
        add_to_report "- ✅ No backup files detected"
    fi
    
    add_to_report ""
}

check_network_security() {
    log "Checking network security configuration..."
    add_to_report "### Network Security Audit"
    add_to_report ""
    
    # Check for hardcoded URLs and IPs
    check_start
    if grep -r "http://\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" . --include="*.py" --include="*.js" --include="*.ts" --exclude-dir=.git --exclude="audit-report-*" 2>/dev/null | head -1 | grep -q .; then
        log_warning "Hardcoded URLs/IPs found in code"
        add_to_report "- ⚠️ Hardcoded URLs/IP addresses in code:"
        grep -r "http://\|[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" . --include="*.py" --include="*.js" --include="*.ts" --exclude-dir=.git --exclude="audit-report-*" 2>/dev/null | head -3 | while read line; do
            add_to_report "  - $line"
        done
    else
        log_success "No hardcoded URLs/IPs in code"
        add_to_report "- ✅ No hardcoded URLs/IPs detected"
    fi
    
    # Check for insecure HTTP usage
    check_start
    if grep -r "http://" . --include="*.py" --include="*.js" --include="*.ts" --exclude-dir=.git --exclude="audit-report-*" 2>/dev/null | head -1 | grep -q .; then
        log_fail "Insecure HTTP URLs found"
        add_to_report "- ❌ **MEDIUM RISK**: Insecure HTTP URLs detected"
    else
        log_success "No insecure HTTP URLs found"
        add_to_report "- ✅ No insecure HTTP URLs"
    fi
    
    add_to_report ""
}

generate_summary() {
    log "Generating audit summary..."
    
    # Calculate score
    if [ $TOTAL_CHECKS -gt 0 ]; then
        SCORE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    else
        SCORE=0
    fi
    
    # Determine security level
    if [ $SCORE -ge 90 ]; then
        SECURITY_LEVEL="EXCELLENT"
        LEVEL_COLOR=$GREEN
    elif [ $SCORE -ge 80 ]; then
        SECURITY_LEVEL="GOOD"
        LEVEL_COLOR=$BLUE
    elif [ $SCORE -ge 70 ]; then
        SECURITY_LEVEL="MODERATE"
        LEVEL_COLOR=$YELLOW
    elif [ $SCORE -ge 60 ]; then
        SECURITY_LEVEL="POOR"
        LEVEL_COLOR=$RED
    else
        SECURITY_LEVEL="CRITICAL"
        LEVEL_COLOR=$RED
    fi
    
    # Add summary to report
    cat >> "$AUDIT_REPORT" << EOF

---

## Audit Summary

### Overall Security Score: $SCORE/100 ($SECURITY_LEVEL)

### Results Breakdown
- **Total Checks**: $TOTAL_CHECKS
- **Passed**: $PASSED_CHECKS ✅
- **Failed**: $FAILED_CHECKS ❌
- **Warnings**: $WARNING_CHECKS ⚠️

### Risk Assessment
EOF

    if [ $FAILED_CHECKS -gt 0 ]; then
        add_to_report "- **HIGH PRIORITY**: $FAILED_CHECKS critical security issues require immediate attention"
    fi
    
    if [ $WARNING_CHECKS -gt 0 ]; then
        add_to_report "- **MEDIUM PRIORITY**: $WARNING_CHECKS security warnings should be reviewed"
    fi
    
    if [ $FAILED_CHECKS -eq 0 ] && [ $WARNING_CHECKS -eq 0 ]; then
        add_to_report "- **LOW RISK**: No critical security issues identified"
    fi
    
    cat >> "$AUDIT_REPORT" << EOF

### Recommendations

1. **Address Critical Issues**: Fix all failed security checks immediately
2. **Review Warnings**: Evaluate and address security warnings based on risk assessment
3. **Regular Audits**: Run this audit weekly and after major changes
4. **Security Monitoring**: Implement continuous security monitoring
5. **Team Training**: Ensure development team follows security best practices

### Next Steps

1. Review this report with your security team
2. Create issues for critical and high-priority findings
3. Schedule regular security audits
4. Update security policies based on findings

---

**Audit Completed**: $(date)  
**Report Location**: $AUDIT_REPORT  
**Next Recommended Audit**: $(date -d "+1 week")

EOF
    
    # Console output
    echo ""
    echo "=================================="
    echo "    SECURITY AUDIT COMPLETE"
    echo "=================================="
    echo ""
    echo -e "${PURPLE}Security Score: $SCORE/100${NC}"
    echo -e "${LEVEL_COLOR}Security Level: $SECURITY_LEVEL${NC}"
    echo ""
    echo "Results:"
    echo -e "  ${GREEN}✓ Passed: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}✗ Failed: $FAILED_CHECKS${NC}"
    echo -e "  ${YELLOW}⚠ Warnings: $WARNING_CHECKS${NC}"
    echo ""
    echo "Report saved to: $AUDIT_REPORT"
    echo ""
    
    if [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "${RED}⚠️  CRITICAL ISSUES FOUND - IMMEDIATE ACTION REQUIRED${NC}"
    elif [ $WARNING_CHECKS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Security warnings require review${NC}"
    else
        echo -e "${GREEN}✅ No critical security issues found${NC}"
    fi
    echo ""
}

# Main audit function
main() {
    log "Starting CoPPA Security Audit..."
    log "This comprehensive audit will check multiple security aspects of the repository."
    echo ""
    
    # Initialize report
    init_report
    
    # Run security checks
    log "=== File Permissions ==="
    check_file_permissions
    
    log "=== Secrets and Credentials ==="
    check_secrets_and_credentials
    
    log "=== Dependency Security ==="
    check_dependency_security
    
    log "=== Git Security ==="
    check_git_security
    
    log "=== Docker Security ==="
    check_docker_security
    
    log "=== Azure Security ==="
    check_azure_security
    
    log "=== Code Security ==="
    check_code_security
    
    log "=== Backup Files ==="
    check_backup_files
    
    log "=== Network Security ==="
    check_network_security
    
    # Generate final summary
    generate_summary
}

# Run main function
main "$@"
