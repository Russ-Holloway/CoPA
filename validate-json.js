const fs = require('fs');
const path = require('path');

try {
    // Path to the JSON file
    const filePath = path.join(__dirname, 'infrastructure', 'deployment.json');
    
    // Read the file
    const jsonContent = fs.readFileSync(filePath, 'utf8');
    
    // Try to parse it
    JSON.parse(jsonContent);
    
    console.log('✅ JSON syntax validation successful!');
} catch (error) {
    console.error('❌ JSON validation failed:', error.message);
    
    // If it's a JSON parse error, try to provide more context
    if (error instanceof SyntaxError) {
        const match = error.message.match(/position (\d+)/);
        if (match && match[1]) {
            const position = parseInt(match[1]);
            const jsonContent = fs.readFileSync(path.join(__dirname, 'infrastructure', 'deployment.json'), 'utf8');
            
            // Extract the context around the error
            const start = Math.max(0, position - 20);
            const end = Math.min(jsonContent.length, position + 20);
            const context = jsonContent.substring(start, end);
            
            console.error('Error context:');
            console.error(context);
            console.error(' '.repeat(Math.min(20, position - start)) + '^');
        }
    }
    
    process.exit(1);
}
