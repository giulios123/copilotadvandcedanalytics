# Copilot Studio Telemetry Analysis - Reference Library

## Overview

This reference library contains **tested KQL queries, quick reference guides, and architecture documentation** for analyzing Microsoft Copilot Studio bot telemetry in Azure Application Insights.

All queries have been validated to work in the **Azure Portal query window**.

---

## 📂 Directory Structure

```
references/
├── README.md                          # This file - main navigation
├── example-kql-copilot-studio.md      # Comprehensive query guide with explanations
├── kql-quick-reference.md             # Quick reference for common patterns
├── architecture-diagram.md            # Diagram creation guidelines
└── queries/                           # Ready-to-use .kql files
    ├── README.md                      # Query library index
    ├── 00-quick-validation.kql        # Data validation
    ├── 01-daily-active-users.kql      # User metrics
    ├── 02-event-volume-by-type.kql    # Event analytics
    └── ... (15 queries total)
```

---

## 🚀 Quick Start

### For First-Time Users

1. **Start here**: Read [`example-kql-copilot-studio.md`](example-kql-copilot-studio.md)
   - Understand the schema
   - Learn KQL best practices
   - See detailed examples with explanations

2. **Validate your data**: Use [`queries/00-quick-validation.kql`](queries/00-quick-validation.kql)
   - Verify data is flowing to Application Insights
   - Inspect available fields

3. **Try common queries**: Browse [`queries/`](queries/) directory
   - Ready-to-use .kql files
   - Just copy and paste into Azure Portal

### For Quick Lookups

- **Need syntax?** → [`kql-quick-reference.md`](kql-quick-reference.md)
- **Need a specific query?** → [`queries/README.md`](queries/README.md)
- **Creating diagrams?** → [`architecture-diagram.md`](architecture-diagram.md)

---

## 📊 Available Queries

### User Analytics
- Daily active users (trend analysis)
- Top active users
- User interaction frequency
- New vs returning users
- Conversation duration

### Event Analysis
- Event volume by type
- Hourly event trends
- Topic lifecycle (start/end)
- Message content extraction

### Agent Performance
- Agent activity summary
- Multi-agent comparison
- Performance dashboard

### Operational Monitoring
- Peak usage hours (heatmap)
- Event rate per minute
- Real-time throughput

See [`queries/README.md`](queries/README.md) for the complete index.

---

## 📖 Documentation Files

### [`example-kql-copilot-studio.md`](example-kql-copilot-studio.md)

**Purpose**: Comprehensive guide with 15 detailed queries

**Contents**:
- Schema reference and field descriptions
- Step-by-step query examples with explanations
- Best practices for Azure Portal
- Troubleshooting common errors
- Query optimization tips

**When to use**: Learning KQL, understanding the data model, or needing detailed examples.

---

### [`kql-quick-reference.md`](kql-quick-reference.md)

**Purpose**: Fast syntax lookup and pattern reference

**Contents**:
- Essential KQL patterns (filters, aggregations, datetime functions)
- Common query snippets (copy-paste ready)
- Schema fields quick reference
- Pro tips for writing efficient queries

**When to use**: Quick syntax lookup while writing queries, or as a cheat sheet.

---

### [`architecture-diagram.md`](architecture-diagram.md)

**Purpose**: Guidelines for creating technical diagrams

**Contents**:
- Diagram creation best practices (draw.io, excalidraw)
- Architecture patterns (cloud, agent systems, Dynamics 365)
- Visualization strategies
- Documentation standards

**When to use**: Documenting system architecture, creating technical presentations, or visualizing agent workflows.

---

### [`queries/`](queries/) Directory

**Purpose**: Ready-to-use KQL query files for immediate execution

**Contents**: 15 individual `.kql` files covering common analysis scenarios

**When to use**: Need a working query quickly without writing from scratch.

---

## 🔍 Schema Overview

