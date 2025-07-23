#!/usr/bin/env pwsh
<#
.SYNOPSIS
Power Automate Connector Deployment Script

.DESCRIPTION
This script creates and deploys a custom Power Platform connector for your Company Data API,
enabling Power Automate flows, Power Apps, and Power BI to access your M365 data.

.NOTES
Requires: Power Platform CLI (pac) and Azure CLI
Author: GitHub Copilot
Date: July 22, 2025
#>

param(
    [string]$Environment = "",
    [string]$ConnectorName = "CompanyDataConnector",
    [string]$ConnectorDisplayName = "Company Data API",
    [string]$ApiDefinitionPath = ".\connector-definition.json"
)

Write-Host "🔌 Power Platform Connector Deployment" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

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
            Write-Host "   💡 Install: https://aka.ms/PowerPlatformCLI" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "   ❌ Power Platform CLI: Not available" -ForegroundColor Red
        return $false
    }
    
    # Check Azure CLI
    try {
        $azVersion = az --version 2>$null
        if ($azVersion) {
            Write-Host "   ✅ Azure CLI: Available" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Azure CLI: Not available" -ForegroundColor Red
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

# Function to authenticate with Power Platform
function Connect-PowerPlatform {
    Write-Host "`n🔐 Authenticating with Power Platform..." -ForegroundColor Green
    
    try {
        # Check if already authenticated
        $currentAuth = pac org who 2>$null
        if ($currentAuth -and $currentAuth -notmatch "not authenticated") {
            Write-Host "   ✅ Already authenticated with Power Platform" -ForegroundColor Green
            return $true
        }
        
        # Authenticate
        Write-Host "   🔑 Starting authentication flow..." -ForegroundColor Yellow
        pac auth create --name "CompanyDataDeployment"
        
        $authCheck = pac org who 2>$null
        if ($authCheck -and $authCheck -notmatch "not authenticated") {
            Write-Host "   ✅ Successfully authenticated with Power Platform" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ Authentication failed" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Authentication error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to list and select environment
function Select-Environment {
    Write-Host "`n🌍 Power Platform Environment Selection..." -ForegroundColor Green
    
    if ($Environment) {
        Write-Host "   🎯 Using specified environment: $Environment" -ForegroundColor Yellow
        return $Environment
    }
    
    try {
        # List available environments
        Write-Host "   📋 Retrieving available environments..." -ForegroundColor Yellow
        $environments = pac env list --json | ConvertFrom-Json
        
        if ($environments.Count -eq 0) {
            Write-Host "   ❌ No environments found" -ForegroundColor Red
            return $null
        }
        
        Write-Host "   📍 Available environments:" -ForegroundColor White
        for ($i = 0; $i -lt $environments.Count; $i++) {
            $env = $environments[$i]
            Write-Host "      [$i] $($env.DisplayName) ($($env.EnvironmentName))" -ForegroundColor White
        }
        
        # Auto-select if only one environment
        if ($environments.Count -eq 1) {
            $selectedEnv = $environments[0].EnvironmentName
            Write-Host "   ✅ Auto-selected: $selectedEnv" -ForegroundColor Green
            return $selectedEnv
        }
        
        # Prompt for selection
        do {
            $selection = Read-Host "   🔢 Select environment [0-$($environments.Count-1)]"
        } while ($selection -notmatch '^\d+$' -or [int]$selection -ge $environments.Count)
        
        $selectedEnv = $environments[[int]$selection].EnvironmentName
        Write-Host "   ✅ Selected: $selectedEnv" -ForegroundColor Green
        return $selectedEnv
        
    } catch {
        Write-Host "   ❌ Failed to retrieve environments: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to create the custom connector
function New-CustomConnector {
    param(
        [string]$EnvironmentName,
        [string]$Name,
        [string]$DisplayName,
        [string]$DefinitionPath
    )
    
    Write-Host "`n🔧 Creating Custom Connector..." -ForegroundColor Green
    
    try {
        # Set the environment
        pac env select --environment $EnvironmentName
        Write-Host "   🎯 Environment set: $EnvironmentName" -ForegroundColor Yellow
        
        # Create the connector
        Write-Host "   🚀 Creating connector '$DisplayName'..." -ForegroundColor Yellow
        
        $result = pac connector create --definition-file $DefinitionPath --connector-name $Name --display-name $DisplayName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Connector created successfully!" -ForegroundColor Green
            Write-Host "   📝 Name: $Name" -ForegroundColor White
            Write-Host "   📝 Display Name: $DisplayName" -ForegroundColor White
            return $true
        } else {
            Write-Host "   ❌ Connector creation failed" -ForegroundColor Red
            Write-Host "   📄 Output: $result" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "   ❌ Error creating connector: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to show next steps
function Show-NextSteps {
    param([string]$EnvironmentName, [string]$ConnectorDisplayName)
    
    Write-Host "`n🎯 Next Steps" -ForegroundColor Cyan
    Write-Host "=============" -ForegroundColor Cyan
    
    Write-Host "`n1. 🌐 Configure Connector in Power Platform:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerapps.com/environments/$EnvironmentName/connections" -ForegroundColor White
    Write-Host "   • Find '$ConnectorDisplayName' in custom connectors" -ForegroundColor White
    Write-Host "   • Test the connection" -ForegroundColor White
    Write-Host "   • Configure OAuth 2.0 authentication" -ForegroundColor White
    
    Write-Host "`n2. 🔄 Create Power Automate Flows:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerautomate.com/environments/$EnvironmentName" -ForegroundColor White
    Write-Host "   • Use the custom connector in your flows" -ForegroundColor White
    Write-Host "   • Leverage the SearchCompanyData action" -ForegroundColor White
    Write-Host "   • Access files, emails, teams data, and user activity" -ForegroundColor White
    
    Write-Host "`n3. 📱 Integrate with Power Apps:" -ForegroundColor Yellow
    Write-Host "   URL: https://make.powerapps.com/environments/$EnvironmentName" -ForegroundColor White
    Write-Host "   • Add the connector as a data source" -ForegroundColor White
    Write-Host "   • Build apps that search company data" -ForegroundColor White
    Write-Host "   • Create rich user experiences" -ForegroundColor White
    
    Write-Host "`n4. 📊 Power BI Integration:" -ForegroundColor Yellow
    Write-Host "   • Use the connector in Power BI Desktop" -ForegroundColor White
    Write-Host "   • Create reports and dashboards" -ForegroundColor White
    Write-Host "   • Analyze company data trends" -ForegroundColor White
    
    Write-Host "`n5. 🧪 Test Integration:" -ForegroundColor Yellow
    Write-Host "   • Create a simple flow to test data retrieval" -ForegroundColor White
    Write-Host "   • Verify authentication is working" -ForegroundColor White
    Write-Host "   • Check data access permissions" -ForegroundColor White
}

# Function to show usage examples
function Show-UsageExamples {
    Write-Host "`n💡 Usage Examples" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    Write-Host "`n📋 Power Automate Flow Examples:" -ForegroundColor Green
    
    Write-Host "`n   1. 📄 Daily Document Summary:" -ForegroundColor Yellow
    Write-Host "      • Trigger: Scheduled (daily)" -ForegroundColor White
    Write-Host "      • Action: Search for files modified in last 24 hours" -ForegroundColor White
    Write-Host "      • Action: Send summary email to team" -ForegroundColor White
    
    Write-Host "`n   2. 📧 Smart Email Insights:" -ForegroundColor Yellow
    Write-Host "      • Trigger: When email received" -ForegroundColor White
    Write-Host "      • Action: Search for related company documents" -ForegroundColor White
    Write-Host "      • Action: Add relevant links to email reply" -ForegroundColor White
    
    Write-Host "`n   3. 👥 Team Collaboration Tracker:" -ForegroundColor Yellow
    Write-Host "      • Trigger: Scheduled (weekly)" -ForegroundColor White
    Write-Host "      • Action: Get user activity data for team members" -ForegroundColor White
    Write-Host "      • Action: Generate collaboration report" -ForegroundColor White
    
    Write-Host "`n📱 Power Apps Examples:" -ForegroundColor Green
    
    Write-Host "`n   1. 🔍 Company Search App:" -ForegroundColor Yellow
    Write-Host "      • Search interface for all company data" -ForegroundColor White
    Write-Host "      • Filter by data source, date, author" -ForegroundColor White
    Write-Host "      • Quick access to documents and emails" -ForegroundColor White
    
    Write-Host "`n   2. 📊 Personal Dashboard:" -ForegroundColor Yellow
    Write-Host "      • Show user's recent activity" -ForegroundColor White
    Write-Host "      • Display relevant documents" -ForegroundColor White
    Write-Host "      • Quick access to frequently used files" -ForegroundColor White
}

# Main execution
function Main {
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "`n❌ Prerequisites check failed. Please install missing components." -ForegroundColor Red
        return
    }
    
    # Authenticate with Power Platform
    if (-not (Connect-PowerPlatform)) {
        Write-Host "`n❌ Power Platform authentication failed." -ForegroundColor Red
        return
    }
    
    # Select environment
    $selectedEnvironment = Select-Environment
    if (-not $selectedEnvironment) {
        Write-Host "`n❌ Environment selection failed." -ForegroundColor Red
        return
    }
    
    # Create the custom connector
    $success = New-CustomConnector -EnvironmentName $selectedEnvironment -Name $ConnectorName -DisplayName $ConnectorDisplayName -DefinitionPath $ApiDefinitionPath
    
    if ($success) {
        Write-Host "`n🎉 Custom Connector Deployed Successfully!" -ForegroundColor Green
        Show-NextSteps -EnvironmentName $selectedEnvironment -ConnectorDisplayName $ConnectorDisplayName
        Show-UsageExamples
    } else {
        Write-Host "`n❌ Connector deployment failed." -ForegroundColor Red
    }
    
    Write-Host "`n✅ Power Platform connector setup complete!" -ForegroundColor Cyan
}

# Execute main function
Main
