# Copilot Studio KQL Query Collection & Azure Data Explorer Dashboards

## 📋 Overview

This comprehensive collection provides **production-ready KQL queries** and **Azure Data Explorer dashboards** for monitoring **Microsoft Copilot Studio bots** through Azure Application Insights. All queries are designed to work with the actual Copilot Studio telemetry schema using `customEvents` and `customDimensions`.

## 🎯 Purpose

Monitor and evaluate Copilot Studio agents using real telemetry data:
- **Usage Metrics**: Track bot adoption, user activity, channel distribution
- **Performance Metrics**: Monitor response times, latency, and bottlenecks
- **Quality Metrics**: Measure conversation quality and error rates
- **Conversation Analytics**: Analyze user engagement, message patterns, locale distribution
- **Dependencies**: Monitor external API calls and service health
- **Advanced Analytics**: Conversation flows, user patterns, channel performance
- **Alerts**: Production-ready alert queries for Azure Monitor

## 🔍 Copilot Studio Telemetry Schema

This collection is built for the **actual Copilot Studio telemetry structure**:

### CustomEvents Table Fields
| Field | Description | Sample Values |
|-------|-------------|---------------|
| timestamp | Event timestamp (UTC) | 2026-03-09T07:49:20.8189867Z |
| name | Event name/activity | BotMessageSend, TopicStart, TopicEnd |
| itemType | Type of telemetry | customEvent |
| user_Id | User identifier | pva-autonomous01dc5f09-1804-4273-a459-3e34d9c799ca |
| cloud_RoleName | Agent platform | Microsoft Copilot Studio |
| cloud_RoleInstance | Agent name | Supplier Communications Agent - inbound |
| itemCount | Number count | 1 |
| customDimensions | Additional data | { "message": "text", "designMode": "False" } |

### Custom Dimensions
| Field | Description | Sample Values |
|-------|-------------|---------------|
| message | Message text content | "find a coffee shop", "help me" |
| designMode | Test canvas indicator | "True" (test), "False" (production) |

### Key Filtering Pattern
```kql
customEvents
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"  // Exclude test canvas conversations
```

## 📁 Repository Structure

```
CopilotStudio-KQL/
│
├── 01-Usage-Metrics/ (6 queries)
│   ├── 01-overall-bot-usage.kql
│   ├── 02-active-users.kql
│   ├── 03-conversation-sessions.kql
│   ├── 04-peak-hours.kql
│   ├── 05-user-retention.kql
│   └── 06-channel-distribution.kql       # Agent distribution analysis
│
├── 02-Performance-Metrics/ (3 queries)
│   ├── 01-response-latency.kql
│   ├── 02-slow-responses.kql
│   └── 03-performance-trends.kql
│
├── 03-Quality-Metrics/ (3 queries)
│   ├── 01-conversation-quality.kql       ⭐ UPDATED
│   ├── 02-error-analysis.kql
│   └── 03-failed-events.kql              ⭐ UPDATED
│
├── 04-Agent-Evaluation/ (4 queries)
│   ├── 01-conversation-analysis.kql      # Event type breakdown
│   ├── 02-user-engagement.kql
│   ├── 03-locale-analysis.kql            # Agent instance analysis
│   └── 04-conversation-length.kql        # User session length
│
├── 05-Dependencies/ (3 queries)
│   ├── 01-api-dependency-health.kql
│   ├── 02-slow-dependencies.kql
│   └── 03-dependency-failures.kql
│
├── 06-Advanced-Analytics/ (3 queries)
│   ├── 01-conversation-flow-analysis.kql # Event flow transitions
│   ├── 02-user-message-patterns.kql      # Message content analysis
│   └── 03-channel-performance.kql        # Agent performance comparison
│
├── 07-Alerts/ (3 queries)
│   ├── 01-high-error-rate-alert.kql
│   ├── 02-low-activity-alert.kql         ⭐ NEW
│   └── 03-dependency-failure-alert.kql
│
└── Dashboards/ (3 dashboards)
    ├── 01-Overview-Dashboard.json
    ├── 02-Performance-Dashboard.json
    └── 03-Conversation-Analytics-Dashboard.json
```

