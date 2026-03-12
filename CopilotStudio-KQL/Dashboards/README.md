# Copilot Studio Dashboards

This folder contains Azure Data Explorer dashboard definitions and preview visualizations for Microsoft Copilot Studio monitoring and analytics.

## 📁 Files Overview

### Dashboard Definitions (JSON)
Ready to import into Azure Data Explorer:
- **01-Overview-Dashboard.json** - High-level usage metrics and KPIs
- **02-Performance-Dashboard.json** - Performance and dependency monitoring
- **03-Conversation-Analytics-Dashboard.json** - Conversation patterns and user engagement

### Preview Visualizations (HTML)
Interactive previews showing how dashboards will look:
- **Preview-All-Dashboards-Overview.html** - Complete presentation view of all dashboards
- **Preview-01-Overview-Dashboard.html** - Overview dashboard preview
- **Preview-02-Performance-Dashboard.html** - Performance dashboard preview
- **Preview-03-Conversation-Analytics-Dashboard.html** - Analytics dashboard preview

### Utilities
- **Capture-Dashboards.ps1** - PowerShell script to capture dashboards as PNG
- **Open-Dashboard-Previews.bat** - Batch file to open all previews in browser
- **CAPTURE-INSTRUCTIONS.md** - Detailed instructions for creating PNG screenshots
- **SKILL.md** - Technical reference guide for dashboard creation and troubleshooting

## 🚀 Quick Start

### View Dashboard Previews

**Option 1: Open All at Once**
```bash
# Windows
Open-Dashboard-Previews.bat
```

**Option 2: Open Individual Files**
Simply double-click any HTML file to open in your default browser.

### Capture as PNG for Presentations

**Using PowerShell (Recommended):**
```powershell
cd CopilotStudio-KQL\Dashboards
.\Capture-Dashboards.ps1
```

**Using Browser:**
1. Open any HTML file in Chrome/Edge
2. Press `F12` to open DevTools
3. Press `Ctrl+Shift+P`
4. Type "Capture full size screenshot"
5. Save the PNG

See `CAPTURE-INSTRUCTIONS.md` for more methods.

### Deploy to Azure Data Explorer

1. **Open Azure Data Explorer Web UI**
   - Navigate to https://dataexplorer.azure.com
   - Connect to your cluster

2. **Import Dashboard**
   - Click on "Dashboards" in the left menu
   - Click "New Dashboard"
   - Click "⋯" menu → "Import"
   - Select a JSON file (e.g., `01-Overview-Dashboard.json`)

3. **Configure Data Source**
   - Update the `resourceId` in the JSON to point to your Application Insights
   - Format: `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/microsoft.insights/components/{app-insights}`

4. **Save and View**
   - Dashboard will load with live data
   - Auto-refresh is configured for 5 minutes

## 📊 Dashboard Details

### 1. Overview Dashboard
**Purpose:** High-level operational metrics
**Key Metrics:**
- Total Messages (14 days)
- Active Users (14 days)
- Unique Conversations
- Active Channels
- Message volume trends
- User retention distribution
- Channel distribution
- Peak usage hours

**Best For:**
- Executive summaries
- Daily operational reviews
- Business stakeholder reports

### 2. Performance Dashboard
**Purpose:** Technical health monitoring
**Key Metrics:**
- Average dependency duration
- P95 latency
- Dependency success rate
- Slow dependencies (>2s)
- Latency trends over time
- Dependency health table
- Exception trends

**Best For:**
- SRE/DevOps teams
- Performance troubleshooting
- SLA monitoring
- Capacity planning

### 3. Conversation Analytics Dashboard
**Purpose:** User behavior and engagement analysis
**Key Metrics:**
- Avg messages per conversation
- Avg message length
- Unique locales
- Activity type distribution
- Conversation length distribution
- User engagement levels
- Message pattern analysis

**Best For:**
- Product managers
- UX teams
- Content optimization
- User experience analysis

## 🔧 Customization

### Modify Sample Data in Previews
1. Open any `Preview-*.html` file in a text editor
2. Locate the data section (look for metric values)
3. Update numbers, text, or styling as needed
4. Save and reload in browser

### Adjust Dashboard JSON
1. Open any `*.json` file in a text editor
2. Modify KQL queries in the `query` fields
3. Adjust time ranges, thresholds, or filters
4. Save and re-import to Azure Data Explorer

