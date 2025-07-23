# GitHub Secrets Setup Guide for CI/CD Deployment

This guide explains how to set up the required GitHub secrets for automated deployment of the Power Automate Plugin.

## Required Secrets

### Azure Function App Secrets

#### Development Environment
- `AZURE_FUNCTION_APP_NAME_DEV` - Name of your development Azure Function App
- `AZURE_FUNCTION_PUBLISH_PROFILE_DEV` - Publish profile for development Function App

#### Production Environment  
- `AZURE_FUNCTION_APP_NAME_PROD` - Name of your production Azure Function App
- `AZURE_FUNCTION_PUBLISH_PROFILE_PROD` - Publish profile for production Function App

### Optional Secrets (for advanced features)

#### Azure Authentication
- `AZURE_CLIENT_ID_DEV` - Azure AD App Registration Client ID (Development)
- `AZURE_CLIENT_ID_PROD` - Azure AD App Registration Client ID (Production)

#### M365 Copilot Integration
- `M365_COPILOT_WEBHOOK_DEV` - Development webhook URL for plugin updates
- `M365_COPILOT_WEBHOOK_PROD` - Production webhook URL for plugin updates

## How to Set Up Secrets

### 1. Navigate to Repository Settings
1. Go to your GitHub repository: https://github.com/BoopasBagelDeli/Power-Automate-Plugin
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**

### 2. Add Repository Secrets
Click **New repository secret** for each required secret:

#### For Azure Function App Names:
- **Name**: `AZURE_FUNCTION_APP_NAME_DEV`
- **Value**: Your development function app name (e.g., `power-automate-dev`)

- **Name**: `AZURE_FUNCTION_APP_NAME_PROD`  
- **Value**: Your production function app name (e.g., `power-automate-prod`)

#### For Publish Profiles:
1. Go to Azure Portal → Function Apps → Your Function App
2. Click **Get publish profile** to download the `.publishsettings` file
3. Open the file and copy the entire XML content
4. Add as secret:
   - **Name**: `AZURE_FUNCTION_PUBLISH_PROFILE_DEV` (or `_PROD`)
   - **Value**: Paste the entire XML content

### 3. Set Up Environments (Optional but Recommended)

#### Create Development Environment:
1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `development`
4. Add environment-specific protection rules if needed

#### Create Production Environment:
1. Click **New environment**
2. Name: `production`
3. **Recommended**: Enable "Required reviewers" for production deployments
4. Add your GitHub username as a required reviewer

## Testing the Setup

### 1. Manual Deployment Test
1. Go to **Actions** tab in your repository
2. Click **Deploy Power Automate Plugin**
3. Click **Run workflow**
4. Select environment and click **Run workflow**

### 2. Automatic Deployment Test
1. Make a small change to your code
2. Commit and push to the `main` branch
3. Check the **Actions** tab to see the deployment pipeline running

## Local Deployment (Alternative)

If you prefer to deploy locally instead of using GitHub Actions:

```powershell
# Deploy to development
npm run deploy:dev

# Deploy to production  
npm run deploy:prod

# Build only (no deployment)
npm run deploy:build-only
```

## Troubleshooting

### Common Issues:

1. **"Function App not found"**
   - Verify the function app names in your secrets
   - Ensure the function apps exist in Azure
   - Check that publish profiles are for the correct apps

2. **"Authentication failed"**
   - Regenerate and update publish profiles
   - Verify XML formatting in secrets (no extra spaces/newlines)

3. **"Schema validation failed"**
   - This is often non-blocking, deployment will continue
   - Fix schema issues in your declarative plugin files

4. **"Build failed"**
   - Check that all dependencies are correctly specified
   - Verify Node.js and Python versions in workflow

## Security Best Practices

- Never commit secrets to your repository
- Use environment-specific secrets (dev vs prod)
- Regularly rotate publish profiles
- Enable branch protection rules for main branch
- Use required reviewers for production deployments

## Next Steps

After setting up CI/CD:
1. Test both development and production deployments
2. Set up monitoring and alerting for your function apps
3. Configure custom domains if needed
4. Set up application insights for monitoring
5. Consider implementing blue-green deployment strategies
