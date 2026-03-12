# Azure Data Explorer Dashboard Creation - Technical Guide

This document contains critical technical requirements and common pitfalls when creating Azure Data Explorer dashboards for Copilot Studio monitoring, based on lessons learned during implementation.

---

## Table of Contents
- [Dashboard JSON Schema Requirements](#dashboard-json-schema-requirements)
- [UUID Format Requirements](#uuid-format-requirements)
- [Visualization Types](#visualization-types)
- [Tile Size Requirements](#tile-size-requirements)
- [Copilot Studio Event Names](#copilot-studio-event-names)
- [Field Extraction from customDimensions](#field-extraction-from-customdimensions)
- [Query Structure](#query-structure)
- [Data Source Configuration](#data-source-configuration)
- [Parameters vs Filters](#parameters-vs-filters)
- [Common Errors and Solutions](#common-errors-and-solutions)

---

## Dashboard JSON Schema Requirements

### Required Root-Level Fields

Azure Data Explorer dashboards **MUST** include these exact fields:

```json
{
  "$schema": "https://dataexplorer.azure.com/static/d/schema/69/dashboard.json",
  "id": "UUID-HERE",
  "eTag": "UUID-HERE",
  "title": "Dashboard Title",
  "schema_version": 69,
  "tiles": [],
  "baseQueries": [],
  "parameters": [],
  "dataSources": [],
  "pages": [],
  "queries": []
}
```

### ❌ Invalid Fields to Avoid

These fields are **NOT** part of Azure Data Explorer schema:
- `version` - Use `schema_version` instead
- `dataSource` (singular) - Use `dataSources` (array) instead
- `filters` - Use `parameters` instead
- `refreshInterval` - Not supported in schema v69
- `description` at root level - Use per-tile descriptions

---

## UUID Format Requirements

### RFC 4122 UUID Format

**All IDs must follow RFC 4122 format with hyphens:**

✅ **Correct:**
```json
"id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
"queryId": "30000000-0000-0000-0000-000000000001"
"pageId": "20000000-0000-0000-0000-000000000001"
"dataSourceId": "50000000-0000-0000-0000-000000000001"
```

❌ **Incorrect:**
```json
"id": "copilot-datasource"
"queryId": "query-total-messages"
"pageId": "overview-page"
```

### Which IDs Need UUIDs?

Every single ID field must be a UUID:
- Dashboard `id`
- Dashboard `eTag`
- All `dataSources[].id`
- All `pages[].id`
- All `tiles[].id`
- All `tiles[].pageId`
- All `tiles[].queryRef.queryId`
- All `queries[].id`
- All `queries[].dataSource.dataSourceId`
- All `parameters[].id`

### Error Message if Wrong Format:
```
Needs to follow the UUID format as defined by RFC 4122
Example: 3e4666bf-d5e5-4aa7-b8ce-cefe41c7568a
```

---

## Visualization Types

### Valid Visual Types (schema v69)

Azure Data Explorer **ONLY** supports these visualization types:

| Visual Type | Use Case | Example |
|-------------|----------|---------|
| `table` | Tables and single-value metrics | KPI cards, data tables |
| `pie` | Pie/donut charts | Distribution analysis |
| `line` | Line charts | Trends over time |
| `area` | Area charts | Cumulative trends |
| `timechart` | Time series | Time-based metrics |

### ❌ Invalid Visual Types

These types **DO NOT EXIST** in Azure Data Explorer:

```json
// ❌ WRONG - These will cause "Visual type X is not supported" error
"visualType": "singlestat"  // Use "table" instead
"visualType": "card"        // Use "table" instead
"visualType": "column"      // Use "line" instead
"visualType": "columnchart" // Use "line" instead
"visualType": "barchart"    // Use "line" instead
```

### Displaying Single Metrics (KPI Cards)

For single-value displays like "Total Messages: 1,234", use `table` visualization:

```json
{
  "visualType": "table",
  "query": "| summarize TotalMessages = count() | project TotalMessages"
}
```

### Time-Based Distribution Charts

For hourly/daily distributions (like "Peak Usage Hours"), use `line` chart:

**Example: Peak Hours by Hour of Day**
```json
{
  "visualType": "line",
  "title": "Peak Usage Hours (UTC)",
  "query": "customEvents\n| where name == 'BotMessageSend'\n| extend HourOfDay = hourofday(timestamp)\n| summarize MessageCount = count(), UniqueUsers = dcount(user_Id) by HourOfDay\n| order by HourOfDay asc"
}
```

**Query Returns Multiple Series:**
- `HourOfDay` (0-23) - X-axis
- `MessageCount` - Series 1 (blue line)
- `UniqueUsers` - Series 2 (orange line)

**Visualization Notes:**
- Azure Data Explorer dashboards will display this as a line chart
- Each numeric column (except the `by` column) becomes a series
- Perfect for showing patterns over time periods (hours, days, weeks)

**Alternative for KQL Editor:**
In standalone KQL queries, you can use `| render columnchart`, but in dashboards, use `visualType: "line"` instead.

---

## Tile Size Requirements

### Minimum Tile Size: 4x4

Azure Data Explorer enforces a **minimum tile size of 4 width × 4 height**:

✅ **Valid Sizes:**
```json
"layout": {"x": 0, "y": 0, "width": 4, "height": 4}   // Minimum
"layout": {"x": 0, "y": 0, "width": 8, "height": 6}   // Medium chart
"layout": {"x": 0, "y": 0, "width": 16, "height": 6}  // Full width
```

❌ **Invalid Sizes:**
```json
"layout": {"x": 0, "y": 0, "width": 3, "height": 2}   // Too small!
"layout": {"x": 0, "y": 0, "width": 2, "height": 4}   // Width too small!
```

### Error Message:
```
Current tile size (3, 2) is smaller than the minimum supported tile size (4, 4)
```

### Recommended Tile Sizes

| Use Case | Width | Height |
|----------|-------|--------|
| KPI Cards (single metrics) | 4 | 4 |
| Small charts | 6-8 | 5-6 |
| Medium charts | 8-12 | 6-8 |
| Large charts | 12-16 | 6-8 |
| Tables | 8-16 | 5-8 |
| Full-width visuals | 16-24 | 6-10 |

---

## Copilot Studio Event Names

### Event Types (name field)

Copilot Studio uses specific event names in the `name` field of `customEvents`:

```kql
// ✅ CORRECT - Filter by event name
customEvents
| where name == "BotMessageSend"    // Bot messages
| where name == "TopicStart"        // Topic starts
| where name == "TopicEnd"          // Topic ends
```

### ❌ Common Mistake: Using activityType

```kql
// ❌ WRONG - activityType field doesn't exist!
customEvents
| where activityType == "message"  // Field doesn't exist!
```

### Error Message:
```
'where' operator: Failed to resolve column or scalar expression named 'activityType'
```

### Available Event Types

| Event Name | Description |
|------------|-------------|
| `BotMessageSend` | Bot sent a message to user |
| `TopicStart` | Conversation topic started |
| `TopicEnd` | Conversation topic ended |
| `SessionStart` | User session started |
| `SessionEnd` | User session ended |

---

## Field Extraction from customDimensions

### Correct Field Names

Fields are stored in the `customDimensions` JSON object and must be extracted:

✅ **Correct Extraction:**
```kql
customEvents
| extend isDesignMode = tostring(customDimensions['designMode'])
| extend messageText = tostring(customDimensions['message'])        // ✅ 'message'
| extend locale = tostring(customDimensions['locale'])
| extend conversationId = tostring(customDimensions['conversationId'])
| extend fromId = tostring(customDimensions['fromId'])
| extend fromName = tostring(customDimensions['fromName'])
```

### ❌ Common Field Name Mistakes

```kql
// ❌ WRONG Field Names
| extend text = tostring(customDimensions['text'])              // Should be 'message'
| extend activityType = tostring(customDimensions['activityType'])  // Doesn't exist
| extend channelId = tostring(customDimensions['channelId'])    // May not exist
```

### Field Name Reference

| ✅ Correct Field | ❌ Wrong Field | Purpose |
|-----------------|----------------|---------|
| `message` | `text` | Message content |
| `designMode` | N/A | Test mode flag |
| `locale` | `language` | User language |
| `conversationId` | N/A | Conversation grouping |
| `fromId` | `userId` | User identifier |
| `fromName` | `userName` | User display name |

---

## Query Structure

### Tile Query Reference Structure

Tiles reference queries using `queryRef`, not embedded queries:

✅ **Correct Structure:**
```json
{
  "tiles": [{
    "id": "tile-uuid",
    "queryRef": {
      "kind": "query",
      "queryId": "query-uuid"
    }
  }],
  "queries": [{
    "id": "query-uuid",
    "dataSource": {
      "kind": "inline",
      "dataSourceId": "datasource-uuid"
    },
    "text": "customEvents | where name == 'BotMessageSend' | count",
    "usedVariables": ["_startTime", "_endTime"]
  }]
}
```

❌ **Incorrect - Embedded Query:**
```json
{
  "tiles": [{
    "id": "tile-uuid",
    "query": "customEvents | count"  // ❌ Don't embed queries!
  }]
}
```

### Query Components

Every query must have:
1. **`id`** - UUID for the query
2. **`dataSource.kind`** - Always `"inline"`
3. **`dataSource.dataSourceId`** - References datasource UUID
4. **`text`** - The KQL query text
5. **`usedVariables`** - Array of parameter variables used (e.g., `["_startTime", "_endTime"]`)

---

## Data Source Configuration

### Application Insights Connection

For Application Insights, use this exact structure:

```json
{
  "dataSources": [{
    "kind": "manual-kusto",
    "id": "50000000-0000-0000-0000-000000000001",
    "name": "CopilotStudio-AppInsights",
    "clusterUri": "https://ade.applicationinsights.io/subscriptions/YOUR-SUB-ID/resourcegroups/YOUR-RG/",
    "database": "YOUR-APPINSIGHTS-NAME",
    "queryResultsCacheMaxAge": 300,
    "scopeId": "kusto"
  }]
}
```

### Required Fields

| Field | Type | Example | Notes |
|-------|------|---------|-------|
| `kind` | string | `"manual-kusto"` | Always this value |
| `id` | UUID | `"50000000..."` | Must be valid UUID |
| `name` | string | `"CopilotStudio-AppInsights"` | Display name |
| `clusterUri` | string | `"https://ade.applicationinsights.io/..."` | Must end with `/` |
| `database` | string | `"appi-name"` | App Insights resource name |
| `queryResultsCacheMaxAge` | number | `300` | Seconds (5 min) |
| `scopeId` | string | `"kusto"` | Always this value |

### URL Format

```
https://ade.applicationinsights.io/subscriptions/{SUB-ID}/resourcegroups/{RG-NAME}/
```

**Important:**
- Use lowercase `resourcegroups` (not `resourceGroups`)
- URL must end with trailing `/`
- Use actual subscription ID and resource group name

---

## Parameters vs Filters

### Use `parameters` Array (Not `filters`)

Azure Data Explorer uses `parameters`, not `filters`:

✅ **Correct:**
```json
{
  "parameters": [{
    "kind": "duration",
    "id": "40000000-0000-0000-0000-000000000001",
    "displayName": "Time range",
    "description": "Time range for the dashboard",
    "beginVariableName": "_startTime",
    "endVariableName": "_endTime",
    "defaultValue": {
      "kind": "dynamic",
      "count": 14,
      "unit": "days"
    },
    "showOnPages": {
      "kind": "all"
    }
  }]
}
```

❌ **Incorrect:**
```json
{
  "filters": [{  // ❌ Wrong - use "parameters"
    "id": "time-range",
    "type": "timeRange",
    "defaultValue": "Last 14 days"
  }]
}
```

### Parameter Types

| Type | Use For | Variable Names |
|------|---------|----------------|
| `duration` | Time ranges | `_startTime`, `_endTime` |
| `string` | Text filters | Custom variable name |
| `number` | Numeric filters | Custom variable name |

---

## Common Errors and Solutions

### Error 1: Visual Type Not Supported

**Error Message:**
```
Visual type singlestat is not supported
```

**Cause:** Using invalid visualization type

**Solution:**
```json
// ❌ Wrong
"visualType": "singlestat"

// ✅ Correct
"visualType": "table"
```

---

### Error 2: UUID Format Required

**Error Message:**
```
Needs to follow the UUID format as defined by RFC 4122
```

**Cause:** Using string names instead of UUIDs

**Solution:**
```json
// ❌ Wrong
"id": "total-messages"
"queryId": "query-total-messages"

// ✅ Correct
"id": "10000000-0000-0000-0000-000000000001"
"queryId": "30000000-0000-0000-0000-000000000001"
```

---

### Error 3: Tile Size Too Small

**Error Message:**
```
Current tile size (3, 2) is smaller than the minimum supported tile size (4, 4)
```

**Cause:** Tile dimensions below 4x4

**Solution:**
```json
// ❌ Wrong
"layout": {"x": 0, "y": 0, "width": 3, "height": 2}

// ✅ Correct
"layout": {"x": 0, "y": 0, "width": 4, "height": 4}
```

---

### Error 4: Column Not Found (activityType)

**Error Message:**
```
'where' operator: Failed to resolve column or scalar expression named 'activityType'
```

**Cause:** Using non-existent field name

**Solution:**
```kql
-- ❌ Wrong
| where activityType == "message"

-- ✅ Correct
| where name == "BotMessageSend"
```

---

### Error 5: queryRef Structure Invalid

**Error Message:**
```
must have required property 'baseQueryId'
must NOT have unevaluated properties
```

**Cause:** Incorrect queryRef structure

**Solution:**
```json
// ❌ Wrong
"queryRef": {
  "queryId": "some-id"
}

// ✅ Correct
"queryRef": {
  "kind": "query",
  "queryId": "30000000-0000-0000-0000-000000000001"
}
```

---

### Error 6: Tile Shows No Data

**Symptoms:**
- Tile displays but shows "No data" or empty results
- Query executes without errors but returns zero rows
- Other tiles work fine, only specific tiles affected

**Common Causes:**

#### Cause 6.1: cloud_RoleName Filter Mismatch

**Problem:** Query filters for a role name that doesn't exist in your data

```kql
// ❌ This may not match your data
exceptions
| where cloud_RoleName == "Microsoft Copilot Studio"
```

**Solution:**
1. Check what role names actually exist in your data:
```kql
dependencies | distinct cloud_RoleName
exceptions | distinct cloud_RoleName
```

2. Remove the filter if it doesn't match, or adjust to match your actual data:
```kql
// ✅ Option 1: Remove role filter entirely
exceptions
| where timestamp between (_startTime .. _endTime)
| summarize ExceptionCount = count() by bin(timestamp, 1h)

// ✅ Option 2: Use actual role name from your data
exceptions
| where timestamp between (_startTime .. _endTime)
| where cloud_RoleName == "YourActualRoleName"
```

#### Cause 6.2: Exceptions Table Has No Data

**Problem:** Your Application Insights may not have exception data

**Solution:** Verify data exists:
```kql
exceptions
| where timestamp > ago(7d)
| count
```

If count is 0, the table is empty. **Remove the tile entirely** rather than leaving it blank.

#### Cause 6.3: Wrong Table for Copilot Studio Events

**Problem:** Using wrong table (exceptions, traces) instead of customEvents

**Solution:**
```kql
// ❌ Wrong - Copilot Studio events aren't in exceptions
exceptions
| where name == "BotMessageSend"

// ✅ Correct - Use customEvents table
customEvents
| where name == "BotMessageSend"
```

**Best Practice:** If a tile consistently shows no data after fixing filters:
1. Test the query directly in Azure Data Explorer query editor
2. Verify the table has data for your time range
3. If no data exists and none is expected, **remove the tile** from the dashboard

---

### How to Remove a Tile and Query

When removing unused tiles (like "Exception Trends"):

**Step 1: Remove the tile from `tiles` array**
```json
// Find and remove the tile object with matching ID
{
  "id": "11000000-0000-0000-0000-000000000007",
  "title": "Exception Trends",
  // ... remove entire object
}
```

**Step 2: Remove the associated query from `queries` array**
```json
// Find and remove query with matching ID
{
  "id": "31000000-0000-0000-0000-000000000007",
  // ... remove entire object
}
```

**Step 3: Remove any parameters only used by that tile**
```json
// If a parameter was only for this tile, remove it too
```

**Important:** The `queryId` in tile's `queryRef` must match the query's `id` - remove both together.

---

## Troubleshooting Data Issues

### Quick Diagnostic Steps

1. **Test query in ADX query editor first:**
   - Copy query text from dashboard JSON
   - Replace parameter variables: `_startTime` → `ago(7d)`, `_endTime` → `now()`
   - Run directly against your database

2. **Check table exists and has data:**
   ```kql
   customEvents | count
   dependencies | count
   exceptions | count
   ```

3. **Verify event names:**
   ```kql
   customEvents
   | where timestamp > ago(7d)
   | distinct name
   | order by name asc
   ```

4. **Check cloud_RoleName values:**
   ```kql
   customEvents
   | distinct cloud_RoleName
   dependencies
   | distinct cloud_RoleName
   ```

5. **Confirm customDimensions structure:**
   ```kql
   customEvents
   | where name == "BotMessageSend"
   | take 1
   | project customDimensions
   ```

### Data Availability Matrix

| Table | Copilot Studio Events | Always Available? |
|-------|----------------------|-------------------|
| `customEvents` | ✅ Yes - BotMessageSend, TopicStart, TopicEnd | Required |
| `dependencies` | ✅ Yes - External API calls | Usually available |
| `exceptions` | ⚠️ Maybe - Only if errors occur | Optional |
| `traces` | ⚠️ Maybe - Depends on logging level | Optional |
| `pageViews` | ❌ No - Not used by Copilot Studio | Not applicable |

**Recommendation:** Only include tiles for tables that consistently have data in your environment.

---

## Validation Checklist

Before importing a dashboard, verify:

- [ ] All IDs are RFC 4122 UUIDs (with hyphens)
- [ ] `visualType` uses only valid types (table, pie, line, area, timechart)
- [ ] All tile sizes are minimum 4x4
- [ ] Queries use `name == "BotMessageSend"` (not activityType)
- [ ] Field extraction uses correct names (`message` not `text`)
- [ ] Tiles use `queryRef` structure (not embedded queries)
- [ ] Data source has `clusterUri` ending with `/`
- [ ] Using `parameters` array (not `filters`)
- [ ] All queries reference correct `dataSourceId` UUID
- [ ] `usedVariables` arrays match parameter variable names

---

## Example: Complete Valid Tile Configuration

```json
{
  "tiles": [{
    "id": "10000000-0000-0000-0000-000000000001",
    "title": "Total Messages",
    "visualType": "table",
    "pageId": "20000000-0000-0000-0000-000000000001",
    "layout": {"x": 0, "y": 0, "width": 4, "height": 4},
    "queryRef": {
      "kind": "query",
      "queryId": "30000000-0000-0000-0000-000000000001"
    },
    "description": "Total bot messages",
    "visualOptions": {
      "crossFilterDisabled": false,
      "drillthroughDisabled": false
    }
  }],
  "queries": [{
    "id": "30000000-0000-0000-0000-000000000001",
    "dataSource": {
      "kind": "inline",
      "dataSourceId": "50000000-0000-0000-0000-000000000001"
    },
    "text": "customEvents\n| where timestamp between (_startTime .. _endTime)\n| where name == \"BotMessageSend\"\n| extend isDesignMode = tostring(customDimensions['designMode'])\n| where isempty(isDesignMode) or tolower(isDesignMode) != \"true\"\n| summarize TotalMessages = count()\n| project TotalMessages",
    "usedVariables": ["_startTime", "_endTime"]
  }]
}
```

---

## Best Practices

### 1. UUID Generation Pattern

Use a consistent pattern for UUIDs:
- **10000000-xxxx...** for tile IDs
- **20000000-xxxx...** for page IDs
- **30000000-xxxx...** for query IDs
- **40000000-xxxx...** for parameter IDs
- **50000000-xxxx...** for datasource IDs

### 2. Query Optimization

Always include these filters in Copilot Studio queries:
```kql
| where timestamp between (_startTime .. _endTime)
| where name == "BotMessageSend"
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
```

### 3. Field Extraction Order

Extract fields before filtering:
```kql
-- ✅ Correct order
| extend isDesignMode = tostring(customDimensions['designMode'])
| extend messageText = tostring(customDimensions['message'])
| where name == "BotMessageSend"
| where isnotempty(messageText)

-- ❌ Wrong - filtering before extraction may fail
| where name == "BotMessageSend"
| where isnotempty(customDimensions['message'])  // May not work
```

### 4. Handle Missing Fields

Always handle potentially missing fields:
```kql
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
// This handles: null, "", "false", "False", "FALSE"
```

### 5. Test Queries Before Adding to Dashboard

**Always test queries in Azure Data Explorer query editor first:**

```kql
// Step 1: Replace parameters with actual values
let _startTime = ago(7d);
let _endTime = now();

// Step 2: Run your query
customEvents
| where timestamp between (_startTime .. _endTime)
| where name == "BotMessageSend"
| summarize count()
```

**Verify:**
- Query returns data (not empty)
- Query executes without errors
- Results make sense for your use case

**Only add to dashboard after successful testing.**

### 6. Remove Tiles with No Data

Don't leave empty tiles on dashboards:

**When to Remove:**
- Tile consistently shows "No data"
- Table doesn't exist in your Application Insights
- Filter criteria don't match your data (e.g., wrong `cloud_RoleName`)
- Feature not enabled (e.g., no exception tracking)

**Benefits of Removal:**
- Cleaner dashboard appearance
- Faster dashboard loading
- Less confusion for users
- Reduced maintenance overhead

**Process:**
1. Identify tile ID from dashboard JSON
2. Remove tile object from `tiles` array
3. Find matching query ID from tile's `queryRef.queryId`
4. Remove query object from `queries` array
5. Test dashboard import to ensure no broken references

### 7. Cloud Role Name Filtering

Be cautious with `cloud_RoleName` filters:

```kql
// ⚠️ This filter may be too restrictive
| where cloud_RoleName == "Microsoft Copilot Studio"

// ✅ Better: Check what values actually exist first
dependencies | distinct cloud_RoleName
exceptions | distinct cloud_RoleName

// ✅ Or remove the filter entirely if not needed
| where timestamp between (_startTime .. _endTime)
```

**Common cloud_RoleName values:**
- `"Microsoft Copilot Studio"` - Official Copilot Studio events
- Your custom application name
- Empty/null for some event types

**Best Practice:** Only filter by `cloud_RoleName` if you have multiple applications logging to the same Application Insights and need to isolate data.

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-03-11 | 1.1 | Added troubleshooting for tiles with no data, cloud_RoleName filtering issues, process for removing unused tiles, time-based chart visualization guidance, and best practices for testing queries |
| 2026-03-11 | 1.0 | Initial documentation with all corrections from dashboard conversion |

---

## References

- [Azure Data Explorer Dashboard Schema](https://dataexplorer.azure.com/static/d/schema/69/dashboard.json)
- [RFC 4122 UUID Specification](https://datatracker.ietf.org/doc/html/rfc4122)
- [KQL Reference](https://docs.microsoft.com/azure/data-explorer/kusto/query/)
- [Copilot Studio Analytics](https://docs.microsoft.com/power-virtual-agents/analytics-overview)

---

**Last Updated:** 2026-03-11 (v1.1)
**Maintained by:** Development Team
**Status:** Active Reference Guide - Updated with troubleshooting and best practices
