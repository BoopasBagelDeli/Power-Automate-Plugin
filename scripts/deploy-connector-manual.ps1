#!/usr/bin/env pwsh
<#
.SYNOPSIS
Simplified Power Platform Connector Deployment Script

.DESCRIPTION
This script creates and deploys a custom Power Platform connector for your Company Data API
using your existing Power Platform environment.

.NOTES
Requires: Power Platform CLI (pac) and Azure CLI
Author: GitHub Copilot
Date: July 22, 2025
#>

param(
    [string]$ConnectorName = "CompanyDataConnector",
    [string]$ConnectorDisplayName = "Company Data API",
    [string]$ApiDefinitionPath = ".\connector-definition.json"
)

Write-Host "🔌 Power Platform Connector Deployment (Simplified)" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "`n📋 Checking Prerequisites..." -ForegroundColor Green
    
    # Check Power Platform CLI
    try {
        $pacVersion = pac --version 2>$null
        if ($pacVersion) {
            Write-Host "   ✅ Power Platform CLI: Available" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Power Platform CLI: Not available" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Power Platform CLI: Not available" -ForegroundColor Red
        return $false
    }
    
    # Check API definition file
    if (Test-Path $ApiDefinitionPath) {
        Write-Host "   ✅ API Definition: Found ($ApiDefinitionPath)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ API Definition: Not found ($ApiDefinitionPath)" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# Function to show current authentication
function Show-CurrentAuth {
    Write-Host "`n🔐 Current Power Platform Authentication..." -ForegroundColor Green
    
    try {
        $auth = pac org who
        if ($auth -and $auth -notmatch "not authenticated") {
            Write-Host "   ✅ Authenticated with Power Platform" -ForegroundColor Green
            Write-Host "$auth" -ForegroundColor White
            return $true
        } else {
            Write-Host "   ❌ Not authenticated with Power Platform" -ForegroundColor Red
            Write-Host "   💡 Run: pac auth create" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "   ❌ Authentication check failed" -ForegroundColor Red
        return $false
    }
}

# Function to show available environments
function Show-Environments {
    Write-Host "`n🌍 Available Power Platform Environments..." -ForegroundColor Green
    
    try {
        $environments = pac env list
        Write-Host "$environments" -ForegroundColor White
        
        Write-Host "`n💡 To select an environment for deployment:" -ForegroundColor Yellow
        Write-Host "   pac env select --environment <ENVIRONMENT_ID>" -ForegroundColor White
        
        return $true
    } catch {
        Write-Host "   ❌ Failed to list environments" -ForegroundColor Red
        return $false
    }
}

# Function to create the connector manually
function Show-ManualConnectorCreation {
    Write-Host "`n🔧 Manual Connector Creation Instructions" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Since automated creation had issues, here's how to create the connector manually:" -ForegroundColor Yellow
    
    Write-Host "`n1. 🌐 Open Power Platform Admin Center:" -ForegroundColor Green
    Write-Host "   URL: https://admin.powerplatform.microsoft.com/" -ForegroundColor White
    Write-Host "   • Sign in with your Power Platform admin account" -ForegroundColor White
    
    Write-Host "`n2. 🏗️ Create New Environment (Optional):" -ForegroundColor Green
    Write-Host "   • Click 'Environments' → 'New'" -ForegroundColor White
    Write-Host "   • Name: 'Company Data Connector Environment'" -ForegroundColor White
    Write-Host "   • Type: Sandbox (for testing) or Production" -ForegroundColor White
    Write-Host "   • Region: United States" -ForegroundColor White
    
    Write-Host "`n3. 🔌 Create Custom Connector:" -ForegroundColor Green
    Write-Host "   URL: https://make.powerapps.com/" -ForegroundColor White
    Write-Host "   • Select your environment (top-right dropdown)" -ForegroundColor White
    Write-Host "   • Go to 'Data' → 'Custom connectors'" -ForegroundColor White
    Write-Host "   • Click 'New custom connector' → 'Import from OpenAPI file'" -ForegroundColor White
    
    Write-Host "`n4. 📤 Upload OpenAPI Definition:" -ForegroundColor Green
    Write-Host "   • Connector name: '$ConnectorDisplayName'" -ForegroundColor White
    Write-Host "   • Upload file: '$ApiDefinitionPath'" -ForegroundColor White
    Write-Host "   • Host: 'copilot-plugin-func-f46zzw7hhsh2q.azurewebsites.net'" -ForegroundColor White
    
    Write-Host "`n5. 🔐 Configure Security:" -ForegroundColor Green
    Write-Host "   • Authentication type: OAuth 2.0" -ForegroundColor White
    Write-Host "   • Identity provider: Azure Active Directory" -ForegroundColor White
    Write-Host "   • Client ID: 5bc6594b-acd4-4e3b-93af-9dabab51c541" -ForegroundColor White
    Write-Host "   • Client secret: (from Azure AD app registration)" -ForegroundColor White
    Write-Host "   • Authorization URL: https://login.microsoftonline.com/de96b383-5f31-4895-9b41-88f3b7435919/oauth2/v2.0/authorize" -ForegroundColor White
    Write-Host "   • Token URL: https://login.microsoftonline.com/de96b383-5f31-4895-9b41-88f3b7435919/oauth2/v2.0/token" -ForegroundColor White
    Write-Host "   • Scope: https://graph.microsoft.com/.default" -ForegroundColor White
    
    Write-Host "`n6. ✅ Test and Deploy:" -ForegroundColor Green
    Write-Host "   • Click 'Test' tab to verify connectivity" -ForegroundColor White
    Write-Host "   • Create a new connection to test authentication" -ForegroundColor White
    Write-Host "   • Test the SearchCompanyData operation" -ForegroundColor White
    Write-Host "   • Click 'Create connector' when tests pass" -ForegroundColor White
}

# Function to show Power Automate flow creation
function Show-FlowCreation {
    Write-Host "`n🔄 Creating Your First Power Automate Flow" -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Example: Daily Document Summary Flow" -ForegroundColor Green
    
    Write-Host "`n1. 🌐 Open Power Automate:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerautomate.com/" -ForegroundColor White
    Write-Host "   • Select your environment" -ForegroundColor White
    Write-Host "   • Click 'Create' → 'Scheduled cloud flow'" -ForegroundColor White
    
    Write-Host "`n2. ⏰ Configure Schedule:" -ForegroundColor Yellow
    Write-Host "   • Flow name: 'Daily Company Data Summary'" -ForegroundColor White
    Write-Host "   • Schedule: Daily at 8:00 AM" -ForegroundColor White
    Write-Host "   • Time zone: Your local time zone" -ForegroundColor White
    
    Write-Host "`n3. ➕ Add Company Data Search Action:" -ForegroundColor Yellow
    Write-Host "   • Click 'New step'" -ForegroundColor White
    Write-Host "   • Search for 'Company Data API'" -ForegroundColor White
    Write-Host "   • Select 'Search Company Data' action" -ForegroundColor White
    Write-Host "   • Configure search parameters:" -ForegroundColor White
    Write-Host "     - Query: 'modified:yesterday'" -ForegroundColor White
    Write-Host "     - Data Source: 'files'" -ForegroundColor White
    Write-Host "     - Max Results: 20" -ForegroundColor White
    
    Write-Host "`n4. 📧 Add Email Summary Action:" -ForegroundColor Yellow
    Write-Host "   • Click 'New step'" -ForegroundColor White
    Write-Host "   • Search for 'Send an email'" -ForegroundColor White
    Write-Host "   • Configure email with search results" -ForegroundColor White
    Write-Host "   • Use dynamic content from search results" -ForegroundColor White
    
    Write-Host "`n5. 💾 Save and Test:" -ForegroundColor Yellow
    Write-Host "   • Click 'Save'" -ForegroundColor White
    Write-Host "   • Click 'Test' → 'Manually'" -ForegroundColor White
    Write-Host "   • Verify the flow executes successfully" -ForegroundColor White
}

# Function to show Power Apps integration
function Show-PowerAppsIntegration {
    Write-Host "`n📱 Creating a Power Apps Search Interface" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Example: Company Data Search App" -ForegroundColor Green
    
    Write-Host "`n1. 🌐 Open Power Apps:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerapps.com/" -ForegroundColor White
    Write-Host "   • Select your environment" -ForegroundColor White
    Write-Host "   • Click 'Create' → 'Canvas app from blank'" -ForegroundColor White
    
    Write-Host "`n2. 🔌 Add Data Source:" -ForegroundColor Yellow
    Write-Host "   • Click 'Data' → 'Add data'" -ForegroundColor White
    Write-Host "   • Search for 'Company Data API'" -ForegroundColor White
    Write-Host "   • Select your custom connector" -ForegroundColor White
    Write-Host "   • Create a new connection" -ForegroundColor White
    
    Write-Host "`n3. 🎨 Design Interface:" -ForegroundColor Yellow
    Write-Host "   • Add Text input control for search query" -ForegroundColor White
    Write-Host "   • Add Dropdown for data source selection" -ForegroundColor White
    Write-Host "   • Add Button to trigger search" -ForegroundColor White
    Write-Host "   • Add Gallery to display results" -ForegroundColor White
    
    Write-Host "`n4. ⚡ Configure Search Logic:" -ForegroundColor Yellow
    Write-Host "   • Button OnSelect: ClearCollect(SearchResults, " -ForegroundColor White
    Write-Host "     CompanyDataAPI.SearchCompanyData({" -ForegroundColor White
    Write-Host "       query: TextInput1.Text," -ForegroundColor White
    Write-Host "       dataSource: Dropdown1.Selected.Value," -ForegroundColor White
    Write-Host "       maxResults: 20" -ForegroundColor White
    Write-Host "     }).results)" -ForegroundColor White
    
    Write-Host "`n5. 📊 Display Results:" -ForegroundColor Yellow
    Write-Host "   • Gallery Items: SearchResults" -ForegroundColor White
    Write-Host "   • Configure gallery template with:" -ForegroundColor White
    Write-Host "     - Title: ThisItem.title" -ForegroundColor White
    Write-Host "     - Subtitle: ThisItem.author" -ForegroundColor White
    Write-Host "     - Body: ThisItem.content" -ForegroundColor White
}

# Function to show environment creation via web
function Show-EnvironmentCreation {
    Write-Host "`n🏗️ Creating a New Power Platform Environment" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Steps to create a dedicated environment:" -ForegroundColor Green
    
    Write-Host "`n1. 🌐 Open Power Platform Admin Center:" -ForegroundColor Yellow
    Write-Host "   URL: https://admin.powerplatform.microsoft.com/" -ForegroundColor White
    Write-Host "   • Sign in with admin credentials" -ForegroundColor White
    
    Write-Host "`n2. ➕ Create New Environment:" -ForegroundColor Yellow
    Write-Host "   • Click 'Environments' in left navigation" -ForegroundColor White
    Write-Host "   • Click '+ New' button" -ForegroundColor White
    
    Write-Host "`n3. ⚙️ Configure Environment:" -ForegroundColor Yellow
    Write-Host "   • Name: 'Company Data Connector'" -ForegroundColor White
    Write-Host "   • Type: Sandbox (for testing)" -ForegroundColor White
    Write-Host "   • Region: United States" -ForegroundColor White
    Write-Host "   • Purpose: 'M365 Copilot Plugin Integration'" -ForegroundColor White
    Write-Host "   • Create a database: Yes" -ForegroundColor White
    Write-Host "   • Language: English" -ForegroundColor White
    Write-Host "   • Currency: USD" -ForegroundColor White
    
    Write-Host "`n4. 👥 Set Security Group (Optional):" -ForegroundColor Yellow
    Write-Host "   • Restrict access to specific users/groups" -ForegroundColor White
    Write-Host "   • Or leave open for all licensed users" -ForegroundColor White
    
    Write-Host "`n5. ✅ Create and Wait:" -ForegroundColor Yellow
    Write-Host "   • Click 'Save'" -ForegroundColor White
    Write-Host "   • Wait 2-5 minutes for environment creation" -ForegroundColor White
    Write-Host "   • Environment will appear in your list" -ForegroundColor White
    
    Write-Host "`n6. 🔄 Update PAC CLI:" -ForegroundColor Yellow
    Write-Host "   • Run: pac env list" -ForegroundColor White
    Write-Host "   • Select new environment: pac env select --environment <NEW_ENV_ID>" -ForegroundColor White
}

# Main execution
function Main {
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "`n❌ Prerequisites check failed. Please install missing components." -ForegroundColor Red
        return
    }
    
    # Show current authentication
    if (-not (Show-CurrentAuth)) {
        Write-Host "`n❌ Authentication required. Please authenticate with Power Platform first." -ForegroundColor Red
        return
    }
    
    # Show available environments
    Show-Environments
    
    # Show manual creation instructions
    Show-EnvironmentCreation
    Show-ManualConnectorCreation
    Show-FlowCreation
    Show-PowerAppsIntegration
    
    Write-Host "`n🎉 Power Platform Setup Guide Complete!" -ForegroundColor Green
    Write-Host "Follow the manual steps above to create your environment and connector." -ForegroundColor Green
    
    Write-Host "`n🔗 Quick Links:" -ForegroundColor Cyan
    Write-Host "   • Power Platform Admin: https://admin.powerplatform.microsoft.com/" -ForegroundColor White
    Write-Host "   • Power Apps: https://make.powerapps.com/" -ForegroundColor White
    Write-Host "   • Power Automate: https://make.powerautomate.com/" -ForegroundColor White
    Write-Host "   • Your Function App: https://copilot-plugin-func-f46zzw7hhsh2q.azurewebsites.net" -ForegroundColor White
}

# Execute main function
Main
