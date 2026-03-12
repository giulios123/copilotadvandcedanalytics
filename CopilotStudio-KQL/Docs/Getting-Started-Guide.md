# Getting Started Guide - Copilot Studio Analytics

Welcome! This guide will help you get started with monitoring and analyzing your Microsoft Copilot Studio bot using Azure Data Explorer dashboards.

**Target Audience:** Beginners new to Copilot Studio monitoring, KQL queries, and Azure Data Explorer dashboards.

---

## Table of Contents

1. [What Is This Project?](#what-is-this-project)
2. [Prerequisites](#prerequisites)
3. [Understanding the Project Structure](#understanding-the-project-structure)
4. [Quick Start (5 Minutes)](#quick-start-5-minutes)
5. [Detailed Setup Guide](#detailed-setup-guide)
6. [Understanding KQL Queries](#understanding-kql-queries)
7. [Working with Dashboards](#working-with-dashboards)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

---

## What Is This Project?

### The Problem
You've built a Copilot Studio bot, but you need to answer questions like:
- How many users are using my bot?
- What times are busiest?
- Are there any performance issues?
- Which conversations are most common?

### The Solution
This project provides:
1. **Ready-to-use KQL queries** - Pre-written queries to analyze your bot data
2. **Azure Data Explorer dashboards** - Visual dashboards you can import and use immediately
3. **Documentation** - Guides to help you understand and customize everything

### What You'll Get
- 📊 **3 Pre-built Dashboards:**
  - Overview Dashboard - High-level metrics
  - Performance Dashboard - Technical health monitoring
  - Conversation Analytics - User behavior analysis

- 📝 **20+ KQL Query Files:**
  - Organized by category (Usage, Performance, Quality, etc.)
  - Copy-paste ready
  - Well-documented with comments

---

## Prerequisites

### Required Access

✅ **You MUST have:**

1. **Microsoft Copilot Studio Bot**
   - An active bot in Copilot Studio
   - Bot must be connected to Application Insights

2. **Azure Subscription**
   - Access to Azure Portal
   - Permissions to read Application Insights data

3. **Application Insights**
   - Your Copilot Studio bot connected to Application Insights
   - Data being collected (at least a few days worth)

4. **Azure Data Explorer Access**
   - Ability to access https://dataexplorer.azure.com
   - Read permissions on your Application Insights

### Optional (But Helpful)

✅ **Nice to have:**
- Basic understanding of Azure services
- Familiarity with data visualization concepts
- A text editor (VS Code, Notepad++, etc.)

### Tools Installation

No special tools required! Everything works in your web browser:
- ✅ Web browser (Chrome, Edge, or Firefox)
- ✅ Access to Azure Portal
- ✅ Access to Azure Data Explorer

---

## Understanding the Project Structure

```
CopilotStudio-KQL/
├── Dashboards/                          ← Dashboard files ready to import
│   ├── 01-Overview-Dashboard.json       ← High-level metrics
│   ├── 02-Performance-Dashboard.json    ← Performance monitoring
│   ├── 03-Conversation-Analytics-Dashboard.json ← User behavior
│   ├── README.md                        ← Dashboard documentation
│   └── SKILL.md                         ← Technical reference
│
├── 01-Usage-Metrics/                    ← KQL queries for usage analysis
│   ├── 01-overall-bot-usage.kql
│   ├── 02-active-users.kql
│   ├── 04-peak-hours.kql
│   └── ...
│
├── 02-Performance-Metrics/              ← KQL queries for performance
│   ├── 01-response-latency.kql
│   └── ...
│
├── 03-Quality-Metrics/                  ← KQL queries for quality
├── 04-Agent-Evaluation/                 ← KQL queries for analytics
├── 05-Dependencies/                     ← KQL queries for dependencies
│
└── Docs/                                ← Documentation (you are here!)
    └── Getting-Started-Guide.md
```

### Key Files Explained

| File | What It Is | When To Use |
|------|------------|-------------|
| `*.json` files in Dashboards/ | Pre-configured dashboard definitions | Import these to create instant visual dashboards |
| `*.kql` files in numbered folders | Individual queries you can run | Use when you want to run specific analysis queries |
| `README.md` in Dashboards/ | Dashboard user guide | Read this for dashboard usage instructions |
| `SKILL.md` in Dashboards/ | Technical reference | Use when troubleshooting or customizing |
| This guide | Beginner tutorial | Start here if you're new! |

---

## Quick Start (5 Minutes)

Follow these steps to get your first dashboard running:

### Step 1: Find Your Application Insights Details

1. Open **Azure Portal** (https://portal.azure.com)
2. Search for your Application Insights resource
3. Note down these three values:
   - **Subscription ID** (found in Overview)
   - **Resource Group** name
   - **Application Insights name**

**Example:**
```
Subscription ID: dc296289-f97a-48ef-9f15-cd0beaa285dc
Resource Group: rg-copilot-prod
App Insights Name: appi-copilot-bot-insights
```

### Step 2: Open Azure Data Explorer

1. Go to https://dataexplorer.azure.com
2. Sign in with your Azure account
3. You should see the Azure Data Explorer interface

### Step 3: Import Your First Dashboard

1. In Azure Data Explorer, click **"Dashboards"** in the left menu
2. Click **"Import dashboard"** (or "+" → Import)
3. Click **"Browse"** and select:
   - `CopilotStudio-KQL/Dashboards/01-Overview-Dashboard.json`
4. The dashboard file will open
5. Click **"Import"**

**✅ That's it!** Your first dashboard is now imported.

### Step 4: View Your Data

1. The dashboard should load automatically
2. You'll see tiles showing metrics like:
   - Total Messages
   - Active Users
   - Message Volume Over Time
   - Peak Usage Hours

If tiles show "No data":
- Check your time range (top of dashboard)
- Verify your bot has been active during that time
- See [Troubleshooting](#troubleshooting) section below

---

## Detailed Setup Guide

### Understanding Application Insights Connection

Your Copilot Studio bot sends telemetry data to Application Insights:

```
Copilot Studio Bot → Application Insights → Azure Data Explorer Dashboard
                     (Automatic)          (You connect manually)
```

**How to verify the connection:**

1. Open Azure Portal
2. Go to your Application Insights resource
3. Click **"Logs"** in the left menu
4. Run this simple query:
   ```kql
   customEvents
   | where name == "BotMessageSend"
   | count
   ```
5. If you see a number > 0, data is flowing! ✅

### Configuring Dashboard Data Sources

**Note:** The dashboard JSON files are already pre-configured with placeholder values. You need to update them with your actual Azure resource details.

#### Option 1: Edit Before Import (Recommended)

1. Open the dashboard JSON file in a text editor
2. Find the `dataSources` section (near the bottom)
3. Update these values:
   ```json
   "clusterUri": "https://ade.applicationinsights.io/subscriptions/YOUR-SUB-ID/resourcegroups/YOUR-RG/",
   "database": "YOUR-APPINSIGHTS-NAME"
   ```
4. Replace:
   - `YOUR-SUB-ID` → Your subscription ID
   - `YOUR-RG` → Your resource group name
   - `YOUR-APPINSIGHTS-NAME` → Your Application Insights name
5. Save the file
6. Import to Azure Data Explorer

#### Option 2: Edit After Import

1. Import the dashboard as-is
2. In Azure Data Explorer, open the dashboard
3. Click **"Edit"** (pencil icon)
4. Click **"Data sources"** tab
5. Update the connection details
6. Click **"Apply"** and **"Save"**

---

## Understanding KQL Queries

### What is KQL?

**KQL** = **K**usto **Q**uery **L**anguage

It's a language for querying data in Azure services. Think of it like SQL but optimized for log and telemetry data.

### Basic KQL Structure

Every KQL query follows this pattern:

```kql
TableName                           ← Which table to query
| where [condition]                 ← Filter the data
| summarize [aggregation]           ← Calculate statistics
| order by [column]                 ← Sort results
```

### Example: Count Bot Messages

```kql
customEvents                        // Look in customEvents table
| where name == "BotMessageSend"    // Only bot messages
| where timestamp > ago(7d)         // Last 7 days
| count                             // Count how many
```

**What this does:**
1. Looks at the `customEvents` table (where Copilot Studio logs events)
2. Filters for only "BotMessageSend" events (actual bot messages)
3. Filters for last 7 days
4. Counts them

**Result:** Single number like `1,234`

### How to Run KQL Queries

#### Method 1: In Azure Data Explorer Query Editor

1. Go to https://dataexplorer.azure.com
2. Click **"Query"** in the left menu
3. Make sure you're connected to your Application Insights:
   - Click **"Add"** → **"Connection"**
   - Select **"Application Insights"**
   - Choose your resource
4. Paste a query from the `.kql` files
5. Click **"Run"** or press `Shift+Enter`

#### Method 2: In Azure Portal

1. Go to your Application Insights resource
2. Click **"Logs"** in the left menu
3. Paste a query
4. Click **"Run"**

### Your First Query

Let's try a simple one:

**File:** `01-Usage-Metrics/01-overall-bot-usage.kql`

```kql
let queryStartDate = ago(14d);
let queryEndDate = now();

customEvents
| where timestamp between (queryStartDate .. queryEndDate)
| where name == "BotMessageSend"
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
| summarize MessageCount = count() by bin(timestamp, 1d)
| order by timestamp asc
| render timechart
```

**What each line does:**

| Line | Purpose |
|------|---------|
| `let queryStartDate = ago(14d)` | Set start date to 14 days ago |
| `let queryEndDate = now()` | Set end date to now |
| `customEvents` | Query the customEvents table |
| `where timestamp between (...)` | Filter to date range |
| `where name == "BotMessageSend"` | Only actual bot messages |
| `extend isDesignMode = ...` | Extract the designMode field |
| `where isempty(isDesignMode)...` | Exclude test messages from canvas |
| `summarize MessageCount = count() by bin(timestamp, 1d)` | Count messages per day |
| `order by timestamp asc` | Sort by date ascending |
| `render timechart` | Display as a chart |

**Result:** A line chart showing messages per day over the last 14 days

---

## Working with Dashboards

### Dashboard Components

Each dashboard has:

1. **Tiles** - Individual visualization boxes (charts, tables, numbers)
2. **Parameters** - Filters you can adjust (like time range)
3. **Queries** - The KQL behind each tile (hidden from view)
4. **Pages** - Multiple tabs to organize content

### Using Dashboard Controls

#### Time Range Selector

Found at the top of every dashboard:

```
[Time range: Last 14 days ▼]
```

**Change it to:**
- Last 24 hours
- Last 7 days
- Last 14 days (default)
- Last 30 days
- Custom range

#### Refresh Dashboard

Click the **🔄 Refresh** button to reload data

**Auto-refresh:** Dashboards refresh automatically every 5 minutes

#### Export Data

1. Click on any tile
2. Click **"..." menu** in the corner
3. Select **"Export to Excel"** or **"Export to CSV"**

### Reading Dashboard Tiles

#### Metric Cards (Single Numbers)

```
┌─────────────────────┐
│ Total Messages      │
│                     │
│      1,234          │
└─────────────────────┘
```

**What it shows:** A single KPI value

#### Line Charts

```
Message Volume Over Time
  │    ╱╲
  │   ╱  ╲  ╱╲
  │  ╱    ╲╱  ╲
  │ ╱          ╲
  └──────────────
   Mon  Tue  Wed
```

**What it shows:** Trends over time

#### Pie Charts

```
Channel Distribution
     ╱───╲
    │ 45% │ Teams
    │ 35% │ Web
    │ 20% │ Other
     ╲───╱
```

**What it shows:** Proportions and percentages

#### Tables

```
┌─────────────┬──────┬────────┐
│ Agent Name  │ Msgs │ Users  │
├─────────────┼──────┼────────┤
│ Bot-Agent-1 │ 450  │ 120    │
│ Bot-Agent-2 │ 380  │ 95     │
└─────────────┴──────┴────────┘
```

**What it shows:** Detailed data in rows and columns

---

## Common Tasks

### Task 1: Check Daily Bot Usage

**Question:** "How many messages did my bot send today?"

**Solution:**

1. Open `01-Overview-Dashboard.json` dashboard
2. Look at **"Total Messages"** tile
3. Change time range to **"Last 24 hours"**
4. Read the number

**Or run this query:**
```kql
customEvents
| where timestamp > ago(1d)
| where name == "BotMessageSend"
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
| count
```

### Task 2: Find Peak Usage Hours

**Question:** "When is my bot busiest?"

**Solution:**

1. Open `01-Overview-Dashboard.json` dashboard
2. Scroll to **"Peak Usage Hours (UTC)"** tile
3. Look for the highest bars/points in the chart

**Or run this query:**
```kql
customEvents
| where timestamp > ago(14d)
| where name == "BotMessageSend"
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
| extend HourOfDay = hourofday(timestamp)
| summarize MessageCount = count() by HourOfDay
| order by MessageCount desc
| take 5
```

### Task 3: Check Performance Issues

**Question:** "Are there any slow API calls?"

**Solution:**

1. Open `02-Performance-Dashboard.json` dashboard
2. Look at **"Slow Dependencies (>2s)"** tile
3. If the number is > 0, check **"Dependency Health Overview"** table
4. Sort by **"AvgDurationMs"** to find slowest calls

### Task 4: Analyze User Engagement

**Question:** "How engaged are my users?"

**Solution:**

1. Open `03-Conversation-Analytics-Dashboard.json` dashboard
2. Look at **"User Engagement Levels"** table
3. Check distribution:
   - High Engagement = Power users
   - Medium = Regular users
   - Low/Minimal = Trying it out

### Task 5: Export Dashboard as PDF

**Steps:**

1. Open dashboard in Azure Data Explorer
2. Click **"..."** menu (top right)
3. Select **"Print dashboard"**
4. In print dialog, select **"Save as PDF"**
5. Choose location and save

---

## Troubleshooting

### Problem 1: Dashboard Shows No Data

**Symptoms:** Tiles are empty or show "No data"

**Possible Causes & Solutions:**

#### Cause 1: Time Range Too Old
- **Fix:** Change time range to include recent data
- **Check:** Click time selector, try "Last 24 hours"

#### Cause 2: Bot Not Connected to Application Insights
- **Fix:** Verify connection in Copilot Studio:
  1. Open your bot in Copilot Studio
  2. Go to **Settings** → **Analytics**
  3. Check Application Insights is connected
  4. If not, connect it and wait 24 hours for data

#### Cause 3: No Bot Activity
- **Fix:** Use your bot to generate test data
- **Action:** Have a test conversation with your bot

#### Cause 4: Wrong Application Insights Resource
- **Fix:** Verify you're querying the correct App Insights
- **Check:** In dashboard, click Edit → Data sources → Verify name

### Problem 2: Query Returns Error

**Common Error Messages:**

#### Error: "Column 'activityType' not found"

```
'where' operator: Failed to resolve column or scalar expression named 'activityType'
```

**Fix:** Use correct event filtering
```kql
// ❌ Wrong
| where activityType == "message"

// ✅ Correct
| where name == "BotMessageSend"
```

#### Error: "Syntax error"

**Fix:** Check for:
- Missing quotes around strings
- Typos in column names
- Missing `|` pipe operators

### Problem 3: Dashboard Import Fails

**Error Message:** "Invalid dashboard format" or "UUID format error"

**Fix:** Dashboard JSON is corrupted or wrong format
- **Action:** Re-download the JSON file from the repository
- **Check:** Open in text editor, verify it's valid JSON
- **Alternative:** Copy contents from GitHub directly

### Problem 4: Permission Denied

**Error Message:** "Access denied" or "Insufficient permissions"

**Fix:** You need read permissions on Application Insights
- **Contact:** Your Azure administrator
- **Request:** Reader role on Application Insights resource

---

## Next Steps

### After You're Comfortable with Basics

1. **Explore More KQL Queries**
   - Browse the numbered folders (`01-Usage-Metrics`, `02-Performance-Metrics`, etc.)
   - Try running different queries
   - Experiment with modifying them

2. **Customize Dashboards**
   - Edit tiles to change colors or layouts
   - Add new tiles with custom queries
   - Create your own dashboard from scratch

3. **Set Up Alerts**
   - Use Azure Monitor to create alerts
   - Get notified when metrics exceed thresholds
   - Example: Alert when error count > 10

4. **Schedule Reports**
   - Export dashboards as PDF
   - Email them to stakeholders
   - Create weekly/monthly reports

5. **Deep Dive into Analytics**
   - Read the SKILL.md technical reference
   - Study the KQL query patterns
   - Learn advanced KQL techniques

### Learning Resources

#### Official Documentation

- **Azure Data Explorer:** https://docs.microsoft.com/azure/data-explorer/
- **KQL Reference:** https://docs.microsoft.com/azure/data-explorer/kql-quick-reference
- **Copilot Studio Analytics:** https://docs.microsoft.com/power-virtual-agents/analytics-overview

#### Practice KQL

- **KQL Tutorial:** https://docs.microsoft.com/azure/data-explorer/kusto/query/tutorial
- **Sample Queries:** Browse the `.kql` files in this project
- **Interactive Demo:** https://dataexplorer.azure.com/clusters/help/databases/Samples

#### Community

- **Microsoft Tech Community:** https://techcommunity.microsoft.com/
- **Azure Data Explorer Forum:** Search for "Azure Data Explorer" on Microsoft Q&A

---

## Glossary of Terms

| Term | What It Means |
|------|---------------|
| **Application Insights** | Azure service that collects telemetry from apps and bots |
| **Azure Data Explorer (ADX)** | Service for analyzing large amounts of data with KQL |
| **Copilot Studio** | Microsoft platform for building AI chatbots |
| **customEvents** | Table in App Insights containing bot events |
| **dependencies** | Table containing external API calls and their performance |
| **Dashboard** | Visual interface showing multiple charts and metrics |
| **KQL** | Kusto Query Language - language for querying data |
| **Tile** | Individual visualization box on a dashboard |
| **BotMessageSend** | Event name when bot sends a message to user |
| **designMode** | Flag indicating test messages from Copilot Studio canvas |
| **cloud_RoleName** | Field identifying which application sent the data |
| **timestamp** | Date and time when event occurred |
| **bin()** | Function to group data into time buckets (hourly, daily, etc.) |
| **summarize** | KQL keyword to aggregate data (count, avg, sum, etc.) |
| **render** | KQL keyword to display results as chart |

---

## FAQ (Frequently Asked Questions)

### Q: Do I need to know programming?

**A:** No! You can use the pre-built dashboards without any coding. If you want to customize queries, basic understanding of SQL-like syntax helps but isn't required.

### Q: How much does this cost?

**A:**
- Application Insights: Pay for data ingestion (first 5GB/month free)
- Azure Data Explorer: Free for querying existing App Insights data
- Dashboards: Free

**Typical cost:** $10-50/month for small-medium bot usage

### Q: Can I use this with multiple bots?

**A:** Yes! Either:
1. Connect all bots to same Application Insights (simpler)
2. Create separate dashboards for each bot (more organized)

### Q: How often is data updated?

**A:**
- Application Insights: Near real-time (1-2 minutes)
- Dashboard: Refreshes every 5 minutes automatically

### Q: Can I share dashboards with my team?

**A:** Yes!
1. In Azure Data Explorer, open the dashboard
2. Click **"Share"** button
3. Choose who to share with
4. They need read access to your Application Insights

### Q: What if I break something?

**A:** Don't worry! You can:
- Re-import the original dashboard JSON files
- Queries are read-only (they can't modify data)
- You can't break Application Insights by querying it

### Q: Where is my data stored?

**A:**
- Your bot data stays in **your** Azure Application Insights
- You control the data retention (default: 90 days)
- This is YOUR data in YOUR Azure subscription

---

## Quick Reference Card

**Print this section for easy reference!**

### Most Common Queries

```kql
// Count total messages today
customEvents
| where timestamp > ago(1d)
| where name == "BotMessageSend"
| count

// Active users last 7 days
customEvents
| where timestamp > ago(7d)
| where name == "BotMessageSend"
| summarize Users = dcount(user_Id)

// Peak hour today
customEvents
| where timestamp > ago(1d)
| where name == "BotMessageSend"
| extend Hour = hourofday(timestamp)
| summarize Count = count() by Hour
| order by Count desc
| take 1
```

### Dashboard Files Quick Reference

| File | What to Use It For |
|------|-------------------|
| `01-Overview-Dashboard.json` | Daily monitoring, usage stats |
| `02-Performance-Dashboard.json` | Technical health, API performance |
| `03-Conversation-Analytics-Dashboard.json` | User behavior, engagement |

### Key KQL Patterns

```kql
// Filter by date
| where timestamp between (startDate .. endDate)

// Count
| count

// Count distinct
| summarize dcount(column)

// Average
| summarize avg(column)

// Group by day
| summarize count() by bin(timestamp, 1d)

// Exclude test data
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isempty(isDesignMode) or tolower(isDesignMode) != "true"
```

---

## Getting Help

### If You're Stuck

1. **Check the troubleshooting section** in this guide
2. **Read SKILL.md** for technical details
3. **Review the README.md** in Dashboards folder
4. **Test queries in Azure Data Explorer** query editor
5. **Check official Microsoft documentation**

### Before Asking for Help, Have Ready:

- Screenshot of the error/issue
- Which dashboard or query you're using
- Your Application Insights resource name
- Time range you're querying
- What you expected vs. what you got

---

## Congratulations! 🎉

You've completed the Getting Started Guide!

**You now know how to:**
- ✅ Import dashboards into Azure Data Explorer
- ✅ Run KQL queries to analyze bot data
- ✅ Read and understand dashboard tiles
- ✅ Troubleshoot common issues
- ✅ Customize and extend the analytics

**Next:** Start exploring your bot's data and discover insights!

---

**Document Version:** 1.0
**Last Updated:** 2026-03-11
**Feedback:** Report issues or suggestions via your team's communication channel

**Happy Analyzing! 📊**
