# 🔌 Power Automate Connector for M365 Copilot Plugin

## Overview
This package provides a declarative plugin connector for integrating Microsoft 365 Copilot with Power Automate flows and Power Platform services. It enables users to list, view, and trigger flows through natural language conversations.

## ✨ Features
- List available Power Automate flows
- Get detailed information about specific flows
- Trigger flows with parameters from Copilot
- Secured with Azure AD authentication

## 📋 Package Contents

### Declarative Configuration
- **`src/declarative/manifest.json`** - Main plugin manifest
- **`src/declarative/openapi/openapi.json`** - OpenAPI specification
- **`src/declarative/schemas/schemas.json`** - Data schemas

### Scripts
- **`scripts/validate-schemas.js`** - Validation script for schema files
- **`scripts/deploy-connector.ps1`** - Automated deployment script

## 🚀 Getting Started

### Prerequisites

- Node.js 16.x or higher
- PowerShell 7.0 or higher
- Azure subscription
- Microsoft 365 tenant with admin access

### Installation

```bash
npm install
```

### Build

```bash
npm run build
```

### Validate Schemas

```bash
npm run validate-schemas
```

### Deployment

```bash
# Deploy to development environment
npm run deploy:dev

# Deploy to production environment
npm run deploy:prod
```

## 🔄 CI/CD with Azure DevOps

This package includes Azure DevOps pipeline configurations for continuous integration and deployment:

1. **Build Stage** - Builds and validates the declarative plugin
2. **Test Stage** - Runs tests to ensure functionality
3. **Deploy_Dev Stage** - Deploys to development environment
4. **Deploy_Prod Stage** - Deploys to production environment

### Setting Up Azure DevOps Pipeline

1. Create a new pipeline in Azure DevOps
2. Select "Azure Repos Git" as the source
3. Select your repository
4. Configure the pipeline using the existing YAML file at `.azure-pipelines/azure-pipelines.yml`
5. Set up the required variables in your Azure DevOps project:

   - AZURE_SUBSCRIPTION
   - FUNCTION_APP_NAME
   - APP_SERVICE_PLAN
   - RESOURCE_GROUP
- **`company-data-flow.json`** - Sample Power Automate flow template

## 🚀 Quick Start

### Prerequisites
1. **Power Platform CLI** - Install from: https://aka.ms/PowerPlatformCLI
2. **Azure CLI** - Already installed from main module
3. **Power Platform Environment** - Access to create custom connectors

### Deployment Steps

```powershell
# 1. Navigate to the Power Automate module
cd power-automate-module

# 2. Run the deployment script
.\deploy-connector.ps1

# 3. Follow the interactive prompts to:
#    - Authenticate with Power Platform
#    - Select your environment
#    - Deploy the custom connector
```

## 🔌 **Where Your Plugin Can Be Utilized**

### **1. M365 Copilot Ecosystem** ✅ (Already Deployed)
- **Teams Chat** - Natural language queries to your company data
- **Outlook** - Email context with related documents
- **Word, Excel, PowerPoint** - Insert relevant company information
- **Microsoft 365 Chat** - Cross-application data access
- **Viva Engage** - Community discussions with data context

### **2. Power Platform** 🆕 (This Module)
- **Power Automate**
  - Automated workflows triggered by data changes
  - Daily/weekly reports from company data
  - Email notifications with relevant documents
  - Integration with external systems
  
- **Power Apps**
  - Custom search applications
  - Personal dashboards
  - Mobile apps for field workers
  - Executive reporting interfaces
  
- **Power BI**
  - Real-time data visualization
  - Usage analytics and trends
  - Compliance and audit reports
  - Executive dashboards

- **Power Virtual Agents**
  - Chatbots with company data access
  - Automated customer support
  - Internal help desk systems
  - FAQ systems with dynamic content

### **3. Teams Platform Extensions**
- **Teams Bots** - Conversational interfaces
- **Message Extensions** - Search company data in chat
- **Tab Applications** - Embedded search interfaces
- **Teams Webhooks** - Real-time data notifications

### **4. External Integrations**
- **Webhooks** - Real-time data push to external systems
- **REST API** - Direct integration with business applications
- **Mobile Applications** - iOS/Android apps
- **Third-party Business Applications** - CRM, ERP, ITSM systems

### **5. Developer Ecosystem**
- **Custom Applications** - Any application that can call REST APIs
- **Logic Apps** - Azure-based workflow automation
- **Azure Functions** - Serverless compute integrations
- **Microsoft Graph** - Native Microsoft 365 integrations

## 🎯 Power Automate Use Cases

### **Automated Document Management**
```
Trigger: New document uploaded to SharePoint
Action: Search for related existing documents
Action: Tag document with relevant metadata
Action: Notify relevant team members
```

### **Smart Email Processing**
```
Trigger: Important email received
Action: Search for related company documents
Action: Create summary with relevant attachments
Action: Forward enhanced email to decision makers
```