## 🚀 Quick Start

### Prerequisites

1. **Azure Application Insights** resource collecting Copilot Studio telemetry
2. **Copilot Studio bot** with Application Insights integration enabled
3. **Azure Data Explorer (Kusto)** access or Application Insights query editor
4. Telemetry flowing from Copilot Studio to Application Insights

### Enable Copilot Studio Telemetry

**Step 1**: In Copilot Studio, navigate to **Settings** > **Analytics**

**Step 2**: Enable **Application Insights** integration

**Step 3**: Provide your Application Insights **Instrumentation Key**

**Step 4**: Verify telemetry by running:
```kql
customEvents
| where timestamp > ago(1h)
| extend isDesignMode = tostring(customDimensions['designMode'])
| project timestamp, name, user_Id, cloud_RoleInstance, isDesignMode
| take 10
```

### Using the Queries

1. **Navigate to Application Insights** in Azure Portal
2. Go to **Logs** section
3. Copy and paste any KQL query from this collection
4. Adjust time ranges as needed (default: 7-14 days)
5. Click **Run** to execute

### Dashboard Import

1. **Navigate to Azure Data Explorer** or Application Insights Dashboards
2. Click **Import Dashboard**
3. Upload JSON file from `Dashboards/` folder
4. **Update the data source** in the JSON:
   ```json
   "resourceId": "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/microsoft.insights/components/{app-insights-name}"
   ```
5. Save and view your dashboard

## 📊 Dashboard Descriptions

### 1. Overview Dashboard
**Purpose**: High-level health and usage monitoring

**Key Metrics**:
- Total messages (14 days)
- Active users
- Unique conversations
- Active channels
- Message volume trends
- Daily active users
- Channel distribution
- User retention distribution
- Locale distribution
- Peak usage hours

**Use Case**: Executive overview, daily health checks, stakeholder reporting

---

### 2. Performance Dashboard
**Purpose**: Monitor response times and dependencies

**Key Metrics**:
- Average dependency duration
- P95 dependency duration
- Dependency success rate
- Slow dependencies count (>2s)
- Latency trends over time
- Dependency health overview table
- Exception trends

**Use Case**: SRE monitoring, performance optimization, troubleshooting

---

### 3. Conversation Analytics Dashboard
**Purpose**: Deep insights into conversation patterns

**Key Metrics**:
- Average messages per conversation
- Average message length
- Unique locales count
- Activity type count
- Conversation length distribution
- Activity type distribution
- User engagement levels table
- Message pattern analysis

**Use Case**: UX research, conversation design optimization, user behavior analysis

## 🔍 Key Query Categories

### Usage Metrics (6 queries)
Track adoption and user activity patterns.

**Highlights**:
- **Overall Bot Usage**: Bot message events over time (excluding test canvas)
- **Active Users**: Distinct users per day using `user_Id`
- **Agent Distribution**: Usage across different agent instances by `cloud_RoleInstance`
- **User Retention**: New, occasional, regular, frequent users by activity days

### Performance Metrics (3 queries)
Monitor response times using `dependencies` table.

**Highlights**:
- **Response Latency**: P50, P95, P99 metrics
- **Slow Responses**: Dependencies exceeding 3 seconds
- **Performance Trends**: 30-day performance tracking

### Quality Metrics (3 queries)
Track conversation quality and errors.

**Highlights**:
- **Conversation Quality**: Message exchange analysis
- **Error Analysis**: Exception tracking from `exceptions` table
- **Failed Events**: Custom events indicating failures

### Agent Evaluation (4 queries)
Assess conversation effectiveness.

**Highlights**:
- **Conversation Analysis**: Event type breakdown (BotMessageSend, TopicStart, TopicEnd)
- **User Engagement**: Interaction frequency and patterns
- **Agent Instance Analysis**: Activity distribution across agent instances
- **User Session Length**: Events per user session analysis

