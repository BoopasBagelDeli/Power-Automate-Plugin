#!/usr/bin/env pwsh
# Deployment script for Power Automate Plugin
# Can be used locally or in CI/CD pipelines

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "",
    
    [Parameter(Mandatory=$false)]
    [string]$FunctionAppName = "",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$BuildOnly = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false
)

# Set colors for output
$Green = [ConsoleColor]::Green
$Yellow = [ConsoleColor]::Yellow
$Red = [ConsoleColor]::Red
$Cyan = [ConsoleColor]::Cyan
$White = [ConsoleColor]::White

Write-Host "=========================================" -ForegroundColor $Cyan
Write-Host "POWER AUTOMATE PLUGIN DEPLOYMENT" -ForegroundColor $Cyan
Write-Host "Environment: $Environment" -ForegroundColor $Cyan
Write-Host "=========================================" -ForegroundColor $Cyan

# Get version from package.json
$packageJson = Get-Content "package.json" | ConvertFrom-Json
$version = $packageJson.version
Write-Host "Deploying version: $version" -ForegroundColor $Green

# Build phase
if (-not $SkipBuild) {
    Write-Host "Building Power Automate Plugin..." -ForegroundColor $Cyan
    
    # Install Node.js dependencies
    Write-Host "Installing Node.js dependencies..." -ForegroundColor $Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Node.js dependencies" -ForegroundColor $Red
        exit 1
    }
    
    # Install Python dependencies if requirements.txt exists
    if (Test-Path "requirements.txt") {
        Write-Host "Installing Python dependencies..." -ForegroundColor $Yellow
        pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install Python dependencies" -ForegroundColor $Red
            exit 1
        }
    }
    
    # Validate schemas
    Write-Host "Validating schemas..." -ForegroundColor $Yellow
    npm run validate-schemas
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Schema validation failed, continuing..." -ForegroundColor $Yellow
    }
    
    # Build the project
    Write-Host "Building project..." -ForegroundColor $Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build failed" -ForegroundColor $Red
        exit 1
    }
    
    Write-Host "✅ Build completed successfully" -ForegroundColor $Green
}

if ($BuildOnly) {
    Write-Host "Build-only mode complete" -ForegroundColor $Green
    exit 0
}

# Deployment phase
Write-Host "Starting deployment to $Environment..." -ForegroundColor $Cyan

# Check if Azure CLI is available
$azVersion = az --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure CLI not found. Please install Azure CLI." -ForegroundColor $Red
    exit 1
}

Write-Host "Azure CLI detected" -ForegroundColor $Green

# Set default values based on environment
if ($Environment -eq "development") {
    if (-not $ResourceGroup) { $ResourceGroup = "power-automate-rg" }
    if (-not $FunctionAppName) { $FunctionAppName = "power-automate-dev-20250723" }
} else {
    if (-not $ResourceGroup) { $ResourceGroup = "power-automate-rg" }
    if (-not $FunctionAppName) { $FunctionAppName = "power-automate-prod-20250723" }
}

Write-Host "Deployment configuration:" -ForegroundColor $Yellow
Write-Host "  Resource Group: $ResourceGroup" -ForegroundColor $White
Write-Host "  Function App: $FunctionAppName" -ForegroundColor $White
Write-Host "  Subscription: $SubscriptionId" -ForegroundColor $White

# Set subscription if provided
if ($SubscriptionId) {
    Write-Host "Setting Azure subscription..." -ForegroundColor $Yellow
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to set subscription" -ForegroundColor $Red
        exit 1
    }
}

# Check if Function App exists
Write-Host "Checking if Function App exists..." -ForegroundColor $Yellow
$functionApp = az functionapp show --name $FunctionAppName --resource-group $ResourceGroup 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Function App '$FunctionAppName' not found in resource group '$ResourceGroup'" -ForegroundColor $Red
    Write-Host "Please create the Function App first or check the parameters." -ForegroundColor $Yellow
    exit 1
}

Write-Host "✅ Function App found" -ForegroundColor $Green

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor $Yellow
$deploymentPath = "dist/deployment"
if (Test-Path $deploymentPath) {
    Remove-Item -Path $deploymentPath -Recurse -Force
}
New-Item -ItemType Directory -Path $deploymentPath -Force | Out-Null

# Copy necessary files
Copy-Item -Path "src/*" -Destination $deploymentPath -Recurse -Force
Copy-Item -Path "package.json" -Destination $deploymentPath -Force
if (Test-Path "requirements.txt") {
    Copy-Item -Path "requirements.txt" -Destination $deploymentPath -Force
}
if (Test-Path "host.json") {
    Copy-Item -Path "host.json" -Destination $deploymentPath -Force
}
if (Test-Path "local.settings.json.template") {
    Copy-Item -Path "local.settings.json.template" -Destination $deploymentPath -Force
}

# Create a zip package
$zipPath = "dist/power-automate-plugin-$version.zip"
if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force
}

Write-Host "Creating zip package..." -ForegroundColor $Yellow
Compress-Archive -Path "$deploymentPath\*" -DestinationPath $zipPath -Force

# Deploy to Azure Functions
Write-Host "Deploying to Azure Functions..." -ForegroundColor $Cyan
az functionapp deployment source config-zip `
    --resource-group $ResourceGroup `
    --name $FunctionAppName `
    --src $zipPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment successful!" -ForegroundColor $Green
    
    # Get Function App URL
    $functionAppUrl = az functionapp show --name $FunctionAppName --resource-group $ResourceGroup --query "defaultHostName" -o tsv
    
    Write-Host "=========================================" -ForegroundColor $Green
    Write-Host "DEPLOYMENT COMPLETE" -ForegroundColor $Green
    Write-Host "=========================================" -ForegroundColor $Green
    Write-Host "Version: $version" -ForegroundColor $Green
    Write-Host "Environment: $Environment" -ForegroundColor $Green
    Write-Host "Function App: https://$functionAppUrl" -ForegroundColor $Green
    Write-Host "Resource Group: $ResourceGroup" -ForegroundColor $Green
    Write-Host "=========================================" -ForegroundColor $Green
    
    # Test deployment
    Write-Host "Testing deployment..." -ForegroundColor $Yellow
    $testUrl = "https://$functionAppUrl/api/health"
    try {
        $response = Invoke-RestMethod -Uri $testUrl -Method Get -ErrorAction Stop
        Write-Host "✅ Health check passed" -ForegroundColor $Green
    } catch {
        Write-Host "⚠️ Health check failed - this may be normal if no health endpoint exists" -ForegroundColor $Yellow
    }
    
} else {
    Write-Host "❌ Deployment failed" -ForegroundColor $Red
    exit 1
}

Write-Host "Deployment process completed" -ForegroundColor $Cyan