### **Compliance Monitoring**
```
Trigger: Scheduled (daily)
Action: Search for documents containing sensitive data
Action: Check access permissions and sharing
Action: Generate compliance report
Action: Alert compliance team if issues found
```

### **Team Productivity Insights**
```
Trigger: Weekly schedule
Action: Analyze team file access patterns
Action: Identify frequently accessed documents
Action: Generate productivity insights
Action: Send summary to team leads
```

## 🔧 Technical Architecture

### **Authentication Flow**
1. Power Platform authenticates with Azure AD
2. Azure AD issues token with configured permissions
3. Custom connector calls your Function App with token
4. Function App validates token and processes request
5. Results returned through Power Platform to consuming app

### **Data Flow**
```
Power App/Flow → Custom Connector → Azure Function → Microsoft Graph → M365 Data
```

### **Permission Model**
Your existing maximum scope permissions (10 permissions) provide full access to:
- **User Management** (User.ReadWrite.All)
- **File Systems** (Files.ReadWrite.All, Sites.FullControl.All)
- **Email & Calendar** (Mail.ReadWrite, Calendars.ReadWrite)
- **Teams** (TeamMember.ReadWrite.All)
- **Directory Services** (Directory.ReadWrite.All)
- **Applications** (Application.ReadWrite.All)
- **Exchange** (Exchange.ManageAsApp)

## 📊 Available Operations

### **Search Operations**
- **Multi-source Search** - Search across files, emails, teams, calendar
- **Filtered Search** - By date range, author, file type, site
- **Advanced Search** - Complex queries with operators

### **File Operations**
- **Get File Content** - Retrieve full file content by ID
- **File Metadata** - Get file properties and permissions
- **File History** - Access version history and changes

### **User Operations**
- **User Activity** - Recent activity across all M365 services
- **User Profile** - Complete directory information
- **User Permissions** - Access rights and group memberships

### **Analytics Operations**
- **Usage Statistics** - Document and email access patterns
- **Collaboration Metrics** - Team interaction data
- **Compliance Reports** - Data governance insights

## 🛡️ Security & Governance

### **Security Features**
- **Azure AD Authentication** - Enterprise-grade security
- **Role-based Access** - Respects existing M365 permissions
- **Audit Logging** - Complete activity tracking
- **Data Encryption** - In transit and at rest

### **Governance**
- **Permission Validation** - Users only see data they have access to
- **Compliance Integration** - Works with existing DLP policies
- **Usage Monitoring** - Track connector usage and patterns
- **Error Handling** - Graceful failure with detailed logging

## 🚀 Getting Started Examples

### **Simple Search Flow**
```json
{
  "trigger": "Manual",
  "actions": [
    {
      "name": "Search Company Data",
      "type": "CustomConnector",
      "inputs": {
        "query": "budget 2025",
        "dataSource": "files",
        "maxResults": 10
      }
    }
  ]
}
```

### **Power Apps Integration**
```javascript
// In Power Apps, use the connector as a data source
CompanyDataConnector.SearchCompanyData({
    query: TextInput1.Text,
    dataSource: Dropdown1.Selected.Value,
    maxResults: 20
})
```

## 📈 Performance & Scaling

### **Optimization Features**
- **Caching** - Intelligent result caching for common queries
- **Pagination** - Efficient handling of large result sets
- **Throttling** - Rate limiting to prevent abuse
- **Async Processing** - Background processing for complex queries

### **Monitoring**
- **Application Insights** - Performance metrics and errors
- **Power Platform Analytics** - Usage patterns and trends
- **Custom Telemetry** - Business-specific metrics

## 🎉 Benefits Summary

### **For End Users**
- **Unified Search** - One interface for all company data
- **Contextual Information** - Relevant data in the right place
- **Mobile Access** - Search company data from anywhere
- **Personalized Experiences** - Tailored to user permissions and role

### **For Developers**
- **Rapid Development** - Pre-built connector accelerates app development
- **Rich APIs** - Comprehensive data access capabilities
- **Scalable Architecture** - Enterprise-ready infrastructure
- **Extensible Platform** - Easy to add new data sources and operations

### **For IT Administrators**
- **Centralized Security** - Leverage existing Azure AD policies
- **Comprehensive Monitoring** - Full visibility into data access
- **Governance Compliance** - Respects existing M365 governance
- **Cost Optimization** - Shared infrastructure across multiple use cases

---

## 🔗 Next Steps

1. **Deploy the Connector** - Run `.\deploy-connector.ps1`
2. **Create Test Flows** - Build simple automation workflows
3. **Build Power Apps** - Create custom search applications
4. **Monitor Usage** - Track adoption and performance
5. **Expand Use Cases** - Identify additional automation opportunities

Your M365 Copilot Plugin now has the foundation to power enterprise-wide automation and custom applications! 🚀