### Dependencies (3 queries)
Monitor external API health.

**Highlights**:
- **API Dependency Health**: Success rates and latencies
- **Slow Dependencies**: API calls >2 seconds
- **Dependency Failures**: Failed external calls

### Advanced Analytics (3 queries)
Deep insights into behavior.

**Highlights**:
- **Event Flow**: Event type transitions (BotMessageSend → TopicStart → TopicEnd)
- **Message Content Patterns**: Text analysis, questions, greetings from message content
- **Agent Performance**: Comparative agent instance analysis

### Alerts (3 queries)
Proactive monitoring.

**Highlights**:
- **High Error Rate**: Exception count threshold
- **Low Activity**: Activity drop detection
- **Dependency Failure**: External service failures

## ⚙️ Customization

### Adjusting Time Ranges

```kql
let queryStartDate = ago(14d);  // Change to ago(7d), ago(30d), etc.
let queryEndDate = now();
```

### Filtering by Agent Instance

```kql
| where cloud_RoleInstance == "Supplier Communications Agent - inbound"  // Focus on specific agent
```

### Filtering by Event Type

```kql
| where name == "BotMessageSend"  // Only bot message events
| where name in ("TopicStart", "TopicEnd")  // Topic-related events
```

### Excluding Test Canvas

```kql
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"  // Always include this!
```

## 🔔 Setting Up Alerts

### Azure Monitor Alert Configuration

1. **Navigate to Azure Monitor** > **Alerts** > **New Alert Rule**
2. Choose your Application Insights resource
3. Select **Custom log search**
4. Paste an alert query from `07-Alerts/`
5. Configure alert logic (threshold, frequency, time window)
6. Add action group (email, SMS, webhook)
7. Save the alert rule

### Recommended Alerts

| Alert | Severity | Threshold | Query File |
|-------|----------|-----------|------------|
| High Error Rate | High | > 10 exceptions/hour | 01-high-error-rate-alert.kql |
| Low Activity | Medium | 50% drop from baseline | 02-low-activity-alert.kql |
| Dependency Failure | High | 20% failure rate | 03-dependency-failure-alert.kql |

## 📚 Best Practices

### Query Optimization

1. **Always filter test canvas data**:
   ```kql
   | extend isDesignMode = tostring(customDimensions['designMode'])
   | where isDesignMode == "False"
   ```

2. **Filter early**: Apply `where` clauses before aggregations
3. **Limit time ranges**: Use specific time windows (7d, 14d, 30d)
4. **Project only needed columns**: Reduce data transfer

### Dashboard Design

1. **Start with Overview**: Build high-level dashboards first
2. **Update data source IDs**: Replace placeholders with your resource IDs
3. **Consistent time ranges**: Align all tiles to same period
4. **Test queries**: Run queries manually before adding to dashboards

### Monitoring Strategy

1. **Daily**: Review Overview Dashboard (5 min)
2. **Weekly**: Analyze Conversation Analytics (30 min)
3. **Monthly**: Review performance trends and optimize
4. **Real-time**: Configure critical alerts

## 📖 Additional Documentation

- **IMPLEMENTATION-GUIDE.md**: Step-by-step setup instructions
- **QUICK-REFERENCE.md**: KQL cheat sheet with common patterns
- **PROJECT-SUMMARY.md**: High-level project overview

## 📄 License

MIT License - See LICENSE file for details

## 📞 References

- [Copilot Studio Telemetry Documentation](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-bot-framework-composer-capture-telemetry)
- [KQL Query Language Reference](https://docs.microsoft.com/azure/data-explorer/kusto/query/)
- [Application Insights Documentation](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure Monitor Alerts](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-overview)

---

**Version**: 2.0.0
**Last Updated**: 2026-03-09
**Compatibility**: Microsoft Copilot Studio, Azure Application Insights, Azure Data Explorer
**Schema**: Copilot Studio customEvents with customDimensions
