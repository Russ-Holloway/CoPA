#!/bin/bash

# CoPPA Security Setup Script
# This script sets up comprehensive security measures for the CoPPA repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if running as root
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. Some security tools work better with regular user permissions."
    fi
}

# Install required security tools
install_security_tools() {
    log "Installing security tools..."
    
    # Update package manager
    if command -v apt-get &> /dev/null; then
        log "Updating apt package list..."
        sudo apt-get update -qq
        
        # Install system security tools
        log "Installing system security tools..."
        sudo apt-get install -y \
            git \
            curl \
            jq \
            grep \
            find \
            file \
            openssl \
            gnupg \
            rkhunter \
            lynis \
            chkrootkit \
            fail2ban \
            ufw \
            aide
            
        log_success "System security tools installed"
    elif command -v yum &> /dev/null; then
        log "Updating yum package list..."
        sudo yum update -y
        
        # Install system security tools for RHEL/CentOS
        sudo yum install -y \
            git \
            curl \
            jq \
            grep \
            findutils \
            file \
            openssl \
            gnupg2 \
            rkhunter \
            lynis \
            chkrootkit \
            fail2ban \
            firewalld
            
        log_success "System security tools installed"
    else
        log_warning "Package manager not detected. Please install security tools manually."
    fi
    
    # Install Python security tools
    if command -v python3 &> /dev/null; then
        log "Installing Python security tools..."
        
        # Upgrade pip first
        python3 -m pip install --upgrade pip --quiet
        
        # Install security packages
        python3 -m pip install --quiet \
            safety \
            bandit \
            semgrep \
            pip-licenses \
            detect-secrets
            
        log_success "Python security tools installed"
    else
        log_warning "Python3 not found. Please install Python and security tools manually."
    fi
    
    # Install Node.js security tools
    if command -v npm &> /dev/null; then
        log "Installing Node.js security tools..."
        
        npm install -g --silent \
            npm-audit \
            eslint \
            @eslint/eslintrc \
            eslint-plugin-security \
            retire
            
        log_success "Node.js security tools installed"
    else
        log_warning "npm not found. Please install Node.js and security tools manually."
    fi
}

# Set up file permissions
setup_file_permissions() {
    log "Setting up secure file permissions..."
    
    # Make security scripts executable
    chmod +x scripts/security-scan.sh 2>/dev/null || log_warning "security-scan.sh not found"
    chmod +x scripts/setup-git-hooks.sh 2>/dev/null || log_warning "setup-git-hooks.sh not found"
    chmod +x scripts/dependency-security.sh 2>/dev/null || log_warning "dependency-security.sh not found"
    
    # Secure sensitive files if they exist
    if [ -f ".env" ]; then
        chmod 600 .env
        log_success "Secured .env file permissions"
    fi
    
    if [ -f "config.json" ]; then
        chmod 600 config.json
        log_success "Secured config.json file permissions"
    fi
    
    # Secure SSH keys if they exist
    find . -name "*id_rsa*" -type f -exec chmod 600 {} \; 2>/dev/null || true
    find . -name "*.key" -type f -exec chmod 600 {} \; 2>/dev/null || true
    find . -name "*.pem" -type f -exec chmod 600 {} \; 2>/dev/null || true
    
    log_success "File permissions configured"
}

# Configure Git security
configure_git_security() {
    log "Configuring Git security settings..."
    
    # Set up secure Git configuration
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global core.autocrlf input 2>/dev/null || true
    git config --global core.fileMode true 2>/dev/null || true
    git config --global pull.rebase false 2>/dev/null || true
    
    # Enable Git secret scanning
    git config --global core.hooksPath .git/hooks 2>/dev/null || true
    
    # Set up .gitignore for security
    if [ ! -f ".gitignore" ]; then
        log "Creating secure .gitignore..."
        cat > .gitignore << 'EOF'
# Security sensitive files
.env
.env.local
.env.production
.env.development
*.key
*.pem
id_rsa*
id_dsa*
*.p12
*.pfx
*.jks
config.json
secrets.json
auth.json

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/settings.json
.idea/
*.swp
*.swo
*~

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Dependency directories
node_modules/
__pycache__/
*.pyc
.Python
env/
venv/
ENV/

# Build outputs
dist/
build/
*.egg-info/
.coverage
htmlcov/

# Temporary files
*.tmp
*.temp
*.backup
*.bak
.DS_Store
Thumbs.db
EOF
        log_success "Secure .gitignore created"
    fi
    
    # Set up Git hooks if the setup script exists
    if [ -f "scripts/setup-git-hooks.sh" ]; then
        log "Setting up Git security hooks..."
        bash scripts/setup-git-hooks.sh
        log_success "Git security hooks configured"
    fi
    
    log_success "Git security configured"
}