### Time Range Filters
Default time ranges in dashboards:
- **Overview:** 14 days (configurable to 7d, 30d, 90d)
- **Performance:** 7 days (configurable to 24h, 3d, 14d, 30d)
- **Analytics:** 14 days (configurable to 7d, 30d, 60d)

## 📈 Data Requirements

### Application Insights Schema
Dashboards expect these tables:
- **customEvents** - Bot events (BotMessageSend, TopicStart, TopicEnd)
- **dependencies** - External API calls and performance
- **exceptions** - Error and exception tracking

### Required Custom Dimensions
- `designMode` - Filter test canvas data (handles missing values)
- `conversationId` - Group related messages
- `message` - Message content (optional)
- `locale` - Language/region data (optional)

### Data Volume Recommendations
- **Minimum:** 1,000 events/day for meaningful insights
- **Optimal:** 10,000+ events/day for robust analytics
- **Retention:** 90 days (configurable)

## 🎯 Use Cases

### Daily Standup
Use **Overview Dashboard** to:
- Check message volume trends
- Monitor active user counts
- Identify channel usage patterns

### Incident Response
Use **Performance Dashboard** to:
- Diagnose latency spikes
- Identify failing dependencies
- Track exception patterns

### Product Reviews
Use **Analytics Dashboard** to:
- Understand user engagement
- Analyze conversation quality
- Optimize bot responses

### Executive Reports
Use **All Dashboards Overview** (HTML) to:
- Present comprehensive metrics
- Show system health status
- Demonstrate ROI and adoption

## 🐛 Troubleshooting

### Dashboard shows no data
- Verify Application Insights connection
- Check data connection between App Insights and Azure Data Explorer
- Confirm time range includes data
- Validate KQL query syntax

### Preview HTML not rendering correctly
- Ensure using a modern browser (Chrome, Edge, Firefox)
- Check JavaScript is enabled
- Try opening in incognito/private mode

### Capture script fails
- Verify Microsoft Edge is installed
- Run PowerShell as Administrator
- Check file paths don't contain special characters

### Dashboard import errors
**See [SKILL.md](SKILL.md) for comprehensive troubleshooting guide covering:**
- UUID format requirements
- Valid visualization types
- Minimum tile size errors
- Field name corrections (activityType, message vs text)
- Query structure validation
- Complete error message reference

### KQL query errors
- All queries use corrected syntax for:
  - `timestamp between (start .. end)` - Inclusive bounds
  - `isempty(isDesignMode) or tolower(isDesignMode) != "true"` - Handles missing/varied values
  - `name == "BotMessageSend"` - Correct event filtering
  - `customDimensions['message']` - Correct field name
- Update queries to match your schema if needed

## 📚 Additional Resources

### Documentation
- [Azure Data Explorer Documentation](https://docs.microsoft.com/azure/data-explorer/)
- [KQL Quick Reference](https://docs.microsoft.com/azure/data-explorer/kql-quick-reference)
- [Copilot Studio Analytics](https://docs.microsoft.com/power-virtual-agents/analytics-overview)

### Related Files in Repository
- `../01-Usage-Metrics/*.kql` - Individual KQL query files
- `../02-Performance-Metrics/*.kql` - Performance queries
- `../03-Quality-Metrics/*.kql` - Quality and error queries
- `../04-Agent-Evaluation/*.kql` - Agent analysis queries

## 💡 Tips & Best Practices

1. **Start with Overview** - Get familiar with high-level metrics first
2. **Set Alerts** - Configure Azure Monitor alerts for critical thresholds
3. **Regular Reviews** - Schedule weekly dashboard reviews with stakeholders
4. **Customize Thresholds** - Adjust based on your specific SLAs and requirements
5. **Export Reports** - Use captured PNGs for regular status reports
6. **Combine with Power BI** - For more advanced visualizations and analysis

## 🤝 Support

For issues, questions, or contributions:
1. Check existing documentation in this folder
2. Review KQL query files in parent directories
3. Validate data in Azure Data Explorer query editor
4. Test queries with sample time ranges

---

**Last Updated:** 2026-03-10
**Version:** 2.0
**Compatible with:** Azure Data Explorer, Application Insights, Copilot Studio
