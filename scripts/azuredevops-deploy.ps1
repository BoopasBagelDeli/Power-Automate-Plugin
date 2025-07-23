#!/usr/bin/env pwsh
# Script for deploying Power Automate Connector using Azure DevOps agents

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [string]$FunctionAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

# Set colors for output
$Green = [ConsoleColor]::Green
$Yellow = [ConsoleColor]::Yellow
$Red = [ConsoleColor]::Red
$Cyan = [ConsoleColor]::Cyan

# Display header
Write-Host "┌──────────────────────────────────────────────┐" -ForegroundColor $Cyan
Write-Host "│ Power Automate Connector CI/CD Deployment    │" -ForegroundColor $Cyan
Write-Host "└──────────────────────────────────────────────┘" -ForegroundColor $Cyan

# Set subscription
Write-Host "Setting Azure subscription: $SubscriptionId" -ForegroundColor $Cyan
az account set --subscription $SubscriptionId
Write-Host "✓ Using subscription: $SubscriptionId" -ForegroundColor $Green

# Check resource group
$resourceGroupExists = az group show --name $ResourceGroup --query "name" -o tsv 2>$null
if (-not $resourceGroupExists) {
    Write-Host "✗ Resource group $ResourceGroup does not exist" -ForegroundColor $Red
    exit 1
}
Write-Host "✓ Using resource group: $ResourceGroup" -ForegroundColor $Green

# Check Function App
$functionAppExists = az functionapp show --name $FunctionAppName --resource-group $ResourceGroup --query "name" -o tsv 2>$null
if (-not $functionAppExists) {
    Write-Host "✗ Function App $FunctionAppName does not exist in resource group $ResourceGroup" -ForegroundColor $Red
    exit 1
}
Write-Host "✓ Using Function App: $FunctionAppName" -ForegroundColor $Green

# Deploy the connector
Write-Host "Deploying Power Automate connector to Function App..." -ForegroundColor $Cyan

# Get paths
$scriptDir = $PSScriptRoot
$sourceDir = Join-Path $scriptDir ".." "src"
$declarativeDir = Join-Path $sourceDir "declarative"
$distDir = Join-Path $scriptDir ".." "dist"

# Check if dist directory exists
if (-not (Test-Path $distDir)) {
    Write-Host "Creating dist directory..." -ForegroundColor $Yellow
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

# Copy declarative files to dist
Write-Host "Preparing deployment package..." -ForegroundColor $Cyan
Copy-Item -Path "$declarativeDir\*" -Destination $distDir -Recurse -Force
Copy-Item -Path "$sourceDir\*" -Destination $distDir -Recurse -Force -Exclude "declarative"

# Create a deployment package
$zipFile = Join-Path $env:TEMP "power-automate-deploy.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Write-Host "Creating deployment package: $zipFile" -ForegroundColor $Yellow
Compress-Archive -Path "$distDir\*" -DestinationPath $zipFile -Force

# Deploy to Azure Function App
Write-Host "Deploying to Azure Function App..." -ForegroundColor $Cyan
az functionapp deployment source config-zip -g $ResourceGroup -n $FunctionAppName --src $zipFile

# Configure environment settings
Write-Host "Configuring Function App settings for environment: $Environment" -ForegroundColor $Cyan
az functionapp config appsettings set --name $FunctionAppName --resource-group $ResourceGroup --settings "ENVIRONMENT=$Environment" "DEPLOYMENT_SOURCE=AzureDevOps" "LAST_DEPLOYED=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Output success message
Write-Host "┌──────────────────────────────────────────────┐" -ForegroundColor $Green
Write-Host "│ Deployment Completed Successfully            │" -ForegroundColor $Green
Write-Host "└──────────────────────────────────────────────┘" -ForegroundColor $Green
Write-Host "Function App: $FunctionAppName" -ForegroundColor $Green
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor $Green
Write-Host "Environment: $Environment" -ForegroundColor $Green
Write-Host "Endpoint URL: https://$FunctionAppName.azurewebsites.net/api" -ForegroundColor $Green

exit 0
