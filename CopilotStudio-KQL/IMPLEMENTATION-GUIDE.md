# Copilot Studio Telemetry Implementation Guide

## 📘 Overview

This guide explains how to enable and configure Microsoft Copilot Studio to send telemetry to Azure Application Insights, allowing you to use the KQL queries and dashboards in this repository.

## 🎯 Prerequisites

- Microsoft Copilot Studio environment (licensed)
- Azure subscription with permissions to create resources
- Copilot Studio bot created and published
- Basic understanding of Azure Portal

## 🔧 Step 1: Create Application Insights Resource

### Via Azure Portal

1. **Navigate to Azure Portal** (portal.azure.com)
2. Click **Create a resource**
3. Search for **Application Insights**
4. Click **Create**
5. Configure:
   - **Subscription**: Your subscription
   - **Resource Group**: Create new or use existing
   - **Name**: `copilot-studio-bot-insights` (or your preferred name)
   - **Region**: Same as your Copilot Studio environment (e.g., East US)
   - **Log Analytics Workspace**: Create new or use existing
6. Click **Review + Create** > **Create**
7. Once deployed, navigate to the resource
8. Copy the **Instrumentation Key** (under **Properties**)
9. Copy the **Connection String** (under **Properties**)

### Via Azure CLI

```bash
# Set variables
RESOURCE_GROUP="copilot-studio-rg"
LOCATION="eastus"
APP_INSIGHTS_NAME="copilot-studio-bot-insights"
WORKSPACE_NAME="copilot-analytics-workspace"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --location $LOCATION

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --query id -o tsv)

# Create Application Insights
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --workspace $WORKSPACE_ID

# Get instrumentation key
az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv
```

## 📡 Step 2: Configure Copilot Studio Telemetry

### Enable Application Insights in Copilot Studio

