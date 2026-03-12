# Example KQL Queries for Copilot Studio Telemetry in Application Insights

## Overview

This guide provides **tested and working KQL queries** for analyzing Microsoft Copilot Studio bot telemetry in Azure Application Insights. All queries are compatible with the Azure Portal query window.

---

## Schema Reference

### CustomEvents Table - Core Fields

| Field | Description | Sample Values |
|-------|-------------|---------------|
| `timestamp` | Event timestamp (UTC) | 2026-03-09T07:49:20.8189867Z |
| `name` | Event name/activity | BotMessageSend, TopicStart, TopicEnd, TopicAction |
| `itemType` | Type of telemetry | customEvent |
| `user_Id` | User identifier | pva-autonomous01dc5f09... |
| `cloud_RoleName` | Agent platform | Microsoft Copilot Studio |
| `cloud_RoleInstance` | Agent name | Supplier Communications Agent - inbound |
| `itemCount` | Count of items | 1 |
| `customDimensions` | Additional data (JSON) | { "message": "text", "designMode": "False" } |

### Event Types

- **BotMessageSend**: Bot sent a message to user
- **TopicStart**: Conversation topic started
- **TopicEnd**: Conversation topic ended
- **TopicAction**: Topic-level action triggered

### CustomDimensions Fields

- **designMode**: `"True"` (test canvas) or `"False"` (production)
- **message**: The text content of the message

---

## Essential Queries

### 1. Quick Data Validation

**Purpose**: Verify data is flowing and inspect the schema

```kql
customEvents
| where timestamp > ago(1h)
| take 10
| project timestamp, name, user_Id, cloud_RoleInstance, customDimensions
```

---

### 2. Production Events Only (Exclude Test Canvas)

**Purpose**: Filter out all test data from the Copilot Studio test canvas

```kql
customEvents
| where timestamp > ago(24h)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| project timestamp, name, user_Id, cloud_RoleInstance
| order by timestamp desc
| take 100
```

**Key Pattern**: Always use `tostring(customDimensions.designMode)` to access nested properties.

---

### 3. Daily Active Users (Last 14 Days)

**Purpose**: Track unique users per day (line chart visualization)

```kql
customEvents
| where timestamp > ago(14d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize UniqueUsers = dcount(user_Id) by bin(timestamp, 1d)
| order by timestamp asc
| render timechart
```

---

### 4. Event Volume by Type

**Purpose**: See which events are most common (last 7 days)

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize EventCount = count() by name
| order by EventCount desc
| render barchart
```

---

### 5. Hourly Event Trends by Type

**Purpose**: Time-series view of event types over the last 7 days

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize EventCount = count() by name, bin(timestamp, 1h)
| order by timestamp asc
| render timechart
```

---

### 6. Agent Activity Summary

**Purpose**: Compare activity across different bot instances

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize
    TotalEvents = count(),
    UniqueUsers = dcount(user_Id),
    FirstEvent = min(timestamp),
    LastEvent = max(timestamp)
    by cloud_RoleInstance