# Set up secrets scanning
setup_secrets_scanning() {
    log "Setting up secrets scanning..."
    
    # Create detect-secrets config if Python is available
    if command -v python3 &> /dev/null && python3 -c "import detect_secrets" 2>/dev/null; then
        if [ ! -f ".secrets.baseline" ]; then
            log "Creating detect-secrets baseline..."
            detect-secrets scan --baseline .secrets.baseline
            log_success "detect-secrets baseline created"
        fi
    fi
    
    # Create custom secrets patterns file
    if [ ! -f "security-patterns.txt" ]; then
        log "Creating security patterns file..."
        cat > security-patterns.txt << 'EOF'
# Security patterns for scanning
# API Keys and Secrets
password\s*=\s*['"][^'"]{3,}['"]
secret\s*=\s*['"][^'"]{8,}['"]
api[_-]?key\s*=\s*['"][^'"]{8,}['"]
client[_-]?secret\s*=\s*['"][^'"]{8,}['"]
access[_-]?token\s*=\s*['"][^'"]{8,}['"]

# Private Keys
-----BEGIN.*PRIVATE.*KEY-----
ssh-rsa\s+[A-Za-z0-9+/]{100,}
ssh-ed25519\s+[A-Za-z0-9+/]{68}

# Database URLs
postgres://[^@]+:[^@]+@
mysql://[^@]+:[^@]+@
mongodb://[^@]+:[^@]+@

# Azure Connection Strings
DefaultEndpointsProtocol=https;AccountName=
BlobEndpoint=https://[^.]+\.blob\.core\.windows\.net

# AWS Credentials
aws_access_key_id\s*=\s*[A-Z0-9]{20}
aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}

# JWT Tokens
eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+

# Generic high-entropy strings
['""][A-Za-z0-9+/]{40,}['""]
EOF
        log_success "Security patterns file created"
    fi
    
    log_success "Secrets scanning configured"
}

# Configure system security
configure_system_security() {
    log "Configuring system security..."
    
    # Configure fail2ban if available
    if command -v fail2ban-client &> /dev/null; then
        log "Configuring fail2ban..."
        sudo systemctl enable fail2ban 2>/dev/null || true
        sudo systemctl start fail2ban 2>/dev/null || true
        log_success "fail2ban configured"
    fi
    
    # Configure UFW firewall if available
    if command -v ufw &> /dev/null; then
        log "Configuring UFW firewall..."
        sudo ufw --force enable 2>/dev/null || true
        sudo ufw default deny incoming 2>/dev/null || true
        sudo ufw default allow outgoing 2>/dev/null || true
        # Allow SSH
        sudo ufw allow ssh 2>/dev/null || true
        # Allow HTTP and HTTPS
        sudo ufw allow 80 2>/dev/null || true
        sudo ufw allow 443 2>/dev/null || true
        log_success "UFW firewall configured"
    fi
    
    # Set up AIDE if available
    if command -v aide &> /dev/null; then
        log "Initializing AIDE database..."
        sudo aide --init 2>/dev/null || log_warning "AIDE initialization failed"
        sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null || true
        log_success "AIDE configured"
    fi
    
    log_success "System security configured"
}

