#!/usr/bin/env pwsh
<#
.SYNOPSIS
Deploy Power Platform Connector to Default Environment

.DESCRIPTION
This script deploys the Company Data API connector to your default Power Platform environment.

.NOTES
Author: GitHub Copilot
Date: July 22, 2025
#>

Write-Host "🔌 Deploying to Default Environment: Boopas (default)" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Function to deploy connector
function Deploy-Connector {
    Write-Host "`n🚀 Deploying Company Data API Connector..." -ForegroundColor Green
    
    try {
        # Verify we're in the right environment
        $currentEnv = pac org who
        Write-Host "   🎯 Current Environment:" -ForegroundColor Yellow
        Write-Host "$currentEnv" -ForegroundColor White
        
        # Try to create the connector using paconn (if available)
        Write-Host "`n📤 Attempting connector deployment..." -ForegroundColor Yellow
        
        # Check if paconn is available
        $paconnAvailable = $false
        try {
            paconn --version 2>$null
            $paconnAvailable = $true
            Write-Host "   ✅ PowerPlatform Connector CLI (paconn) available" -ForegroundColor Green
        } catch {
            Write-Host "   ℹ️  PowerPlatform Connector CLI (paconn) not available" -ForegroundColor Yellow
        }
        
        if ($paconnAvailable) {
            # Use paconn to deploy
            Write-Host "   📦 Deploying with paconn..." -ForegroundColor Yellow
            $result = paconn create --api-def .\connector-definition.json --api-prop .\connector-properties.json
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Connector deployed successfully!" -ForegroundColor Green
                return $true
            } else {
                Write-Host "   ⚠️  Paconn deployment failed, showing manual instructions..." -ForegroundColor Yellow
                return $false
            }
        } else {
            Write-Host "   ℹ️  Using manual deployment approach..." -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "   ❌ Deployment error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to create connector properties file
function New-ConnectorProperties {
    Write-Host "`n📝 Creating connector properties..." -ForegroundColor Green
    
    $properties = @{
        "properties" = @{
            "connectionParameters" = @{
                "token" = @{
                    "type" = "oauthSetting"
                    "oAuthSettings" = @{
                        "identityProvider" = "aad"
                        "clientId" = "5bc6594b-acd4-4e3b-93af-9dabab51c541"
                        "scopes" = @("https://graph.microsoft.com/.default")
                        "redirectMode" = "Global"
                        "redirectUrl" = "https://global.consent.azure-apim.net/redirect"
                        "properties" = @{
                            "IsFirstParty" = "False"
                            "AzureActiveDirectoryResourceId" = "https://graph.microsoft.com/"
                        }
                    }
                }
            }
            "iconBrandColor" = "#0078d4"
            "capabilities" = @("actions")
            "policyTemplateInstances" = @()
        }
    }
    
    $propertiesJson = $properties | ConvertTo-Json -Depth 10
    $propertiesJson | Out-File -FilePath ".\connector-properties.json" -Encoding UTF8
    
    Write-Host "   ✅ Connector properties file created" -ForegroundColor Green
}

# Function to show manual deployment instructions
function Show-ManualDeployment {
    Write-Host "`n🔧 Manual Deployment Instructions" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Since we're using the default environment, follow these steps:" -ForegroundColor Green
    
    Write-Host "`n1. 🌐 Open Power Apps Maker Portal:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerapps.com/environments/de96b383-5f31-4895-9b41-88f3b7435919" -ForegroundColor White
    Write-Host "   (This will open directly in your default environment)" -ForegroundColor White
    
    Write-Host "`n2. 🔌 Create Custom Connector:" -ForegroundColor Yellow
    Write-Host "   • Click 'Data' → 'Custom connectors' in left menu" -ForegroundColor White
    Write-Host "   • Click '+ New custom connector' → 'Import an OpenAPI file'" -ForegroundColor White
    
    Write-Host "`n3. 📤 Upload Definition:" -ForegroundColor Yellow
    Write-Host "   • Connector name: 'Company Data API'" -ForegroundColor White
    Write-Host "   • Upload file: connector-definition.json (from this folder)" -ForegroundColor White
    Write-Host "   • Click 'Import'" -ForegroundColor White
    
    Write-Host "`n4. ⚙️ Configure General Tab:" -ForegroundColor Yellow
    Write-Host "   • Description: 'Access your company data across M365'" -ForegroundColor White
    Write-Host "   • Host: copilot-plugin-func-f46zzw7hhsh2q.azurewebsites.net" -ForegroundColor White
    Write-Host "   • Base URL: /api" -ForegroundColor White
    
    Write-Host "`n5. 🔐 Configure Security Tab:" -ForegroundColor Yellow
    Write-Host "   • Authentication type: OAuth 2.0" -ForegroundColor White
    Write-Host "   • Identity Provider: Azure Active Directory" -ForegroundColor White
    Write-Host "   • Client id: 5bc6594b-acd4-4e3b-93af-9dabab51c541" -ForegroundColor White
    Write-Host "   • Client secret: [Get from Azure AD app registration]" -ForegroundColor White
    Write-Host "   • Authorization URL: https://login.microsoftonline.com/de96b383-5f31-4895-9b41-88f3b7435919/oauth2/v2.0/authorize" -ForegroundColor White
    Write-Host "   • Token URL: https://login.microsoftonline.com/de96b383-5f31-4895-9b41-88f3b7435919/oauth2/v2.0/token" -ForegroundColor White
    Write-Host "   • Refresh URL: https://login.microsoftonline.com/de96b383-5f31-4895-9b41-88f3b7435919/oauth2/v2.0/token" -ForegroundColor White
    Write-Host "   • Scope: https://graph.microsoft.com/.default" -ForegroundColor White
    
    Write-Host "`n6. ✅ Test and Create:" -ForegroundColor Yellow
    Write-Host "   • Click 'Test' tab" -ForegroundColor White
    Write-Host "   • Create a new connection" -ForegroundColor White
    Write-Host "   • Test 'SearchCompanyData' operation" -ForegroundColor White
    Write-Host "   • Click 'Create connector' when successful" -ForegroundColor White
    
    Write-Host "`n🎯 Quick Test After Creation:" -ForegroundColor Green
    Write-Host "   • Try searching for: 'test'" -ForegroundColor White
    Write-Host "   • Data source: 'files'" -ForegroundColor White
    Write-Host "   • Max results: 10" -ForegroundColor White
}

# Function to get client secret from Azure
function Get-ClientSecret {
    Write-Host "`n🔑 Getting Client Secret..." -ForegroundColor Green
    
    try {
        # Read from app-registration.json
        $appRegPath = "..\app-registration.json"
        if (Test-Path $appRegPath) {
            $appReg = Get-Content $appRegPath | ConvertFrom-Json
            $clientSecret = $appReg.clientSecret
            
            Write-Host "   ✅ Client secret retrieved from app-registration.json" -ForegroundColor Green
            Write-Host "   🔐 Client Secret: $clientSecret" -ForegroundColor Yellow
            Write-Host "   ⚠️  Copy this secret for the connector configuration!" -ForegroundColor Red
            
            return $clientSecret
        } else {
            Write-Host "   ⚠️  app-registration.json not found in parent directory" -ForegroundColor Yellow
            Write-Host "   💡 You'll need to get the client secret from Azure AD app registration" -ForegroundColor Yellow
            return $null
        }
    } catch {
        Write-Host "   ❌ Error retrieving client secret: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Main execution
function Main {
    Write-Host "`n🎯 Environment: Boopas (default)" -ForegroundColor Green
    Write-Host "   Environment ID: de96b383-5f31-4895-9b41-88f3b7435919" -ForegroundColor White
    Write-Host "   URL: https://org29f8dd94.crm.dynamics.com/" -ForegroundColor White
    
    # Create connector properties
    New-ConnectorProperties
    
    # Get client secret
    $clientSecret = Get-ClientSecret
    
    # Attempt deployment
    $deployed = Deploy-Connector
    
    if (-not $deployed) {
        # Show manual instructions
        Show-ManualDeployment
        
        if ($clientSecret) {
            Write-Host "`n🔐 Your Client Secret for Manual Setup:" -ForegroundColor Cyan
            Write-Host "   $clientSecret" -ForegroundColor Yellow
            Write-Host "   (Copy this for the Security tab configuration)" -ForegroundColor White
        }
    }
    
    Write-Host "`n🎉 Deployment guide complete!" -ForegroundColor Green
    Write-Host "Your connector will be available in the default environment once created." -ForegroundColor Green
    
    Write-Host "`n🔗 Direct Link to Custom Connectors:" -ForegroundColor Cyan
    Write-Host "   https://make.powerapps.com/environments/de96b383-5f31-4895-9b41-88f3b7435919/customconnectors" -ForegroundColor White
}

# Execute main function
Main
