# KQL Query Library for Copilot Studio Telemetry

## Overview

This directory contains **ready-to-use KQL queries** for analyzing Microsoft Copilot Studio bot telemetry in Azure Application Insights. Each query is tested and verified to work in the Azure Portal query window.

## How to Use

1. **Navigate to Azure Portal**
   - Go to your Application Insights resource
   - Click on "Logs" in the left menu
   - This opens the query editor

2. **Copy and Paste**
   - Open any `.kql` file from this directory
   - Copy the entire content
   - Paste into the Azure Portal query editor
   - Click "Run" or press `Shift + Enter`

3. **Customize as Needed**
   - Adjust time ranges (`ago(7d)` → `ago(30d)`)
   - Modify filters and conditions
   - Change visualization types

## Query Index

### Getting Started

| File | Description | Use Case |
|------|-------------|----------|
| `00-quick-validation.kql` | Verify data is flowing | First-time setup, troubleshooting |
| `03-production-events-only.kql` | Filter out test canvas | Inspect recent production events |

### User Analytics

| File | Description | Use Case |
|------|-------------|----------|
| `01-daily-active-users.kql` | Unique users per day (14 days) | Track user engagement trends |
| `05-top-active-users.kql` | Top 10 most active users today | Identify power users |
| `10-user-interaction-frequency.kql` | User engagement patterns (14 days) | Segment users by activity |
| `13-new-vs-returning-users.kql` | New vs returning user ratio | Measure user retention |
| `14-conversation-duration.kql` | How long users engage | Understand session length |

### Event Analysis

| File | Description | Use Case |
|------|-------------|----------|
| `02-event-volume-by-type.kql` | Event counts by type (7 days) | Understand event distribution |
| `06-hourly-event-trends.kql` | Event trends by hour (7 days) | Time-series analysis |
| `07-topic-lifecycle.kql` | Topic starts and completions | Track conversation topics |
| `08-message-content-analysis.kql` | Extract message text | Analyze bot responses |

### Agent Performance

| File | Description | Use Case |
|------|-------------|----------|
| `04-agent-activity-summary.kql` | Compare agent activity (7 days) | Multi-agent comparison |
| `11-agent-comparison-dashboard.kql` | Detailed agent metrics (7 days) | Performance dashboard |

### Operational Monitoring

| File | Description | Use Case |
|------|-------------|----------|
| `09-peak-usage-hours.kql` | Usage by hour and day of week | Capacity planning |
| `12-event-rate-per-minute.kql` | Events per minute (1 hour) | Real-time monitoring |

## Common Modifications

### Change Time Range

```kql
// Original
| where timestamp > ago(7d)

// Last 24 hours
| where timestamp > ago(24h)

// Last 30 days
| where timestamp > ago(30d)

// This week
| where timestamp > startofweek(now())

// Custom range
| where timestamp between (datetime(2026-03-01) .. datetime(2026-03-10))
```

### Change Binning Interval

```kql
// Original
| bin(timestamp, 1d)

// Per hour
| bin(timestamp, 1h)

// Per 15 minutes
| bin(timestamp, 15m)

// Per week
| bin(timestamp, 7d)
```

### Filter by Specific Agent

```kql
// Add after the designMode filter
| where cloud_RoleInstance == "Supplier Communications Agent - inbound"
```

### Filter by Event Type

```kql
// Single event type
| where name == "BotMessageSend"

// Multiple event types
| where name in ("TopicStart", "TopicEnd")

// Exclude specific types
| where name !in ("TopicAction")
```

### Change Result Limit

```kql
// Original
| take 100

// Top 50
| take 50

// Top 20 by specific field
| top 20 by EventCount desc
```

## Tips for Azure Portal

1. **Save Queries**: Click "Save" → "Save as query" to keep your favorites
2. **Pin to Dashboard**: Click "Pin to dashboard" to add visualizations
3. **Export Results**: Click "Export" to download as CSV or Excel
4. **Share Queries**: Use "Share" to create a link for team members
5. **Auto-Refresh**: Enable auto-refresh for real-time monitoring dashboards

## Troubleshooting

### Query Fails: "The name 'session_Id' does not refer to any known column"

**Issue**: Your schema doesn't have a `session_Id` field.

**Solution**: Run `00-quick-validation.kql` to check available fields, then modify queries accordingly.

### No Results Returned

**Possible causes**:
- Time range too narrow → increase from `ago(1h)` to `ago(7d)`
- All data is from test canvas → remove or adjust designMode filter
- Wrong event types → check available event names with validation query

### Error: "Cannot convert value to type 'string'"

**Solution**: Always use `tostring()` when accessing customDimensions:

```kql
| extend designMode = tostring(customDimensions.designMode)
```

## Best Practices

1. **Always filter production data** (except when debugging test canvas)
2. **Use appropriate time ranges** (don't query months when you need hours)
3. **Test with `take 10`** before running full queries
4. **Add comments** to document your query modifications
5. **Save working queries** for future reuse

## Additional Resources

- **Full Documentation**: See `example-kql-copilot-studio.md` for detailed explanations
- **Quick Reference**: See `kql-quick-reference.md` for syntax patterns
- **Microsoft Learn**: [KQL Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)

---

**Version**: 1.0
**Last Updated**: 2026-03-10
**Queries Tested**: Azure Application Insights (Azure Portal)