### Core Fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | datetime | Event timestamp (UTC) |
| `name` | string | Event type (BotMessageSend, TopicStart, TopicEnd, TopicAction) |
| `user_Id` | string | User identifier |
| `cloud_RoleName` | string | Platform name (Microsoft Copilot Studio) |
| `cloud_RoleInstance` | string | Agent/bot instance name |
| `customDimensions` | dynamic | JSON with message text and designMode |

### Event Types

- **BotMessageSend**: Bot sent a message to user
- **TopicStart**: Conversation topic started
- **TopicEnd**: Conversation topic ended
- **TopicAction**: Topic-level action triggered

### CustomDimensions Fields

- **designMode**: `"True"` (test canvas) or `"False"` (production)
- **message**: Message text content

---

## 💡 Common Use Cases

### Daily Reporting

**Goal**: Track daily active users and event volumes

**Files to use**:
1. `queries/01-daily-active-users.kql` - User trends
2. `queries/02-event-volume-by-type.kql` - Event distribution
3. `queries/09-peak-usage-hours.kql` - Usage patterns

---

### Production Incident Investigation

**Goal**: Debug issues in production

**Files to use**:
1. `queries/03-production-events-only.kql` - Recent events
2. `queries/08-message-content-analysis.kql` - Inspect messages
3. `queries/12-event-rate-per-minute.kql` - Check for spikes

**Tip**: Adjust time range to incident window using `ago(1h)` or `ago(30m)`

---

### Agent Performance Review

**Goal**: Compare multiple bot instances

**Files to use**:
1. `queries/04-agent-activity-summary.kql` - Activity overview
2. `queries/11-agent-comparison-dashboard.kql` - Detailed metrics
3. `queries/07-topic-lifecycle.kql` - Topic completion rates

---

### User Engagement Analysis

**Goal**: Understand user behavior

**Files to use**:
1. `queries/10-user-interaction-frequency.kql` - Engagement patterns
2. `queries/13-new-vs-returning-users.kql` - Retention metrics
3. `queries/14-conversation-duration.kql` - Session length

---

## 🛠️ How to Use with Azure Portal

### Step 1: Access Application Insights

1. Open Azure Portal
2. Navigate to your Application Insights resource
3. Click "Logs" in the left sidebar

### Step 2: Run a Query

1. Copy content from any `.kql` file
2. Paste into the query editor
3. Click "Run" or press `Shift + Enter`

### Step 3: Customize

- Adjust time ranges (`ago(7d)` → `ago(30d)`)
- Filter by agent: `| where cloud_RoleInstance == "YourAgentName"`
- Change visualization: `| render timechart` → `| render barchart`

### Step 4: Save and Share

- **Save query**: Click "Save" → "Save as query"
- **Pin to dashboard**: Click "Pin to dashboard"
- **Export data**: Click "Export" → Choose format

---

## ⚠️ Important Notes

### Always Filter Production Data

Unless debugging test canvas, include this filter in every query:

```kql
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
```

### Use Time Ranges

Always specify a time range to limit data volume:

```kql
| where timestamp > ago(7d)
```

### Access CustomDimensions Correctly

Always cast customDimensions fields:

```kql
| extend messageText = tostring(customDimensions.message)
```

---

## 🔗 External Resources

- [Kusto Query Language (KQL) Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Application Insights Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Copilot Studio Telemetry Documentation](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-bot-framework-composer-capture-telemetry)

---

## 📝 Contributing

When adding new queries:

1. Test in Azure Portal first
2. Add clear comments explaining the query purpose
3. Include example use cases
4. Update relevant README files
5. Follow naming convention: `##-descriptive-name.kql`

---

## 📅 Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2026-03-10 | Complete rewrite with tested queries for Azure Portal |
| 1.0 | 2026-03-09 | Initial release |

---

**Questions or Issues?**

- Check the troubleshooting section in [`example-kql-copilot-studio.md`](example-kql-copilot-studio.md)
- Review syntax patterns in [`kql-quick-reference.md`](kql-quick-reference.md)
- Validate your data with [`queries/00-quick-validation.kql`](queries/00-quick-validation.kql)
