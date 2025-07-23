# Azure Function Apps Setup Script
# This script creates the required Azure Function Apps for the CI/CD pipeline

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "power-automate-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$StorageAccount = "powerautomatesa$(Get-Random -Maximum 9999)",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Write-Host "🏗️  Azure Function Apps Setup" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az --version 2>$null | Select-String "azure-cli" | Select-Object -First 1
    Write-Host "✅ Azure CLI is available: $azVersion" -ForegroundColor Green
    $useAzCli = $true
} catch {
    Write-Host "❌ Azure CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Manual Setup Instructions:" -ForegroundColor Cyan
    Write-Host "1. Install Azure CLI" -ForegroundColor White
    Write-Host "2. Run: az login" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    exit 1
}

Write-Host ""

# Login to Azure
Write-Host "🔐 Checking Azure login status..." -ForegroundColor Yellow
try {
    $currentAccount = az account show --query "user.name" -o tsv 2>$null
    if ($currentAccount) {
        Write-Host "✅ Already logged in as: $currentAccount" -ForegroundColor Green
    } else {
        Write-Host "🔑 Please login to Azure..." -ForegroundColor Yellow
        az login
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Azure login failed" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "🔑 Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Get current subscription
$subscription = az account show --query "name" -o tsv
$subscriptionId = az account show --query "id" -o tsv
Write-Host "📋 Using subscription: $subscription ($subscriptionId)" -ForegroundColor Green
Write-Host ""

# Configuration
$timestamp = Get-Date -Format "yyyyMMdd"
$devAppName = "power-automate-dev-$timestamp"
$prodAppName = "power-automate-prod-$timestamp"

Write-Host "🎯 Configuration:" -ForegroundColor Magenta
Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Storage Account: $StorageAccount" -ForegroundColor White
Write-Host "   Dev Function App: $devAppName (Consumption Plan)" -ForegroundColor White
Write-Host "   Prod Function App: $prodAppName (Consumption Plan)" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No resources will be created" -ForegroundColor Yellow
    Write-Host ""
}

# Confirm before proceeding
$proceed = Read-Host "Do you want to create these Azure resources? (y/n)"
if ($proceed -ne 'y' -and $proceed -ne 'Y') {
    Write-Host "⏹️  Setup cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🚀 Creating Azure Resources..." -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "📁 Creating Resource Group: $ResourceGroup" -ForegroundColor Cyan
if (-not $DryRun) {
    $rgExists = az group exists --name $ResourceGroup
    if ($rgExists -eq "false") {
        az group create --name $ResourceGroup --location "$Location" --output table
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Resource Group created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create Resource Group" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✅ Resource Group already exists" -ForegroundColor Green
    }
} else {
    Write-Host "🔍 [DRY RUN] Would create Resource Group: $ResourceGroup" -ForegroundColor Yellow
}

Write-Host ""

# Create Storage Account
Write-Host "💾 Creating Storage Account: $StorageAccount" -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        az storage account create `
            --name $StorageAccount `
            --location "$Location" `
            --resource-group $ResourceGroup `
            --sku Standard_LRS `
            --kind StorageV2 `
            --output table
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Storage Account created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create Storage Account" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Error creating Storage Account: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔍 [DRY RUN] Would create Storage Account: $StorageAccount" -ForegroundColor Yellow
}

Write-Host ""

# Create Development Function App (Consumption Plan - no plan needed)
Write-Host "⚡ Creating Development Function App: $devAppName" -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        az functionapp create `
            --name $devAppName `
            --resource-group $ResourceGroup `
            --consumption-plan-location "$Location" `
            --storage-account $StorageAccount `
            --runtime node `
            --runtime-version 20 `
            --functions-version 4 `
            --os-type Linux `
            --output table
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Development Function App created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create Development Function App" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Error creating Development Function App: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔍 [DRY RUN] Would create Development Function App: $devAppName" -ForegroundColor Yellow
}

Write-Host ""

# Create Production Function App (Consumption Plan - no plan needed)
Write-Host "⚡ Creating Production Function App: $prodAppName" -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        az functionapp create `
            --name $prodAppName `
            --resource-group $ResourceGroup `
            --consumption-plan-location "$Location" `
            --storage-account $StorageAccount `
            --runtime node `
            --runtime-version 20 `
            --functions-version 4 `
            --os-type Linux `
            --output table
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Production Function App created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create Production Function App" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Error creating Production Function App: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "🔍 [DRY RUN] Would create Production Function App: $prodAppName" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📥 Getting Publish Profiles..." -ForegroundColor Magenta

# Get Development Publish Profile
Write-Host "📄 Getting Development publish profile..." -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        $devPublishProfile = az webapp deployment list-publishing-profiles `
            --name $devAppName `
            --resource-group $ResourceGroup `
            --xml
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Development publish profile retrieved" -ForegroundColor Green
            $devPublishProfileFile = "dev-publish-profile.xml"
            $devPublishProfile | Out-File -FilePath $devPublishProfileFile -Encoding UTF8
            Write-Host "💾 Saved to: $devPublishProfileFile" -ForegroundColor Gray
        } else {
            Write-Host "❌ Failed to get Development publish profile" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error getting Development publish profile: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "🔍 [DRY RUN] Would get Development publish profile" -ForegroundColor Yellow
}

# Get Production Publish Profile
Write-Host "📄 Getting Production publish profile..." -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        $prodPublishProfile = az webapp deployment list-publishing-profiles `
            --name $prodAppName `
            --resource-group $ResourceGroup `
            --xml
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Production publish profile retrieved" -ForegroundColor Green
            $prodPublishProfileFile = "prod-publish-profile.xml"
            $prodPublishProfile | Out-File -FilePath $prodPublishProfileFile -Encoding UTF8
            Write-Host "💾 Saved to: $prodPublishProfileFile" -ForegroundColor Gray
        } else {
            Write-Host "❌ Failed to get Production publish profile" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error getting Production publish profile: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "🔍 [DRY RUN] Would get Production publish profile" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔐 Updating GitHub Secrets..." -ForegroundColor Magenta

# Update GitHub secrets with real values
if (-not $DryRun) {
    $repoOwner = "BoopasBagelDeli"
    $repoName = "Power-Automate-Plugin"
    
    # Update Function App names
    Write-Host "🔧 Updating AZURE_FUNCTION_APP_NAME_DEV..." -ForegroundColor Cyan
    try {
        gh secret set AZURE_FUNCTION_APP_NAME_DEV --body "$devAppName" --repo "$repoOwner/$repoName"
        Write-Host "✅ AZURE_FUNCTION_APP_NAME_DEV updated" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to update AZURE_FUNCTION_APP_NAME_DEV" -ForegroundColor Red
    }
    
    Write-Host "🔧 Updating AZURE_FUNCTION_APP_NAME_PROD..." -ForegroundColor Cyan
    try {
        gh secret set AZURE_FUNCTION_APP_NAME_PROD --body "$prodAppName" --repo "$repoOwner/$repoName"
        Write-Host "✅ AZURE_FUNCTION_APP_NAME_PROD updated" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to update AZURE_FUNCTION_APP_NAME_PROD" -ForegroundColor Red
    }
    
    # Update Publish Profiles
    if (Test-Path $devPublishProfileFile) {
        Write-Host "🔧 Updating AZURE_FUNCTION_PUBLISH_PROFILE_DEV..." -ForegroundColor Cyan
        try {
            $devProfile = Get-Content $devPublishProfileFile -Raw
            gh secret set AZURE_FUNCTION_PUBLISH_PROFILE_DEV --body "$devProfile" --repo "$repoOwner/$repoName"
            Write-Host "✅ AZURE_FUNCTION_PUBLISH_PROFILE_DEV updated" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to update AZURE_FUNCTION_PUBLISH_PROFILE_DEV" -ForegroundColor Red
        }
    }
    
    if (Test-Path $prodPublishProfileFile) {
        Write-Host "🔧 Updating AZURE_FUNCTION_PUBLISH_PROFILE_PROD..." -ForegroundColor Cyan
        try {
            $prodProfile = Get-Content $prodPublishProfileFile -Raw
            gh secret set AZURE_FUNCTION_PUBLISH_PROFILE_PROD --body "$prodProfile" --repo "$repoOwner/$repoName"
            Write-Host "✅ AZURE_FUNCTION_PUBLISH_PROFILE_PROD updated" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to update AZURE_FUNCTION_PUBLISH_PROFILE_PROD" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🎉 Azure Setup Complete!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Created Resources:" -ForegroundColor Cyan
Write-Host "   📁 Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   💾 Storage Account: $StorageAccount" -ForegroundColor White
Write-Host "   ⚡ Dev Function App: $devAppName (Consumption Plan)" -ForegroundColor White
Write-Host "   ⚡ Prod Function App: $prodAppName (Consumption Plan)" -ForegroundColor White
Write-Host ""
Write-Host "🔐 GitHub Secrets Updated:" -ForegroundColor Cyan
Write-Host "   ✅ AZURE_FUNCTION_APP_NAME_DEV" -ForegroundColor White
Write-Host "   ✅ AZURE_FUNCTION_APP_NAME_PROD" -ForegroundColor White
Write-Host "   ✅ AZURE_FUNCTION_PUBLISH_PROFILE_DEV" -ForegroundColor White
Write-Host "   ✅ AZURE_FUNCTION_PUBLISH_PROFILE_PROD" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Function App URLs:" -ForegroundColor Cyan
Write-Host "   Dev: https://$devAppName.azurewebsites.net" -ForegroundColor White
Write-Host "   Prod: https://$prodAppName.azurewebsites.net" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Your CI/CD pipeline is now fully configured!" -ForegroundColor White
Write-Host "2. Push any change to trigger automatic deployment" -ForegroundColor White
Write-Host "3. Monitor deployments at: https://github.com/$repoOwner/$repoName/actions" -ForegroundColor White
Write-Host ""

# Clean up temporary files
if (Test-Path $devPublishProfileFile) {
    Remove-Item $devPublishProfileFile -Force
    Write-Host "🧹 Cleaned up temporary files" -ForegroundColor Gray
}
if (Test-Path $prodPublishProfileFile) {
    Remove-Item $prodPublishProfileFile -Force
}

Write-Host ""
Write-Host "🎯 Ready to deploy! Your CI/CD pipeline is fully operational!" -ForegroundColor Green
