# GitHub Secrets Configuration Helper Script
# This script helps you set up all required GitHub secrets for CI/CD deployment

param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Write-Host "🔧 GitHub Secrets Configuration Helper" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$repoOwner = "BoopasBagelDeli"
$repoName = "Power-Automate-Plugin"
$repoUrl = "https://github.com/$repoOwner/$repoName"

Write-Host "Repository: $repoUrl" -ForegroundColor Green
Write-Host ""

# Check if GitHub CLI is installed
try {
    $ghVersion = gh --version 2>$null
    Write-Host "✅ GitHub CLI is available: $($ghVersion.Split("`n")[0])" -ForegroundColor Green
    $useGhCli = $true
} catch {
    Write-Host "⚠️  GitHub CLI not found. We'll provide manual setup instructions." -ForegroundColor Yellow
    $useGhCli = $false
}

Write-Host ""

# Define all required secrets
$secrets = @{
    "Required" = @{
        "AZURE_FUNCTION_APP_NAME_DEV" = @{
            "description" = "Name of your development Azure Function App"
            "example" = "power-automate-dev-20250723"
            "required" = $true
        }
        "AZURE_FUNCTION_APP_NAME_PROD" = @{
            "description" = "Name of your production Azure Function App"
            "example" = "power-automate-prod-20250723"
            "required" = $true
        }
        "AZURE_FUNCTION_PUBLISH_PROFILE_DEV" = @{
            "description" = "Development Function App publish profile (XML content)"
            "example" = "Download from Azure Portal → Function App → Get publish profile"
            "required" = $true
        }
        "AZURE_FUNCTION_PUBLISH_PROFILE_PROD" = @{
            "description" = "Production Function App publish profile (XML content)"
            "example" = "Download from Azure Portal → Function App → Get publish profile"
            "required" = $true
        }
    }
    "Optional" = @{
        "AZURE_CLIENT_ID_DEV" = @{
            "description" = "Azure AD App Registration Client ID for development"
            "example" = "12345678-1234-1234-1234-123456789012"
            "required" = $false
        }
        "AZURE_CLIENT_ID_PROD" = @{
            "description" = "Azure AD App Registration Client ID for production"
            "example" = "87654321-4321-4321-4321-210987654321"
            "required" = $false
        }
        "M365_COPILOT_WEBHOOK_DEV" = @{
            "description" = "M365 Copilot webhook URL for development notifications"
            "example" = "https://your-webhook-dev.azurewebsites.net/api/notify"
            "required" = $false
        }
        "M365_COPILOT_WEBHOOK_PROD" = @{
            "description" = "M365 Copilot webhook URL for production notifications"
            "example" = "https://your-webhook-prod.azurewebsites.net/api/notify"
            "required" = $false
        }
    }
}

function Show-SecretSetupInstructions {
    param($secretName, $secretInfo, $category)
    
    Write-Host "📝 $secretName" -ForegroundColor Cyan
    Write-Host "   Description: $($secretInfo.description)" -ForegroundColor Gray
    Write-Host "   Example: $($secretInfo.example)" -ForegroundColor Gray
    if ($secretInfo.required) {
        Write-Host "   Status: REQUIRED" -ForegroundColor Red
    } else {
        Write-Host "   Status: Optional" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Set-GitHubSecret {
    param($secretName, $secretValue)
    
    if ($DryRun) {
        Write-Host "🔍 [DRY RUN] Would set secret: $secretName" -ForegroundColor Yellow
        return $true
    }
    
    if ($useGhCli) {
        try {
            $result = gh secret set $secretName --body "$secretValue" --repo "$repoOwner/$repoName" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Successfully set secret: $secretName" -ForegroundColor Green
                return $true
            } else {
                Write-Host "❌ Failed to set secret: $secretName - $result" -ForegroundColor Red
                return $false
            }
        } catch {
            Write-Host "❌ Error setting secret $secretName`: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "📋 Manual setup required for: $secretName" -ForegroundColor Yellow
        Write-Host "   Go to: $repoUrl/settings/secrets/actions" -ForegroundColor Gray
        Write-Host "   Click 'New repository secret'" -ForegroundColor Gray
        Write-Host "   Name: $secretName" -ForegroundColor Gray
        Write-Host "   Value: [Paste your value]" -ForegroundColor Gray
        Write-Host ""
        return $true
    }
}

