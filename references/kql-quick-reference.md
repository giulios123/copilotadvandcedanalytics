# KQL Quick Reference for Copilot Studio Telemetry

## Essential Patterns

### Basic Production Filter
```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
```

### Access Custom Dimensions
```kql
| extend messageText = tostring(customDimensions.message)
| extend designMode = tostring(customDimensions.designMode)
```

### Time Windows
```kql
| where timestamp > ago(1h)       // Last hour
| where timestamp > ago(24h)      // Last 24 hours
| where timestamp > ago(7d)       // Last 7 days
| where timestamp > ago(30d)      // Last 30 days
| where timestamp > startofday(now())  // Today
| where timestamp > startofweek(now()) // This week
```

### Time Binning
```kql
| bin(timestamp, 1m)   // Per minute
| bin(timestamp, 1h)   // Per hour
| bin(timestamp, 1d)   // Per day
| bin(timestamp, 7d)   // Per week
```

### Common Aggregations
```kql
| summarize count()                          // Total count
| summarize dcount(user_Id)                  // Unique users
| summarize avg(duration)                    // Average
| summarize min(timestamp), max(timestamp)   // Min/Max
| summarize percentile(duration, 95)         // 95th percentile
| summarize count() by name                  // Group by event type
```

### Filtering Event Types
```kql
| where name == "BotMessageSend"
| where name in ("TopicStart", "TopicEnd")
| where name !in ("TopicAction")
| where name startswith "Topic"
| where name contains "Message"
```

### Datetime Functions
```kql
| extend HourOfDay = hourofday(timestamp)
| extend DayOfWeek = dayofweek(timestamp)
| extend Date = startofday(timestamp)
| extend DaysDiff = datetime_diff('day', now(), timestamp)
| extend HoursDiff = datetime_diff('hour', now(), timestamp)
```

### Visualization
```kql
| render timechart      // Time series line chart
| render barchart       // Bar chart
| render columnchart    // Column chart
| render piechart       // Pie chart
| render table          // Table view
| render areachart      // Area chart
```

### Result Limiting
```kql
| take 100                    // First 100 rows
| top 10 by EventCount desc   // Top 10 by value
| sample 50                   // Random 50 rows
| limit 1000                  // Limit to 1000 rows
```

### Sorting
```kql
| order by timestamp desc      // Descending
| order by timestamp asc       // Ascending
| sort by EventCount desc      // Alternative syntax
```

### Column Operations
```kql
| project timestamp, name, user_Id           // Select specific columns
| project-away customDimensions              // Exclude columns
| extend newColumn = existingColumn * 2      // Create new column
| extend Category = iff(count > 10, "High", "Low")  // Conditional
```

### String Operations
```kql
| where message contains "error"
| where message !contains "test"
| where message startswith "Hello"
| where message endswith "?"
| where isnotempty(message)
| where isempty(message)
```

### Joins (if needed with other tables)
```kql
customEvents
| join kind=inner (
    traces
    | where timestamp > ago(1h)
) on user_Id
```

## Common Query Snippets

### Daily Unique Users
```kql
customEvents
| where timestamp > ago(14d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize UniqueUsers = dcount(user_Id) by bin(timestamp, 1d)
| render timechart
```

### Event Counts by Type
```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize Count = count() by name
| order by Count desc
```

### Top Active Users
```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize EventCount = count() by user_Id
| top 10 by EventCount desc
```

### Agent Performance Comparison
```kql
customEvents
| where timestamp > ago(7d)
| extend designMode = tostring(customDimensions.designMode)
| where designMode == "False"
| summarize
    Events = count(),
    Users = dcount(user_Id)
    by cloud_RoleInstance
| order by Events desc
```

## Schema Fields Quick Reference

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | datetime | Event timestamp (UTC) |
| `name` | string | Event type (BotMessageSend, TopicStart, etc.) |
| `user_Id` | string | User identifier |
| `cloud_RoleName` | string | Platform name |
| `cloud_RoleInstance` | string | Agent/bot instance name |
| `itemType` | string | Always "customEvent" |
| `itemCount` | int | Always 1 |
| `customDimensions` | dynamic | JSON with message, designMode |

## Event Types

| Event Name | Description |
|------------|-------------|
| `BotMessageSend` | Bot sent message to user |
| `TopicStart` | Conversation topic started |
| `TopicEnd` | Conversation topic ended |
| `TopicAction` | Topic action triggered |

## CustomDimensions Fields

| Field | Values | Description |
|-------|--------|-------------|
| `designMode` | "True" / "False" | Test canvas vs production |
| `message` | string | Message text content |

## Pro Tips

1. **Always filter test data**: Include the designMode filter in every production query
2. **Filter early**: Apply `where` clauses before `summarize` for better performance
3. **Use time ranges**: Always specify a time range with `where timestamp > ago()`
4. **Test with `take`**: Use `| take 10` during development to limit results
5. **Check schema**: Run a quick `take 1` query to verify field names
6. **Use `tostring()`**: Always cast customDimensions fields with `tostring()`
7. **Visualize appropriately**: Choose the right chart type for your data

---

**Version**: 1.0
**Last Updated**: 2026-03-10
