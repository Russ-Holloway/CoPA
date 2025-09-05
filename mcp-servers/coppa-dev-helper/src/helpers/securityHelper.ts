export interface SecurityCheckParams {
  code?: string;
  language: 'typescript' | 'python' | 'javascript';
  context: 'frontend' | 'backend' | 'api';
}

export interface InputValidationParams {
  fieldName: string;
  fieldType: string;
  validationRules?: string[];
  context: 'user_input' | 'api_parameter' | 'form_data';
}

export interface SensitiveDataCheckParams {
  code?: string;
  dataType?: 'personal' | 'police' | 'operational' | 'authentication';
}

export class SecurityHelper {
  async checkSecurityPatterns(params: SecurityCheckParams): Promise<any> {
    try {
      const { code, language, context } = params;
      
      const securityIssues = this.analyzeSecurityPatterns(code, language, context);
      const recommendations = this.generateSecurityRecommendations(language, context);
      
      return {
        success: true,
        securityIssues,
        recommendations,
        coPPASecurityStandards: this.getCoPPASecurityStandards(),
        policeDataGuidelines: this.getPoliceDataGuidelines(),
        score: this.calculateSecurityScore(securityIssues)
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async addInputValidation(params: InputValidationParams): Promise<any> {
    try {
      const { fieldName, fieldType, validationRules = [], context } = params;
      
      const validationCode = this.generateInputValidation(fieldName, fieldType, validationRules, context);
      
      return {
        success: true,
        validationCode,
        implementation: {
          frontend: this.generateFrontendValidation(fieldName, fieldType),
          backend: this.generateBackendValidation(fieldName, fieldType),
        },
        securityNotes: [
          'Always validate on both client and server side',
          'Use whitelist validation instead of blacklist',
          'Sanitize all input before processing or storage',
          'Log validation failures for security monitoring'
        ],
        policeDataConsiderations: [
          'Never log sensitive police data in validation errors',
          'Use secure error messages that don\'t expose system information',
          'Implement rate limiting for repeated validation failures',
          'Follow data retention policies for validation logs'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async checkSensitiveDataHandling(params: SensitiveDataCheckParams): Promise<any> {
    try {
      const { code, dataType } = params;
      
      const dataHandlingIssues = this.analyzeSensitiveDataHandling(code, dataType);
      const complianceChecks = this.performComplianceChecks(dataType);
      
      return {
        success: true,
        dataHandlingIssues,
        complianceChecks,
        gdprRequirements: this.getGDPRRequirements(),
        policeDataProtectionAct: this.getPoliceDataProtectionRequirements(),
        recommendations: [
          'Encrypt all sensitive data at rest and in transit',
          'Implement proper access controls and audit logging',
          'Use data minimization principles - only collect what\'s needed',
          'Provide data subject rights mechanisms (access, deletion, etc.)',
          'Regular security audits and penetration testing'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  private analyzeSecurityPatterns(code?: string, language?: string, context?: string): any[] {
    const issues = [];

    // Common security pattern checks
    if (code) {
      // SQL Injection checks
      if (code.includes('SELECT') && code.includes('+')) {
        issues.push({
          type: 'SQL Injection Risk',
          severity: 'high',
          message: 'Potential SQL injection vulnerability detected',
          recommendation: 'Use parameterized queries or ORM methods'
        });
      }

      // XSS checks
      if (code.includes('innerHTML') || code.includes('dangerouslySetInnerHTML')) {
        issues.push({
          type: 'XSS Risk',
          severity: 'high',
          message: 'Potential Cross-Site Scripting vulnerability',
          recommendation: 'Use safe DOM manipulation methods and sanitize input'
        });
      }

      // Hardcoded secrets
      if (code.includes('password') || code.includes('secret') || code.includes('key')) {
        issues.push({
          type: 'Hardcoded Secrets',
          severity: 'medium',
          message: 'Potential hardcoded secrets detected',
          recommendation: 'Use environment variables or secure key management'
        });
      }

      // Logging sensitive data
      if (code.includes('console.log') || code.includes('print(')) {
        issues.push({
          type: 'Information Disclosure',
          severity: 'medium',
          message: 'Potential sensitive data logging detected',
          recommendation: 'Avoid logging sensitive police data'
        });
      }
    }

    return issues;
  }

  private generateSecurityRecommendations(language: string, context: string): string[] {
    const recommendations = [];

    if (language === 'typescript' || language === 'javascript') {
      recommendations.push('Use TypeScript strict mode for type safety');
      recommendations.push('Implement Content Security Policy (CSP) headers');
      recommendations.push('Use HTTPS for all communications');
      recommendations.push('Validate and sanitize all user input');
    }

    if (language === 'python') {
      recommendations.push('Use parameterized queries for database operations');
      recommendations.push('Implement proper error handling without exposing system details');
      recommendations.push('Use secure session management');
      recommendations.push('Apply principle of least privilege');
    }

    if (context === 'frontend') {
      recommendations.push('Implement proper authentication state management');
      recommendations.push('Use secure cookie attributes (HttpOnly, Secure, SameSite)');
      recommendations.push('Validate data on both client and server side');
    }

    if (context === 'backend') {
      recommendations.push('Implement rate limiting and throttling');
      recommendations.push('Use secure communication protocols (TLS 1.2+)');
      recommendations.push('Implement proper audit logging');
    }

    return recommendations;
  }

  private getCoPPASecurityStandards(): string[] {
    return [
      'All police data must be encrypted at rest and in transit',
      'Implement multi-factor authentication for all user accounts',
      'Use role-based access control (RBAC) for feature access',
      'Maintain comprehensive audit logs for all system access',
      'Regular security assessments and penetration testing',
      'Follow NCSC (National Cyber Security Centre) guidelines',
      'Implement data loss prevention (DLP) measures',
      'Use approved cryptographic algorithms and key lengths'
    ];
  }

  private getPoliceDataGuidelines(): string[] {
    return [
      'Never log operational police data in plain text',
      'Implement data masking for non-production environments',
      'Follow data retention policies for different data types',
      'Ensure data sovereignty - police data must remain in UK',
      'Implement proper data anonymization for analytics',
      'Use secure communication channels for sensitive operations',
      'Regular training on data protection for all developers',
      'Incident response procedures for data breaches'
    ];
  }

  private calculateSecurityScore(issues: any[]): number {
    if (issues.length === 0) return 100;
    
    const totalDeductions = issues.reduce((total, issue) => {
      switch (issue.severity) {
        case 'high': return total + 30;
        case 'medium': return total + 15;
        case 'low': return total + 5;
        default: return total + 10;
      }
    }, 0);
    
    return Math.max(0, 100 - totalDeductions);
  }

  private generateInputValidation(fieldName: string, fieldType: string, validationRules: string[], context: string): any {
    const validation = {
      fieldName,
      fieldType,
      context,
      rules: [...validationRules]
    };

    // Add default validation rules based on field type
    switch (fieldType) {
      case 'email':
        validation.rules.push('Valid email format required');
        validation.rules.push('Maximum 255 characters');
        break;
      case 'password':
        validation.rules.push('Minimum 8 characters');
        validation.rules.push('Must contain uppercase, lowercase, number, and special character');
        break;
      case 'text':
        validation.rules.push('No script tags allowed');
        validation.rules.push('Maximum length validation');
        break;
    }

    return validation;
  }

  private generateFrontendValidation(fieldName: string, fieldType: string): string {
    let validationCode = `
// Frontend validation for ${fieldName}
const validate${fieldName.charAt(0).toUpperCase() + fieldName.slice(1)} = (value: string): string | null => {
  if (!value || value.trim() === '') {
    return '${fieldName} is required';
  }`;

    switch (fieldType) {
      case 'email':
        validationCode += `
  
  const emailRegex = /^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/;
  if (!emailRegex.test(value)) {
    return 'Please enter a valid email address';
  }
  
  if (value.length > 255) {
    return 'Email address is too long';
  }`;
        break;

      case 'password':
        validationCode += `
  
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  
  if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]/.test(value)) {
    return 'Password must contain uppercase, lowercase, number, and special character';
  }`;
        break;

      case 'text':
        validationCode += `
  
  // Prevent XSS attempts
  if (/<script|javascript:|on\\w+=/i.test(value)) {
    return 'Invalid characters detected';
  }
  
  if (value.length > 1000) {
    return 'Text is too long (maximum 1000 characters)';
  }`;
        break;
    }

    validationCode += `
  
  return null; // Valid
};`;

    return validationCode;
  }

  private generateBackendValidation(fieldName: string, fieldType: string): string {
    let validationCode = `
# Backend validation for ${fieldName}
def validate_${fieldName}(value: str) -> tuple[bool, str]:
    """
    Validate ${fieldName} input
    Returns: (is_valid, error_message)
    """
    if not value or not value.strip():
        return False, "${fieldName} is required"
    
    # Sanitize input
    value = value.strip()`;

    switch (fieldType) {
      case 'email':
        validationCode += `
    
    import re
    email_pattern = r'^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$'
    if not re.match(email_pattern, value):
        return False, "Invalid email format"
    
    if len(value) > 255:
        return False, "Email address too long"`;
        break;

      case 'password':
        validationCode += `
    
    import re
    if len(value) < 8:
        return False, "Password too short"
    
    if not re.match(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])', value):
        return False, "Password complexity requirements not met"`;
        break;

      case 'text':
        validationCode += `
    
    import re
    # Check for potential XSS
    if re.search(r'<script|javascript:|on\\w+=', value, re.IGNORECASE):
        logging.warning(f"XSS attempt detected in ${fieldName}")
        return False, "Invalid input detected"
    
    if len(value) > 1000:
        return False, "Input too long"`;
        break;
    }

    validationCode += `
    
    return True, ""  # Valid`;

    return validationCode;
  }

  private analyzeSensitiveDataHandling(code?: string, dataType?: string): any[] {
    const issues: any[] = [];

    if (code && dataType === 'police') {
      // Check for potential police data exposure
      const policeDataPatterns = [
        'badge_number', 'officer_id', 'case_number', 'incident_id',
        'warrant_number', 'arrest_record', 'investigation'
      ];

      policeDataPatterns.forEach(pattern => {
        if (code.includes(pattern) && (code.includes('console.log') || code.includes('print('))) {
          issues.push({
            type: 'Police Data Exposure',
            severity: 'critical',
            message: `Potential police data logging detected: ${pattern}`,
            recommendation: 'Remove logging of sensitive police data'
          });
        }
      });
    }

    return issues;
  }

  private performComplianceChecks(dataType?: string): any[] {
    const checks = [];

    checks.push({
      standard: 'GDPR',
      requirement: 'Data minimization',
      status: 'review_required',
      description: 'Only collect and process data that is necessary'
    });

    checks.push({
      standard: 'GDPR',
      requirement: 'Right to be forgotten',
      status: 'review_required',
      description: 'Implement data deletion capabilities'
    });

    if (dataType === 'police') {
      checks.push({
        standard: 'Police Data Protection Act 2018',
        requirement: 'Lawful basis for processing',
        status: 'review_required',
        description: 'Ensure lawful basis for police data processing'
      });

      checks.push({
        standard: 'NCSC Guidelines',
        requirement: 'Security controls',
        status: 'review_required',
        description: 'Implement appropriate security controls for police data'
      });
    }

    return checks;
  }

  private getGDPRRequirements(): string[] {
    return [
      'Lawful basis for data processing must be established',
      'Data subjects must be informed about data processing',
      'Implement data protection by design and by default',
      'Conduct Data Protection Impact Assessments (DPIA) when required',
      'Maintain records of processing activities',
      'Implement appropriate technical and organizational measures',
      'Notify authorities of data breaches within 72 hours',
      'Provide data subject rights (access, rectification, erasure, etc.)'
    ];
  }

  private getPoliceDataProtectionRequirements(): string[] {
    return [
      'Police Data Protection Act 2018 provides specific provisions for law enforcement',
      'Different lawful bases apply for law enforcement processing',
      'Enhanced security measures required for police operational data',
      'Special provisions for covert operations and national security',
      'Data subject rights may be restricted in certain circumstances',
      'Regular review of data retention periods',
      'Staff training on data protection in law enforcement context',
      'International data transfers require additional safeguards'
    ];
  }
}