# Display all secrets that need to be configured
Write-Host "🔐 Secrets Configuration Overview" -ForegroundColor Magenta
Write-Host "=================================" -ForegroundColor Magenta
Write-Host ""

foreach ($category in $secrets.Keys) {
    Write-Host "[$category Secrets]" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
    
    foreach ($secretName in $secrets[$category].Keys) {
        Show-SecretSetupInstructions $secretName $secrets[$category][$secretName] $category
    }
}

# Interactive setup
Write-Host "🚀 Interactive Secret Setup" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

if ($useGhCli) {
    Write-Host "GitHub CLI detected! We can set secrets automatically." -ForegroundColor Green
    $response = Read-Host "Do you want to set up secrets interactively? (y/n)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        foreach ($category in $secrets.Keys) {
            Write-Host ""
            Write-Host "Setting up $category secrets..." -ForegroundColor Yellow
            
            foreach ($secretName in $secrets[$category].Keys) {
                $secretInfo = $secrets[$category][$secretName]
                
                Write-Host ""
                Write-Host "📝 $secretName" -ForegroundColor Cyan
                Write-Host "   $($secretInfo.description)" -ForegroundColor Gray
                
                if ($secretInfo.required) {
                    Write-Host "   This secret is REQUIRED" -ForegroundColor Red
                    $value = Read-Host "   Enter value for $secretName"
                    
                    if (![string]::IsNullOrWhiteSpace($value)) {
                        Set-GitHubSecret $secretName $value
                    } else {
                        Write-Host "   ⚠️  Skipping empty value for required secret" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "   This secret is optional" -ForegroundColor Yellow
                    $response = Read-Host "   Do you want to set $secretName`? (y/n)"
                    
                    if ($response -eq 'y' -or $response -eq 'Y') {
                        $value = Read-Host "   Enter value for $secretName"
                        if (![string]::IsNullOrWhiteSpace($value)) {
                            Set-GitHubSecret $secretName $value
                        }
                    }
                }
            }
        }
    }
} else {
    Write-Host "Manual setup required. Please visit:" -ForegroundColor Yellow
    Write-Host "$repoUrl/settings/secrets/actions" -ForegroundColor Cyan
}

# Create Azure Function Apps if needed
Write-Host ""
Write-Host "🏗️  Azure Function App Setup" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
Write-Host ""

$setupAzure = Read-Host "Do you need help creating Azure Function Apps? (y/n)"
if ($setupAzure -eq 'y' -or $setupAzure -eq 'Y') {
    Write-Host ""
    Write-Host "📋 Azure Function App Creation Steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Login to Azure Portal: https://portal.azure.com" -ForegroundColor White
    Write-Host "2. Click 'Create a resource' → 'Function App'" -ForegroundColor White
    Write-Host "3. Fill in the details:" -ForegroundColor White
    Write-Host "   - Subscription: Your Azure subscription" -ForegroundColor Gray
    Write-Host "   - Resource Group: Create new or use existing" -ForegroundColor Gray
    Write-Host "   - Function App name: power-automate-dev-$(Get-Date -Format 'yyyyMMdd')" -ForegroundColor Gray
    Write-Host "   - Runtime stack: Node.js" -ForegroundColor Gray
    Write-Host "   - Version: 18 LTS" -ForegroundColor Gray
    Write-Host "   - Region: Choose your preferred region" -ForegroundColor Gray
    Write-Host "4. Click 'Review + create' → 'Create'" -ForegroundColor White
    Write-Host "5. Repeat for production app (use 'power-automate-prod-$(Get-Date -Format 'yyyyMMdd')')" -ForegroundColor White
    Write-Host ""
    Write-Host "📥 Getting Publish Profiles:" -ForegroundColor Cyan
    Write-Host "1. Go to your Function App in Azure Portal" -ForegroundColor White
    Write-Host "2. Click 'Get publish profile' in the overview" -ForegroundColor White
    Write-Host "3. Download the .publishsettings file" -ForegroundColor White
    Write-Host "4. Open the file and copy ALL the XML content" -ForegroundColor White
    Write-Host "5. Use this as the value for the publish profile secrets" -ForegroundColor White
}

