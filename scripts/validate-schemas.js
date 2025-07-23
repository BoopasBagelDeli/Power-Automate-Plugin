#!/usr/bin/env node

/**
 * Schema validation script for Power Automate Connector
 * This script validates the OpenAPI specification and schema files
 */

const fs = require('fs');
const path = require('path');
const Ajv = require('ajv');
const SwaggerParser = require('@apidevtools/swagger-parser');

// Paths to validation targets
const OPENAPI_PATH = path.join(__dirname, '..', 'src', 'declarative', 'openapi', 'openapi.json');
const SCHEMAS_PATH = path.join(__dirname, '..', 'src', 'declarative', 'schemas', 'schemas.json');
const MANIFEST_PATH = path.join(__dirname, '..', 'src', 'declarative', 'manifest.json');

// Function to validate OpenAPI spec
async function validateOpenAPI() {
    try {
        console.log('Validating OpenAPI specification...');
        // This will throw an error if the OpenAPI spec is invalid
        const api = await SwaggerParser.validate(OPENAPI_PATH);
        console.log('✅ OpenAPI specification is valid');
        console.log(`API name: ${api.info.title}`);
        console.log(`Version: ${api.info.version}`);
        return true;
    } catch (err) {
        console.error('❌ OpenAPI validation failed:');
        console.error(err);
        return false;
    }
}

// Function to validate JSON schema
async function validateSchema() {
    try {
        console.log('Validating schema definitions...');
        const schemaContent = fs.readFileSync(SCHEMAS_PATH, 'utf8');
        const schema = JSON.parse(schemaContent);
        
        // Basic validation - just check if it's valid JSON with a schemas property
        if (!schema.schemas) {
            console.error('❌ Schema validation failed: Missing "schemas" property');
            return false;
        }
        
        // Check if required schemas exist
        const requiredSchemas = ['Flow', 'FlowRun'];
        for (const required of requiredSchemas) {
            if (!schema.schemas[required]) {
                console.error(`❌ Schema validation failed: Missing required schema "${required}"`);
                return false;
            }
        }
        
        console.log('✅ Schema definitions are valid');
        return true;
    } catch (err) {
        console.error('❌ Schema validation failed:');
        console.error(err);
        return false;
    }
}

// Function to validate manifest
async function validateManifest() {
    try {
        console.log('Validating plugin manifest...');
        const manifestContent = fs.readFileSync(MANIFEST_PATH, 'utf8');
        const manifest = JSON.parse(manifestContent);
        
        // Basic validation
        const requiredProps = ['id', 'name', 'version', 'description', 'publisher', 'endpoints', 'actions'];
        for (const prop of requiredProps) {
            if (!manifest[prop]) {
                console.error(`❌ Manifest validation failed: Missing required property "${prop}"`);
                return false;
            }
        }
        
        // Validate actions
        if (!Array.isArray(manifest.actions) || manifest.actions.length === 0) {
            console.error('❌ Manifest validation failed: "actions" must be a non-empty array');
            return false;
        }
        
        console.log('✅ Plugin manifest is valid');
        return true;
    } catch (err) {
        console.error('❌ Manifest validation failed:');
        console.error(err);
        return false;
    }
}

// Main function
async function main() {
    console.log('Starting validation of Power Automate Connector...');
    
    const openApiValid = await validateOpenAPI();
    const schemaValid = await validateSchema();
    const manifestValid = await validateManifest();
    
    if (openApiValid && schemaValid && manifestValid) {
        console.log('✅ All validations passed!');
        process.exit(0);
    } else {
        console.error('❌ Validation failed. Please fix the issues and try again.');
        process.exit(1);
    }
}

main().catch(err => {
    console.error('Unexpected error during validation:');
    console.error(err);
    process.exit(1);
});
