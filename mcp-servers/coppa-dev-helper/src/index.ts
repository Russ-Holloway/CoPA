#!/usr/bin/env node

import { ReactComponentHelper } from './helpers/reactComponentHelper.js';
import { FlaskRouteHelper } from './helpers/flaskRouteHelper.js';
import { TypeScriptHelper } from './helpers/typeScriptHelper.js';
import { AccessibilityHelper } from './helpers/accessibilityHelper.js';
import { SecurityHelper } from './helpers/securityHelper.js';
import * as readline from 'readline';

class CoPPADevHelperServer {
  private reactHelper: ReactComponentHelper;
  private flaskHelper: FlaskRouteHelper;
  private tsHelper: TypeScriptHelper;
  private a11yHelper: AccessibilityHelper;
  private securityHelper: SecurityHelper;

  constructor() {
    this.reactHelper = new ReactComponentHelper();
    this.flaskHelper = new FlaskRouteHelper();
    this.tsHelper = new TypeScriptHelper();
    this.a11yHelper = new AccessibilityHelper();
    this.securityHelper = new SecurityHelper();
  }

  async handleRequest(method: string, params: any): Promise<any> {
    try {
      switch (method) {
        // React/Frontend Methods
        case 'generate_react_component':
          return await this.reactHelper.generateComponent(params);
        case 'add_component_props':
          return await this.reactHelper.addProps(params);
        case 'create_api_hook':
          return await this.reactHelper.createApiHook(params);
        case 'generate_css_module':
          return await this.reactHelper.generateCSSModule(params);
        
        // Flask/Backend Methods
        case 'create_flask_route':
          return await this.flaskHelper.createRoute(params);
        case 'add_route_authentication':
          return await this.flaskHelper.addAuthentication(params);
        case 'create_api_model':
          return await this.flaskHelper.createModel(params);
        case 'add_cosmos_db_integration':
          return await this.flaskHelper.addCosmosDBIntegration(params);
        
        // TypeScript Methods
        case 'create_typescript_interface':
          return await this.tsHelper.createInterface(params);
        case 'add_type_definitions':
          return await this.tsHelper.addTypeDefinitions(params);
        case 'generate_api_types':
          return await this.tsHelper.generateApiTypes(params);
        
        // Accessibility Methods
        case 'check_accessibility_compliance':
          return await this.a11yHelper.checkCompliance(params);
        case 'add_aria_labels':
          return await this.a11yHelper.addAriaLabels(params);
        case 'generate_accessible_form':
          return await this.a11yHelper.generateAccessibleForm(params);
        
        // Security Methods
        case 'check_security_patterns':
          return await this.securityHelper.checkSecurityPatterns(params);
        case 'add_input_validation':
          return await this.securityHelper.addInputValidation(params);
        case 'check_sensitive_data_handling':
          return await this.securityHelper.checkSensitiveDataHandling(params);
        
        default:
          throw new Error(`Unknown method: ${method}`);
      }
    } catch (error) {
      throw new Error(`Error in ${method}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  async run() {
    console.log('CoPPA Dev Helper MCP Server started');
    console.log('Designed specifically for CoPPA police chat application development');
    
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    console.log('\n🚀 Available methods:');
    console.log('\n📱 React/Frontend:');
    console.log('- generate_react_component');
    console.log('- add_component_props');
    console.log('- create_api_hook');
    console.log('- generate_css_module');
    
    console.log('\n🔧 Flask/Backend:');
    console.log('- create_flask_route');
    console.log('- add_route_authentication');
    console.log('- create_api_model');
    console.log('- add_cosmos_db_integration');
    
    console.log('\n📝 TypeScript:');
    console.log('- create_typescript_interface');
    console.log('- add_type_definitions');
    console.log('- generate_api_types');
    
    console.log('\n♿ Accessibility (WCAG 2.1 AA):');
    console.log('- check_accessibility_compliance');
    console.log('- add_aria_labels');
    console.log('- generate_accessible_form');
    
    console.log('\n🛡️ Security (Police Data):');
    console.log('- check_security_patterns');
    console.log('- add_input_validation');
    console.log('- check_sensitive_data_handling');
    
    console.log('\nType method name followed by JSON parameters, or "exit" to quit');

    rl.on('line', async (input: string) => {
      if (input.trim() === 'exit') {
        rl.close();
        return;
      }

      try {
        const [method, ...paramsParts] = input.split(' ');
        const paramsJson = paramsParts.join(' ');
        const params = paramsJson ? JSON.parse(paramsJson) : {};
        
        const result = await this.handleRequest(method, params);
        console.log('\n✅ Result:');
        console.log(JSON.stringify(result, null, 2));
      } catch (error) {
        console.error('\n❌ Error:', error instanceof Error ? error.message : String(error));
      }
      
      console.log('\nNext command:');
    });
  }
}

const server = new CoPPADevHelperServer();
server.run().catch(console.error);