Write-Host ""
Write-Host "🧪 Testing the Pipeline" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host ""

$testPipeline = Read-Host "Ready to test the deployment pipeline? (y/n)"
if ($testPipeline -eq 'y' -or $testPipeline -eq 'Y') {
    Write-Host ""
    Write-Host "🚀 Pipeline Testing Options:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Option 1 - Manual Trigger:" -ForegroundColor Yellow
    Write-Host "1. Go to: $repoUrl/actions" -ForegroundColor White
    Write-Host "2. Click 'Deploy Power Automate Plugin'" -ForegroundColor White
    Write-Host "3. Click 'Run workflow'" -ForegroundColor White
    Write-Host "4. Select 'development' environment" -ForegroundColor White
    Write-Host "5. Click 'Run workflow'" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2 - Automatic Trigger:" -ForegroundColor Yellow
    Write-Host "1. Make a small change to any file" -ForegroundColor White
    Write-Host "2. Commit and push to main branch" -ForegroundColor White
    Write-Host "3. Check Actions tab for automatic deployment" -ForegroundColor White
    Write-Host ""
    
    $triggerTest = Read-Host "Should I create a test commit to trigger the pipeline? (y/n)"
    if ($triggerTest -eq 'y' -or $triggerTest -eq 'Y') {
        # Create a test file to trigger deployment
        $testFile = "PIPELINE_TEST_$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
        $testContent = @"
# Pipeline Test - $(Get-Date)

This file was created to test the CI/CD pipeline deployment.

## Test Details
- Timestamp: $(Get-Date)
- Environment: Development (auto-deploy)
- Trigger: Commit to main branch

The pipeline should automatically:
1. ✅ Build the project
2. ✅ Validate schemas  
3. ✅ Deploy to development environment
4. ✅ Notify of successful deployment

You can monitor the progress at: $repoUrl/actions
"@
        
        $testContent | Out-File -FilePath $testFile -Encoding UTF8
        
        try {
            git add $testFile
            git commit -m "🧪 Test CI/CD pipeline deployment

- Created test file to trigger automatic deployment
- Pipeline should deploy to development environment
- Monitor progress in GitHub Actions tab"
            git push origin main
            
            Write-Host ""
            Write-Host "✅ Test commit created and pushed!" -ForegroundColor Green
            Write-Host "🔍 Monitor the deployment at: $repoUrl/actions" -ForegroundColor Cyan
            Write-Host ""
            
            # Open GitHub Actions in browser
            $openBrowser = Read-Host "Open GitHub Actions in browser to monitor deployment? (y/n)"
            if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y') {
                Start-Process "$repoUrl/actions"
            }
            
        } catch {
            Write-Host "❌ Failed to create test commit: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "You can manually trigger the pipeline from GitHub Actions instead." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. ✅ Configure all required GitHub secrets" -ForegroundColor White
Write-Host "2. ✅ Create Azure Function Apps (if not done)" -ForegroundColor White  
Write-Host "3. ✅ Test the deployment pipeline" -ForegroundColor White
Write-Host "4. ✅ Monitor deployments in GitHub Actions" -ForegroundColor White
Write-Host ""
Write-Host "📚 Useful Links:" -ForegroundColor Cyan
Write-Host "- Repository: $repoUrl" -ForegroundColor White
Write-Host "- Actions: $repoUrl/actions" -ForegroundColor White
Write-Host "- Secrets: $repoUrl/settings/secrets/actions" -ForegroundColor White
Write-Host "- Environments: $repoUrl/settings/environments" -ForegroundColor White
Write-Host ""
Write-Host "🔧 For help with any issues, check the documentation in docs/CICD_SETUP.md" -ForegroundColor Gray