| order by TotalEvents desc
```

---

### 7. User Interaction Frequency

**Purpose**: Identify most active users and their engagement patterns

```kql
customEvents
| where timestamp > ago(14d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize
    TotalInteractions = count(),
    UniqueAgents = dcount(cloud_RoleInstance),
    FirstSeen = min(timestamp),
    LastSeen = max(timestamp)
    by user_Id
| extend DaysSinceFirst = datetime_diff('day', now(), FirstSeen)
| where TotalInteractions >= 2
| order by TotalInteractions desc
| take 50
```

---

### 8. Topic Start vs Topic End Analysis

**Purpose**: Track topic lifecycle events

```kql
customEvents
| where timestamp > ago(7d)
| where name in ("TopicStart", "TopicEnd")
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize Count = count() by name, bin(timestamp, 1h)
| order by timestamp asc
| render timechart
```

---

### 9. Message Content Analysis

**Purpose**: Extract and analyze message text from BotMessageSend events

```kql
customEvents
| where timestamp > ago(24h)
| where name == "BotMessageSend"
| extend designMode = tostring(customDimensions.designMode)
| extend messageText = tostring(customDimensions.message)
| where designMode == "False"
| where isnotempty(messageText)
| project timestamp, user_Id, cloud_RoleInstance, messageText
| order by timestamp desc
| take 100
```

---

### 10. Conversation Session Duration

**Purpose**: Calculate how long users engage in conversations

**Note**: This requires a `session_Id` field. Adjust if your schema uses a different field for session tracking.

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize
    StartTime = min(timestamp),
    EndTime = max(timestamp),
    EventCount = count()
    by user_Id
| extend DurationSeconds = datetime_diff('second', EndTime, StartTime)
| where DurationSeconds > 0 and DurationSeconds < 3600
| extend DurationMinutes = DurationSeconds / 60.0
| project user_Id, EventCount, DurationMinutes, StartTime, EndTime
| order by DurationMinutes desc
| take 100
```

---

### 11. Peak Usage Hours (Heatmap Data)

**Purpose**: Identify when users are most active

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| extend HourOfDay = hourofday(timestamp)
| extend DayOfWeek = dayofweek(timestamp)
| summarize EventCount = count() by HourOfDay, DayOfWeek
| order by DayOfWeek asc, HourOfDay asc
```

---

### 12. New vs Returning Users (Last 30 Days)

**Purpose**: Segment users by first-time vs returning activity

```kql
let lookbackPeriod = 30d;
let recentPeriod = 7d;
let historicalUsers = customEvents
    | where timestamp between (ago(lookbackPeriod) .. ago(recentPeriod))
    | extend designMode = tostring(customDimensions.designMode)
    | where designMode == "False"
    | distinct user_Id;
customEvents
| where timestamp > ago(recentPeriod)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize FirstEvent = min(timestamp) by user_Id
| extend UserType = iff(user_Id in (historicalUsers), "Returning", "New")
| summarize UserCount = count() by UserType
| render piechart
```

---

### 13. Event Rate (Events per Minute)

**Purpose**: Monitor event throughput for capacity planning

```kql
customEvents
| where timestamp > ago(1h)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize EventCount = count() by bin(timestamp, 1m)
| order by timestamp asc
| render timechart
```

---

### 14. Top 10 Most Active Users Today

**Purpose**: Quick snapshot of today's power users

```kql
customEvents
| where timestamp > startofday(now())
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize EventCount = count() by user_Id
| top 10 by EventCount desc
```

---

### 15. Agent Comparison Dashboard

**Purpose**: Multi-metric comparison across agents

```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize
    TotalEvents = count(),
    UniqueUsers = dcount(user_Id),
    AvgEventsPerUser = count() / dcount(user_Id),
    BotMessages = countif(name == "BotMessageSend"),
    TopicsStarted = countif(name == "TopicStart"),
    TopicsCompleted = countif(name == "TopicEnd")
    by cloud_RoleInstance
| extend TopicCompletionRate = round(100.0 * TopicsCompleted / TopicsStarted, 2)
| order by TotalEvents desc
```

---

## Best Practices for Azure Portal Queries

### 1. Always Filter Production Data

```kql
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
```

### 2. Use Time Ranges Efficiently

```kql
// Good - uses indexed timestamp
| where timestamp > ago(7d)

// Avoid - less efficient
| where timestamp > datetime(2026-03-01)
```

### 3. Access Custom Dimensions Correctly

```kql
// Correct syntax for nested JSON
| extend messageText = tostring(customDimensions.message)
| extend designMode = tostring(customDimensions.designMode)

// Alternative bracket notation
| extend messageText = tostring(customDimensions["message"])
```

### 4. Filter Before Aggregation

```kql
// Good - filter first, then aggregate
customEvents
| where timestamp > ago(7d)
| where name == "BotMessageSend"
| summarize count() by user_Id

// Less efficient - aggregates then filters
customEvents
| summarize count() by user_Id, name
| where name == "BotMessageSend"
```

### 5. Use Appropriate Visualizations

```kql
| render timechart     // For time-series data
| render barchart      // For category comparisons
| render piechart      // For proportions/distributions
| render columnchart   // For grouped comparisons
| render table         // For detailed data inspection
```

---

## Troubleshooting Common Errors

### Error: "The name 'session_Id' does not refer to any known column"

**Solution**: Check your actual schema. Use this query to discover available fields:

```kql
customEvents
| take 1
| project timestamp, name, itemType, user_Id, cloud_RoleName, cloud_RoleInstance, itemCount, customDimensions
```

### Error: "Syntax error near 'render'"

**Solution**: Ensure there's no semicolon before `render` and it's the last operator in the query.

### Error: "Cannot convert value to type 'string'"

**Solution**: Always use `tostring()` when extracting from `customDimensions`:

```kql
| extend value = tostring(customDimensions.fieldName)
```

---

## Query Optimization Tips

1. **Limit time ranges**: Use `ago(7d)` instead of `ago(90d)` when possible
2. **Project early**: Only select columns you need
3. **Filter before joins**: Reduce data volume before complex operations
4. **Use summarize wisely**: Aggregate at appropriate granularity
5. **Test with `take`**: Use `| take 100` during development to limit results

---

## Additional Resources

- [Kusto Query Language (KQL) Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Application Insights Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Copilot Studio Telemetry Guide](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-bot-framework-composer-capture-telemetry)

---

**Last Updated**: 2026-03-10
**Version**: 2.0
**Tested Environment**: Azure Application Insights Query Window