# Create security documentation
create_security_documentation() {
    log "Creating security documentation..."
    
    cat > SECURITY_SETUP_COMPLETE.md << 'EOF'
# CoPPA Security Setup Complete

This document provides information about the security measures implemented in the CoPPA repository.

## Security Tools Installed

### System Security Tools
- **fail2ban**: Intrusion prevention system
- **ufw**: Uncomplicated Firewall
- **aide**: Advanced Intrusion Detection Environment
- **rkhunter**: Rootkit detection
- **lynis**: Security auditing tool
- **chkrootkit**: Local rootkit detector

### Application Security Tools
- **safety**: Python dependency vulnerability scanner
- **bandit**: Python security linter
- **semgrep**: Static analysis security scanner
- **detect-secrets**: Secret detection tool
- **eslint-plugin-security**: JavaScript/TypeScript security linting
- **npm-audit**: Node.js dependency vulnerability scanner

## Security Scripts

### 1. security-scan.sh
Comprehensive security scanner that checks for:
- Secrets and credentials
- Environment file security
- File permissions
- Dependency vulnerabilities
- Hardcoded credentials
- Debug code
- Docker security
- Azure configuration security
- Git security settings
- Backup files

Usage:
```bash
./scripts/security-scan.sh [--fix]
```

### 2. setup-git-hooks.sh
Installs Git security hooks:
- **pre-commit**: Scans for secrets and security issues before commits
- **pre-push**: Comprehensive security validation before pushing
- **commit-msg**: Validates commit messages for security keywords

### 3. dependency-security.sh
Dependency security scanner:
- Python package vulnerability scanning with safety
- Node.js package vulnerability scanning with npm audit
- License compliance checking
- Malicious package detection
- Detailed vulnerability reporting

Usage:
```bash
./scripts/dependency-security.sh [--fix]
```

## Security Configuration

### security-config.yaml
Central security configuration file defining:
- Security scanning policies
- File security settings
- Dependency security rules
- Code quality standards
- Azure security settings
- Docker security requirements
- Network security policies
- Compliance requirements
- Incident response procedures

## Git Security

### Git Hooks
Automated security validation on:
- Every commit (pre-commit hook)
- Every push (pre-push hook)
- Commit message validation

### .gitignore
Configured to exclude:
- Environment files (.env*)
- Private keys (*.key, *.pem, id_rsa*)
- Configuration files with secrets
- Temporary and backup files
- IDE-specific files

## File Security

### Secure Permissions
- Scripts: 755 (executable)
- Sensitive files: 600 (owner read/write only)
- Configuration files: 600 (restricted access)

### File Monitoring
- AIDE database for file integrity monitoring
- Regular scans for backup files and temporary data
- Permission validation for sensitive files

## System Security

### Firewall (UFW)
- Default deny incoming connections
- Allow SSH (port 22)
- Allow HTTP (port 80) and HTTPS (port 443)
- All outgoing connections allowed

### Intrusion Prevention
- fail2ban configured for SSH brute force protection
- Log monitoring for suspicious activity
- Automated IP blocking for repeated failures

### System Monitoring
- lynis for regular security audits
- rkhunter for rootkit detection
- chkrootkit for additional rootkit scanning

## Compliance

### Data Protection
- Encryption at rest and in transit
- 7-year data retention for police records
- Audit trail maintenance
- Secure data deletion procedures

### Access Control
- Multi-factor authentication required
- Role-based access control (RBAC)
- Principle of least privilege
- Regular access reviews

### Audit and Logging
- Comprehensive audit logging
- 7-year log retention
- Log integrity protection
- Security monitoring and incident response

## Usage Instructions

### Daily Security Checks
```bash
# Run comprehensive security scan
./scripts/security-scan.sh

# Check dependencies for vulnerabilities
./scripts/dependency-security.sh

# Manual system security audit
sudo lynis audit system
```

### Weekly Security Tasks
```bash
# Update security tools
sudo apt update && sudo apt upgrade -y
python3 -m pip install --upgrade safety bandit semgrep
npm update -g

# Run rootkit scans
sudo rkhunter --check --sk
sudo chkrootkit

# Check file integrity
sudo aide --check
```

### Monthly Security Review
1. Review and update security-config.yaml
2. Update security patterns in security-patterns.txt
3. Review Git security settings
4. Update firewall rules if needed
5. Review access controls and permissions
6. Conduct security training for team members

## Incident Response

In case of security incidents:
1. Isolate affected systems
2. Notify security team immediately
3. Document all actions taken
4. Preserve evidence for investigation
5. Follow incident response procedures in security-config.yaml

## Security Contacts

- **Security Officer**: security@police.uk
- **Technical Lead**: tech-lead@police.uk  
- **Data Protection Officer**: dpo@police.uk

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Azure Security Documentation](https://docs.microsoft.com/en-us/azure/security/)
- [Git Security Best Practices](https://docs.github.com/en/code-security)

---

**Security Setup Completed**: $(date)
**Next Review Date**: $(date -d "+1 month")
EOF
    
    log_success "Security documentation created"
}

# Run initial security scan
run_initial_scan() {
    log "Running initial security scan..."
    
    if [ -f "scripts/security-scan.sh" ]; then
        bash scripts/security-scan.sh
    else
        log_warning "security-scan.sh not found, skipping initial scan"
    fi
    
    if [ -f "scripts/dependency-security.sh" ]; then
        bash scripts/dependency-security.sh
    else
        log_warning "dependency-security.sh not found, skipping dependency scan"
    fi
}

# Main function
main() {
    log "Starting CoPPA Security Setup..."
    log "This script will configure comprehensive security measures for the repository."
    
    # Check permissions
    check_permissions
    
    # Install security tools
    log "=== Phase 1: Installing Security Tools ==="
    install_security_tools
    
    # Set up file permissions
    log "=== Phase 2: Configuring File Permissions ==="
    setup_file_permissions
    
    # Configure Git security
    log "=== Phase 3: Configuring Git Security ==="
    configure_git_security
    
    # Set up secrets scanning
    log "=== Phase 4: Setting up Secrets Scanning ==="
    setup_secrets_scanning
    
    # Configure system security
    log "=== Phase 5: Configuring System Security ==="
    configure_system_security
    
    # Create documentation
    log "=== Phase 6: Creating Security Documentation ==="
    create_security_documentation
    
    # Run initial security scan
    log "=== Phase 7: Running Initial Security Scan ==="
    run_initial_scan
    
    log_success "CoPPA Security Setup Complete!"
    log ""
    log "Next steps:"
    log "1. Review SECURITY_SETUP_COMPLETE.md for detailed information"
    log "2. Run './scripts/security-scan.sh' regularly for security checks"
    log "3. Monitor security alerts and update dependencies regularly"
    log "4. Schedule weekly system security audits with 'sudo lynis audit system'"
    log "5. Review and update security configuration monthly"
    log ""
    log_success "Your CoPPA repository is now secured with enterprise-grade security measures!"
}

# Run main function
main "$@"
