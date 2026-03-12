# Troubleshooting: Query Returns No Results

## Problem
Your query for BotMessageSend events with production data filter returns no results.

## Diagnostic Queries (Run in Order)

### Step 1: Verify ANY Data Exists (Last 14 Days)

```kql
customEvents
| where timestamp > ago(14d)
| count
```

**Expected**: A number > 0
**If 0**: Your Application Insights has no customEvents data in the last 14 days. Try `ago(30d)` or `ago(90d)`.

---

### Step 2: Check Recent Data Sample

```kql
customEvents
| where timestamp > ago(14d)
| take 10
| project timestamp, name, user_Id, cloud_RoleInstance, customDimensions
```

**What to check**:
- Do you see any rows?
- What values are in the `name` column?
- What does `customDimensions` look like?

---

### Step 3: List All Event Names

```kql
customEvents
| where timestamp > ago(14d)
| summarize Count = count() by name
| order by Count desc
```

**What to check**:
- Is "BotMessageSend" in the list?
- Is it spelled exactly as shown (case-sensitive)?
- Do you see different event names like "BotMessageReceived" or similar?

---

### Step 4: Inspect CustomDimensions Structure

```kql
customEvents
| where timestamp > ago(14d)
| take 1
| project customDimensions
```

**What to check**:
- Does `designMode` exist in customDimensions?
- What is the exact structure of the JSON?
- Are there other fields you need to filter on?

---

### Step 5: Check DesignMode Values

```kql
customEvents
| where timestamp > ago(14d)
| extend designMode = tostring(customDimensions.designMode)
| summarize Count = count() by designMode
```

**What to check**:
- Is the field called `designMode` or something else (e.g., `DesignMode`, `design_mode`)?
- What values exist? ("True", "False", "true", "false", null, empty)?
- Try alternative syntax: `tostring(customDimensions["designMode"])`

---

### Step 6: Check for BotMessageSend Events (Any Mode)

```kql
customEvents
| where timestamp > ago(14d)
| where name == "BotMessageSend"
| count
```

**Expected**: A number > 0
**If 0**: There are no BotMessageSend events at all. Check Step 3 for actual event names.

---

### Step 7: Check BotMessageSend with DesignMode Details

```kql
customEvents
| where timestamp > ago(14d)
| where name == "BotMessageSend"
| extend designMode = tostring(customDimensions.designMode)
| summarize Count = count() by designMode
```

**What to check**:
- How many have `designMode = "False"`?
- How many have `designMode = "True"`?
- How many have null or empty designMode?

---

## Common Issues & Solutions

### Issue 1: Wrong Event Name

**Symptom**: Step 3 shows no "BotMessageSend" event

**Solution**: Use the actual event name from Step 3. Common alternatives:
- `BotMessageReceived`
- `BotMessage`
- `MessageSend`
- Case-sensitive: `botmessagesend` vs `BotMessageSend`

**Fix your query**:
```kql
| where name == "ActualEventNameFromStep3"
```

---

### Issue 2: DesignMode Field Name Different

**Symptom**: Step 5 shows empty or null values

**Solution**: The field might be named differently. Check Step 4 output for exact field name.

Common alternatives:
- `DesignMode` (capital D)
- `design_mode` (snake_case)
- `isDesignMode`
- `testMode`

**Fix your query**:
```kql
| extend designMode = tostring(customDimensions.ActualFieldName)
```

---

### Issue 3: DesignMode Value Different

**Symptom**: Step 7 shows counts but not for "False"

**Possible values**:
- Lowercase: `"false"` instead of `"False"`
- Boolean: `false` instead of `"False"`
- Different values: `"production"`, `"prod"`, `0`

**Fix your query**:
```kql
// For lowercase
| where isDesignMode == "false"

// For boolean (no quotes)
| where customDimensions.designMode == false

// For null/empty (means production)
| where isempty(isDesignMode) or isDesignMode != "True"
```

---

### Issue 4: No Production Data Yet

**Symptom**: Step 7 shows all events have `designMode = "True"`

**Solution**: All your data is from test canvas. You need actual production bot conversations.

**Temporary workaround** (to test query with test data):
```kql
| where isDesignMode == "True"  // Use test data temporarily
```

---

### Issue 5: Data Older Than 14 Days

**Symptom**: Step 1 returns 0, but you know you have data

**Solution**: Extend the time range

```kql
let queryStartDate = ago(90d);  // Try 90 days
```

---

## Alternative Query Syntax to Try

### Option A: Remove DesignMode Filter Temporarily

```kql
let queryStartDate = ago(14d);
let queryEndDate = now();
let groupByInterval = 1d;

customEvents
| where timestamp > queryStartDate
| where timestamp < queryEndDate
| where name == "BotMessageSend"
// TEMPORARILY REMOVED: | extend isDesignMode = tostring(customDimensions['designMode'])
// TEMPORARILY REMOVED: | where isDesignMode == "False"
| summarize MessageCount = count() by bin(timestamp, groupByInterval)
| order by timestamp asc
| render timechart
```

**Purpose**: See if you get ANY results without the designMode filter.

---

### Option B: Use Alternative CustomDimensions Syntax

```kql
// Original syntax
| extend isDesignMode = tostring(customDimensions['designMode'])

// Alternative 1: Dot notation
| extend isDesignMode = tostring(customDimensions.designMode)

// Alternative 2: Direct comparison
| where tostring(customDimensions.designMode) == "False"
```

---

### Option C: Case-Insensitive DesignMode Check

```kql
| extend isDesignMode = tolower(tostring(customDimensions.designMode))
| where isDesignMode == "false"
```

---

### Option D: Check for NULL or Empty

```kql
| extend isDesignMode = tostring(customDimensions.designMode)
| where isnotempty(isDesignMode)  // Only non-empty values
| where isDesignMode == "False"
```

---

## Recommended Diagnostic Process

1. **Run Step 1** → Confirm data exists
2. **Run Step 2** → See what your data looks like
3. **Run Step 3** → Get correct event name
4. **Run Step 4** → Understand customDimensions structure
5. **Run Step 5** → Check designMode values
6. **Update your query** with correct field names and values
7. **Test without filters** (Option A) → Verify BotMessageSend events exist
8. **Add filters back** one at a time

---

## Copy-Paste Diagnostic Script

Run this single query to get all diagnostic info at once:

```kql
// Diagnostic Report for BotMessageSend Query Issue
print "=== DIAGNOSTIC REPORT ==="
| union (
    customEvents
    | where timestamp > ago(14d)
    | summarize TotalEvents = count()
    | extend Section = "1. Total Events (14d)"
)
| union (
    customEvents
    | where timestamp > ago(14d)
    | summarize Count = count() by name
    | top 10 by Count desc
    | extend Section = "2. Top Event Names"
)
| union (
    customEvents
    | where timestamp > ago(14d)
    | where name == "BotMessageSend"
    | summarize BotMessageSendCount = count()
    | extend Section = "3. BotMessageSend Events"
)
| union (
    customEvents
    | where timestamp > ago(14d)
    | where name == "BotMessageSend"
    | extend designMode = tostring(customDimensions.designMode)
    | summarize Count = count() by designMode
    | extend Section = "4. DesignMode Values"
)
| project Section, Count, name, BotMessageSendCount, TotalEvents, designMode
```

---

## Next Steps

After running diagnostics:

1. **Share the results** from Step 2, 3, and 5
2. **I'll provide a corrected query** based on your actual schema
3. **Verify the corrected query works**

---

**Created**: 2026-03-10
**Purpose**: Troubleshoot "no results" issue with BotMessageSend query
