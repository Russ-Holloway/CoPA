#!/usr/bin/env node

import { ARMTemplateValidator } from './validators/armTemplateValidator.js';
import { IdentityReferenceHelper } from './helpers/identityReferenceHelper.js';
import { BestPracticesChecker } from './helpers/bestPracticesChecker.js';
import * as readline from 'readline';

class AzureARMHelperServer {
  private validator: ARMTemplateValidator;
  private identityHelper: IdentityReferenceHelper;
  private bestPracticesChecker: BestPracticesChecker;

  constructor() {
    this.validator = new ARMTemplateValidator();
    this.identityHelper = new IdentityReferenceHelper();
    this.bestPracticesChecker = new BestPracticesChecker();
  }

  async handleRequest(method: string, params: any): Promise<any> {
    try {
      switch (method) {
        case 'validate_arm_template':
          return await this.validator.validate(params);
        case 'fix_identity_reference':
          return await this.identityHelper.generateCorrectReference(params);
        case 'check_best_practices':
          return await this.bestPracticesChecker.check(params);
        case 'analyze_dependencies':
          return await this.validator.analyzeDependencies(params);
        case 'suggest_role_assignment_pattern':
          return await this.identityHelper.suggestRoleAssignmentPattern(params);
        default:
          throw new Error(`Unknown method: ${method}`);
      }
    } catch (error) {
      throw new Error(`Error in ${method}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  async run() {
    console.log('Azure ARM Helper MCP Server started');
    
    // For now, we'll create a simple command line interface
    // In a full MCP implementation, this would use the MCP SDK
    
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    console.log('Available methods:');
    console.log('- validate_arm_template');
    console.log('- fix_identity_reference');  
    console.log('- check_best_practices');
    console.log('- analyze_dependencies');
    console.log('- suggest_role_assignment_pattern');
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
        console.log(JSON.stringify(result, null, 2));
      } catch (error) {
        console.error('Error:', error instanceof Error ? error.message : String(error));
      }
      
      console.log('\nNext command:');
    });
  }
}

const server = new AzureARMHelperServer();
server.run().catch(console.error);