1. **Open Copilot Studio** (https://copilotstudio.microsoft.com)
2. Select your bot
3. Navigate to **Settings** > **Analytics** (left sidebar)
4. Scroll to **Application Insights** section
5. Toggle **Enable Application Insights** to **ON**
6. Paste your **Instrumentation Key** from Step 1
7. Click **Save**

### Configure Telemetry Settings

In the same **Analytics** settings page:

1. **Enable Conversation Transcripts**: ON (recommended)
2. **Collect User Data**: ON (for fromName, locale analysis)
3. **Track Custom Events**: ON (essential for this collection)
4. **Log Level**: Information (or Verbose for detailed debugging)

### What Gets Logged

With Copilot Studio telemetry enabled, the following data flows to Application Insights:

**customEvents table** with customDimensions:
- `type`: message, conversationUpdate, event, invoke
- `channelId`: emulator, directline, msteams, webchat, pva-autonomous
- `fromId`: User identifier
- `fromName`: User display name
- `locale`: User language/region (e.g., en-us, zh-cn)
- `recipientId`: Bot identifier
- `recipientName`: Bot display name
- `text`: Message text content
- `designMode`: True/False (test canvas indicator)
- `conversationId`: Conversation identifier

**dependencies table**:
- Bot API calls to external services
- Response times and success/failure status

**exceptions table**:
- Errors and exceptions from bot runtime
- Stack traces and error messages

**traces table** (if verbose logging enabled):
- Detailed diagnostic logs

## 📊 Step 3: Verify Telemetry Flow

### Check Application Insights

Wait 2-5 minutes after sending a few test messages to your bot.

1. Navigate to Application Insights in Azure Portal
2. Go to **Logs** section
3. Run verification query:

```kql
// Verify Copilot Studio telemetry
customEvents
| where timestamp > ago(1h)
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    eventName = name,
    channelId = tostring(customDimensions['channelId']),
    fromName = tostring(customDimensions['fromName']),
    text = tostring(customDimensions['message'])
| project timestamp, name, activityType, channelId, fromName, isDesignMode, text
| order by timestamp desc
| take 20
```

### Expected Output

You should see events like:
```
timestamp               | name            | activityType      | channelId | fromName  | isDesignMode | text
2026-03-09 10:30:00    | ActivityEvent   | message           | webchat   | John Doe  | False        | hello
2026-03-09 10:30:02    | ActivityEvent   | message           | webchat   | Bot       | False        | Hi! How can I help?
2026-03-09 10:30:10    | ActivityEvent   | conversationUpdate| webchat   | John Doe  | False        |
```

### Test Canvas vs Production

**Test messages** (from Copilot Studio test canvas):
```kql
customEvents
| where timestamp > ago(1h)
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "True"  // Test canvas conversations
| count
```

**Production messages** (from deployed channels):
```kql
customEvents
| where timestamp > ago(1h)
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"  // Production conversations
| count
```

## 🎨 Step 4: Import Dashboards

### Update Dashboard JSON Files

Before importing, update each dashboard JSON file:

1. Open dashboard JSON file in a text editor
2. Find the `dataSource` section:
   ```json
   "dataSource": {
     "type": "ApplicationInsights",
     "resourceId": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/microsoft.insights/components/{app-insights-name}"
   }
   ```
3. Replace placeholders:
   - `{subscription-id}`: Your Azure subscription ID
   - `{resource-group}`: Your resource group name (e.g., copilot-studio-rg)
   - `{app-insights-name}`: Your App Insights name (e.g., copilot-studio-bot-insights)

#### Find Your Subscription ID and Resource IDs

**Option 1: Azure Portal**
1. Navigate to your Application Insights resource
2. Click **JSON View** (top right)
3. Copy the **Resource ID** (full path)

**Option 2: Azure CLI**
```bash
# Get subscription ID
az account show --query id -o tsv

# Get Application Insights resource ID
az monitor app-insights component show \
  --app copilot-studio-bot-insights \
  --resource-group copilot-studio-rg \
  --query id -o tsv
```

Example result:
```
/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/copilot-studio-rg/providers/microsoft.insights/components/copilot-studio-bot-insights
```

### Import to Azure Portal

#### Method 1: Application Insights Workbooks

1. Navigate to your **Application Insights** resource
2. Click **Workbooks** (left sidebar)
3. Click **+ New**
4. Click **Advanced Editor** (</> icon, top right)
5. Replace the JSON with your dashboard JSON content
6. Click **Apply**
7. Click **Done Editing**
8. Click **Save** > Provide name and location

#### Method 2: Azure Dashboards (Classic)

1. Navigate to **Azure Portal** home
2. Click **Dashboard** (left sidebar)
3. Click **+ New Dashboard** > **Blank Dashboard**
4. Click **Upload** (top toolbar)
5. Select your updated JSON file
6. Adjust tile sizes and positions as needed
7. Click **Done customizing**

## 🔍 Step 5: Validate Dashboard Data

### Test Each Dashboard

#### 1. Overview Dashboard
- **Check**: Total messages, active users, conversations
- **Expected**: Numbers matching your test activity
- **Charts**: Message volume and user trends

#### 2. Performance Dashboard
- **Check**: Dependency latencies, success rates
- **Expected**: Values < 1000ms for typical operations
- **Charts**: Latency trends, exception trends

#### 3. Conversation Analytics Dashboard
- **Check**: Conversation lengths, message patterns
- **Expected**: Realistic averages (2-10 messages/conversation)
- **Charts**: Length distribution, engagement levels

### Common Issues

#### No Data in Dashboards

**Problem**: Tiles show "No data available"

**Solutions**:
1. Verify telemetry is flowing (Step 3)
2. Increase time range from 7d to 14d or 30d
3. Check that designMode filter matches your data:
   ```kql
   customEvents
   | extend isDesignMode = tostring(customDimensions['designMode'])
   | summarize count() by isDesignMode
   ```
4. Ensure queries reference correct fields (case-sensitive)

#### Incorrect Metrics

**Problem**: Metrics seem wrong or empty

**Solutions**:
1. Verify custom dimension field names:
   ```kql
   customEvents
   | where timestamp > ago(1h)
   | extend customDims = todynamic(customDimensions)
   | mvexpand customDims
   | project FieldName = tostring(bag_keys(customDims)[0])
   | distinct FieldName
   ```
2. Check data types (string vs. number)
3. Ensure `channelId`, `fromId`, `text` fields exist

#### Dashboard Import Fails

**Problem**: JSON import fails with error

**Solutions**:
1. Validate JSON syntax (use jsonlint.com)
2. Ensure resource IDs are complete and correct
3. Check subscription permissions (Reader + Monitoring Contributor)
4. Try importing to different browser (Edge/Chrome)

## 📋 Step 6: Custom Dimension Schema Reference

### Actual Copilot Studio Fields

Based on Copilot Studio telemetry structure:

**Direct Fields:**
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| timestamp | datetime | Event timestamp (UTC) | 2026-03-09T07:49:20.8189867Z |
| name | string | Event name | BotMessageSend, TopicStart, TopicEnd |
| itemType | string | Telemetry type | customEvent |
| user_Id | string | User identifier | pva-autonomous01dc5f09... |
| cloud_RoleName | string | Agent platform | Microsoft Copilot Studio |
| cloud_RoleInstance | string | Agent name | Supplier Communications Agent - inbound |
| itemCount | int | Count | 1 |

**Custom Dimensions:**
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| message | string | Message text content | "I need help with my order" |
| designMode | string | Test canvas flag | "True", "False" |

### Sample Query to Explore Your Schema

```kql
// Discover all custom dimensions in your data
customEvents
| where timestamp > ago(24h)
| where name == "ActivityEvent"  // Common Copilot Studio event name
| take 1
| project customDimensions
```

## 🔐 Security & Best Practices

### Instrumentation Key Protection

1. **Use Azure Key Vault** to store instrumentation keys (enterprise)
2. **Limit access** to Application Insights resource
3. **Rotate keys** annually or after team changes
4. **Monitor usage** for anomalies

### Data Privacy & Compliance

1. **Anonymize PII**: Consider hashing `fromId` or `fromName` if required
2. **Review message text**: Ensure no sensitive data in `text` field
3. **Set retention**: Configure data retention (default 90 days, max 730 days)
4. **GDPR compliance**: Implement data deletion procedures if needed

**To set retention:**
1. Navigate to Application Insights > **Usage and estimated costs**
2. Click **Data Retention**
3. Select retention period (30-730 days)
4. Click **Apply**

### Performance & Cost Optimization

1. **Sampling**: Enable adaptive sampling for high-volume bots
   - Navigate to **Application Insights** > **Sampling**
   - Enable **Adaptive sampling** (recommended: 10-20% for high traffic)

2. **Daily Cap**: Set daily ingestion limit
   - Navigate to **Usage and estimated costs** > **Daily cap**
   - Set limit (e.g., 5 GB/day for small bots, 50 GB/day for large)

3. **Filter unnecessary data**:
   - Disable **Trace** logging if not needed (reduces volume by 30-50%)
   - Filter out non-essential custom dimensions

## 🚨 Step 7: Set Up Alerts

### Create Azure Monitor Alert Rule

1. **Navigate to Azure Monitor** > **Alerts** > **+ New Alert Rule**
2. **Select resource**: Your Application Insights resource
3. **Add condition**: Custom log search
4. **Query**: Paste alert query from `07-Alerts/` folder
5. **Alert logic**:
   - **Threshold**: As defined in query (e.g., > 10 exceptions)
   - **Aggregation granularity**: 5 minutes
   - **Frequency of evaluation**: 5 minutes
6. **Actions**: Create or select action group
7. **Alert details**:
   - **Severity**: Critical/Error/Warning/Informational
   - **Alert rule name**: Descriptive name (e.g., "Copilot High Error Rate")
8. **Review + create**

### Recommended Alerts

| Alert | Query File | Severity | Threshold |
|-------|-----------|----------|-----------|
| High Error Rate | 01-high-error-rate-alert.kql | High | > 10 exceptions/hour |
| Low Activity | 02-low-activity-alert.kql | Medium | 50% drop |
| Dependency Failure | 03-dependency-failure-alert.kql | High | 20% failure rate |

### Action Groups

Create action groups for notifications:

**Email notifications**:
- Email: alerts@yourdomain.com
- Use case: Non-critical alerts

**SMS notifications**:
- Phone: +1-555-0100
- Use case: Critical production issues

**Webhook integrations**:
- Slack/Teams webhook URL
- Use case: Team collaboration on incidents

## ✅ Validation Checklist

- [ ] Application Insights resource created
- [ ] Instrumentation key obtained
- [ ] Copilot Studio telemetry enabled
- [ ] Test messages sent and visible in Application Insights
- [ ] `designMode == "False"` for production data verified
- [ ] Dashboard JSON files updated with resource IDs
- [ ] Dashboards imported successfully
- [ ] All dashboard tiles showing data (or "no data" expected for new bots)
- [ ] Time ranges appropriate (7d, 14d, 30d)
- [ ] Alerts configured (at least error rate alert)
- [ ] Data retention policy set
- [ ] Team trained on dashboard usage

## 🆘 Troubleshooting

### Telemetry Not Appearing

**Symptoms**: No events in Application Insights after 10 minutes

**Diagnosis**:
```kql
// Check if any data exists
union customEvents, dependencies, exceptions, traces
| where timestamp > ago(1h)
| count
```

**Solutions**:
1. Verify instrumentation key is correct
2. Check Copilot Studio analytics settings (ensure toggle is ON)
3. Send multiple test messages from different channels
4. Wait 5-10 minutes (ingestion delay)
5. Check Application Insights quota limits (Usage and estimated costs)
6. Verify bot is published and accessible

### Only Test Canvas Data

**Symptoms**: All events have `designMode == "True"`

**Solutions**:
1. Publish your bot to a channel (Teams, Web Chat)
2. Send messages from the channel (not test canvas)
3. Wait 2-5 minutes for data
4. Query production data:
   ```kql
   customEvents
   | where timestamp > ago(1h)
   | extend isDesignMode = tostring(customDimensions['designMode'])
   | where isDesignMode == "False"
   | count
   ```

### Missing Custom Dimensions

**Symptoms**: `fromName`, `text`, or other fields are empty

**Solutions**:
1. Check Copilot Studio analytics settings:
   - **Collect User Data**: must be ON
   - **Track Custom Events**: must be ON
2. Verify channel supports these fields (Web Chat, Teams support all)
3. Some fields may be empty for certain activity types (conversationUpdate)

### Dashboard Shows Zero for All Metrics

**Symptoms**: Dashboard tiles show "0" instead of "No data"

**Solutions**:
1. Verify time range in dashboard (change from 7d to 30d)
2. Check filter conditions in queries
3. Ensure data exists:
   ```kql
   customEvents
   | where timestamp > ago(30d)
   | summarize count()
   ```
4. Review query syntax (case-sensitive field names)

## 📚 Additional Resources

### Official Documentation
- [Copilot Studio Telemetry](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-bot-framework-composer-capture-telemetry)
- [Application Insights Overview](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [KQL Quick Reference](https://docs.microsoft.com/azure/data-explorer/kusto/query/)

### Community Resources
- [Copilot Studio Community](https://powerusers.microsoft.com/t5/Microsoft-Copilot-Studio/ct-p/PVACommunity)
- [Azure Monitor Q&A](https://docs.microsoft.com/answers/products/azure-monitor)

---

**Version**: 2.0.0
**Last Updated**: 2026-03-09
**Author**: Azure Observability Team
**Compatibility**: Copilot Studio with Application Insights integration
