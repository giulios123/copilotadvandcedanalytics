# Copilot Studio KQL Project - Complete Summary

## 📦 What Was Created

This project provides a **complete, production-ready monitoring solution** for **Microsoft Copilot Studio bots** using **Azure Application Insights** and **KQL queries** based on the **actual Copilot Studio telemetry schema**.

### Total Deliverables

- **25 KQL Query Files** (organized in 7 categories)
- **3 Azure Data Explorer Dashboard JSON Files** (ready to import)
- **4 Comprehensive Documentation Files**

---

## 📁 Complete File Structure

```
CopilotStudio-KQL/
│
├── 📄 README.md                          # Main documentation
├── 📄 IMPLEMENTATION-GUIDE.md            # Step-by-step setup instructions
├── 📄 QUICK-REFERENCE.md                 # KQL cheat sheet & quick queries
├── 📄 PROJECT-SUMMARY.md                 # This file
│
├── 📂 01-Usage-Metrics/ (6 queries)
│   ├── 01-overall-bot-usage.kql
│   ├── 02-active-users.kql
│   ├── 03-conversation-sessions.kql
│   ├── 04-peak-hours.kql
│   ├── 05-user-retention.kql
│   └── 06-channel-distribution.kql       ⭐ Copilot-specific
│
├── 📂 02-Performance-Metrics/ (3 queries)
│   ├── 01-response-latency.kql
│   ├── 02-slow-responses.kql
│   └── 03-performance-trends.kql
│
├── 📂 03-Quality-Metrics/ (3 queries)
│   ├── 01-conversation-quality.kql
│   ├── 02-error-analysis.kql
│   └── 03-failed-events.kql
│
├── 📂 04-Agent-Evaluation/ (4 queries)
│   ├── 01-conversation-analysis.kql
│   ├── 02-user-engagement.kql
│   ├── 03-locale-analysis.kql            ⭐ Copilot-specific
│   └── 04-conversation-length.kql
│
├── 📂 05-Dependencies/ (3 queries)
│   ├── 01-api-dependency-health.kql
│   ├── 02-slow-dependencies.kql
│   └── 03-dependency-failures.kql
│
├── 📂 06-Advanced-Analytics/ (3 queries)
│   ├── 01-conversation-flow-analysis.kql
│   ├── 02-user-message-patterns.kql     ⭐ Copilot-specific
│   └── 03-channel-performance.kql       ⭐ Copilot-specific
│
├── 📂 07-Alerts/ (3 queries)
│   ├── 01-high-error-rate-alert.kql
│   ├── 02-low-activity-alert.kql        ⭐ Copilot-specific
│   └── 03-dependency-failure-alert.kql
│
└── 📂 Dashboards/ (3 dashboards)
    ├── 01-Overview-Dashboard.json
    ├── 02-Performance-Dashboard.json
    └── 03-Conversation-Analytics-Dashboard.json
```

---

## 🎯 Key Features & Updates

### ✅ Version 2.0 - Copilot Studio Schema Alignment

This version is **completely rewritten** to use the **actual Copilot Studio telemetry schema**:

#### **Custom Dimensions Used**
| Field | Purpose | Queries Using It |
|-------|---------|------------------|
| `type` | Activity type (message, conversationUpdate, event) | All usage queries |
| `cloud_RoleInstance` | Channel (msteams, webchat, directline) | Channel distribution, performance |
| `user_Id` | User identifier | User tracking, engagement |
| `fromName` | User display name | User analysis |
| `locale` | User language/region | Locale analysis |
| `text` | Message content | Message pattern analysis |
| `designMode` | Test vs. production indicator | ALL queries (filter) |
| `conversationId` | Conversation identifier | Conversation analysis |

#### **Production vs. Test Filtering**
Every query includes this critical filter:
```kql
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"  // Production data only
```

#### **Copilot Studio-Specific Queries**
- **Channel Distribution**: Usage across msteams, webchat, directline
- **Locale Analysis**: Geographic/language distribution
- **User Message Patterns**: Text analysis, questions, greetings
- **Channel Performance**: Comparative analysis across channels
- **Low Activity Alert**: Detects activity drops vs. baseline

---

## 📊 Query Categories Breakdown

### 1. Usage Metrics (6 queries)
**Purpose**: Track bot adoption and user engagement

| Query | What It Shows | Copilot Studio Fields Used |
|-------|---------------|----------------------------|
| Overall Bot Usage | Message volume over time | type, designMode |
| Active Users | Unique daily users | user_Id, designMode |
| Conversation Sessions | Session metrics | conversationId, type |
| Peak Hours | Hourly usage distribution | type, designMode |
| User Retention | New vs. returning users | user_Id, conversationId |
| Channel Distribution | Usage by channel | **cloud_RoleInstance**, type |

### 2. Performance Metrics (3 queries)
**Purpose**: Monitor response times and system performance

| Query | What It Shows | Data Source |
|-------|---------------|-------------|
| Response Latency | P50, P95, P99 latencies | dependencies table |
| Slow Responses | Responses >3 seconds | dependencies table |
| Performance Trends | 30-day performance trends | dependencies table |

### 3. Quality Metrics (3 queries)
**Purpose**: Track conversation quality and errors

| Query | What It Shows | Focus |
|-------|---------------|-------|
| Conversation Quality | Message exchange analysis | Message completion rate |
| Error Analysis | Exception breakdown | exceptions table |
| Failed Events | Problematic custom events | Error indicators in messages |

### 4. Agent Evaluation (4 queries)
**Purpose**: Assess conversation effectiveness

| Query | What It Shows | Copilot Studio Fields Used |
|-------|---------------|----------------------------|
| Conversation Analysis | Activity type breakdown | type, conversationId |
| User Engagement | Message frequency patterns | user_Id, text, conversationId |
| Locale Analysis | Language/region distribution | **locale**, user_Id |
| Conversation Length | Messages per conversation | conversationId, type |

### 5. Dependencies (3 queries)
**Purpose**: Monitor external API health

| Query | What It Shows | Use Case |
|-------|---------------|----------|
| API Dependency Health | Success rates and latencies | Integration monitoring |
| Slow Dependencies | API calls >2 seconds | Performance tuning |
| Dependency Failures | Failed external calls | Service reliability |

### 6. Advanced Analytics (3 queries)
**Purpose**: Deep insights into user behavior

| Query | What It Shows | Copilot Studio Fields Used |
|-------|---------------|----------------------------|
| Conversation Flow | Activity type transitions | type, conversationId |
| User Message Patterns | Text analysis (length, questions) | **text**, user_Id |
| Channel Performance | Comparative channel metrics | **cloud_RoleInstance**, type |

### 7. Alerts (3 queries)
**Purpose**: Proactive monitoring

| Query | Trigger Condition | Severity |
|-------|-------------------|----------|
| High Error Rate | >10 exceptions/hour | High |
| Low Activity | 50% drop from baseline | Medium |
| Dependency Failure | 20% failure rate | High |

---

## 📈 Dashboard Descriptions

### 1. Overview Dashboard (10 tiles)
**Audience**: Executives, Product Managers
**Refresh**: Every 5 minutes
**Time Range**: 14 days

**Metrics**:
- Total messages
- Active users
- Unique conversations
- Active channels
- Message volume chart
- Daily active users chart
- Channel distribution pie chart
- User retention pie chart
- Locale distribution bar chart
- Peak hours column chart

### 2. Performance Dashboard (7 tiles)
**Audience**: DevOps, SRE Teams
**Refresh**: Every 5 minutes
**Time Range**: 7 days

**Metrics**:
- Avg dependency duration
- P95 dependency duration
- Dependency success rate
- Slow dependencies count
- Latency trends line chart
- Dependency health table
- Exception trends line chart

### 3. Conversation Analytics Dashboard (8 tiles)
**Audience**: Conversation Designers, UX Researchers
**Refresh**: Every 5 minutes
**Time Range**: 14 days

**Metrics**:
- Avg messages per conversation
- Avg message length
- Unique locales
- Activity type count
- Conversation length distribution
- Activity type distribution
- User engagement levels table
- Message pattern analysis table

---

## 🚀 Getting Started (Quick Guide)

### Step 1: Enable Telemetry (5 minutes)
1. Open Copilot Studio > Settings > Analytics
2. Enable **Application Insights**
3. Enter **Instrumentation Key** from Azure
4. Save settings

### Step 2: Verify Data Flow (5 minutes)
```kql
customEvents
| where timestamp > ago(1h)
| extend isDesignMode = tostring(customDimensions['designMode'])
| take 10
```

### Step 3: Run Queries (10 minutes)
1. Open Application Insights > Logs
2. Copy query from any `.kql` file
3. Run and analyze results

### Step 4: Import Dashboards (15 minutes)
1. Update JSON files with your resource IDs
2. Import to Azure Portal
3. Verify data displays correctly

### Step 5: Set Up Alerts (10 minutes)
1. Use queries from `07-Alerts/`
2. Create Azure Monitor alert rules
3. Configure action groups

**Total Setup Time**: ~45 minutes

---

## 🔑 Key Differences from Generic Bot Monitoring

### ❌ What This Collection Does NOT Use
- Generic `requests` table filters
- Generic `operation_Id` correlation
- Generic custom event names like "ConversationStart", "TopicTriggered"
- Assumed telemetry that may not exist in Copilot Studio

### ✅ What This Collection DOES Use
- **Copilot Studio's actual custom dimensions**: type, cloud_RoleInstance, user_Id, locale, text, designMode
- **designMode filter**: Always excludes test canvas data
- **customEvents table**: Primary data source for bot activity
- **dependencies table**: For bot performance metrics
- **exceptions table**: For error tracking
- **Channel-specific analysis**: msteams, webchat, directline
- **Locale analysis**: For international user distribution

---

## 📊 Sample Data Schema

### Typical customEvent Record from Copilot Studio

```json
{
  "timestamp": "2026-03-09T10:30:00Z",
  "name": "ActivityEvent",
  "customDimensions": {
    "type": "message",
    "cloud_RoleInstance": "msteams",
    "user_Id": "user-abc-123",
    "fromName": "John Doe",
    "locale": "en-us",
    "recipientId": "bot-xyz-789",
    "recipientName": "Customer Support Bot",
    "text": "I need help with my order",
    "designMode": "False",
    "conversationId": "conv-abc123xyz"
  }
}
```

---

## ✅ Success Criteria

### Week 1
- [ ] Application Insights configured
- [ ] Telemetry flowing from production channels
- [ ] At least 3 queries tested successfully
- [ ] 1 dashboard imported and showing data

### Month 1
- [ ] All dashboards imported and monitored daily
- [ ] Team trained on dashboard usage
- [ ] At least 1 alert configured and tested
- [ ] Baseline KPIs established

### Quarter 1
- [ ] Data-driven conversation optimizations implemented
- [ ] Reduced user drop-off based on analytics
- [ ] Improved channel distribution strategy
- [ ] Documented ROI from monitoring insights

---

## 📚 Documentation Overview

### README.md (Main Documentation)
- Complete overview
- Copilot Studio schema details
- Repository structure
- Dashboard descriptions
- Customization guide

### IMPLEMENTATION-GUIDE.md (Setup Instructions)
- Step-by-step Azure setup
- Copilot Studio telemetry configuration
- Dashboard import instructions
- Troubleshooting guide
- Security best practices

### QUICK-REFERENCE.md (Cheat Sheet)
- Common query patterns
- Copilot Studio custom dimensions
- Filtering examples
- Aggregation patterns
- Pro tips

### PROJECT-SUMMARY.md (This File)
- High-level project overview
- File structure
- Key features and updates
- Quick start guide
- Success criteria

---

## 🎓 Learning Path

### Beginner (Day 1-2)
1. Enable Application Insights in Copilot Studio
2. Verify telemetry flow
3. Run 3-5 simple queries
4. Import Overview Dashboard

### Intermediate (Week 1)
1. Test all query categories
2. Import all dashboards
3. Customize for your bot
4. Set up 1 alert

### Advanced (Month 1)
1. Create custom queries for specific needs
2. Build custom dashboards
3. Implement full alerting strategy
4. Train team on analytics-driven optimization

---

## 🆘 Common Issues & Solutions

### No Data in Application Insights
**Solution**: Verify Copilot Studio Analytics settings are enabled and instrumentation key is correct

### All Data Shows designMode == "True"
**Solution**: Send messages from published channels (Teams, Web Chat), not test canvas

### Missing Custom Dimensions
**Solution**: Enable "Collect User Data" in Copilot Studio analytics settings

### Dashboard Tiles Show Zero
**Solution**: Increase time range from 7d to 30d; verify queries match your data schema

---

## 📊 Project Statistics

| Category | Count | Description |
|----------|-------|-------------|
| KQL Query Files | 25 | Production-ready queries |
| Dashboard JSON Files | 3 | Import-ready dashboards |
| Documentation Files | 4 | Comprehensive guides |
| Query Categories | 7 | Organized by purpose |
| Dashboard Tiles | 25 | Visualization components |
| Custom Dimensions | 9 | Copilot Studio fields |
| Time Investment | ~1 hour | Complete setup time |

---

## 🎉 What You Get

### Immediate Value
✅ Production-ready Copilot Studio monitoring
✅ 25 tested KQL queries
✅ 3 comprehensive dashboards
✅ Complete documentation
✅ Real-world telemetry schema

### Long-term Benefits
✅ Improved bot performance visibility
✅ Faster incident detection
✅ Data-driven conversation optimization
✅ Better understanding of user behavior
✅ Channel-specific insights
✅ International user analytics (locale)

---

## 🚦 Next Steps

1. **Read** the README.md file
2. **Follow** the IMPLEMENTATION-GUIDE.md
3. **Enable** Application Insights in Copilot Studio
4. **Verify** telemetry is flowing
5. **Test** queries in Application Insights
6. **Import** dashboards to Azure
7. **Configure** alerts for critical metrics
8. **Train** your team on dashboard usage
9. **Optimize** conversations based on insights

---

**🎯 Goal**: Enable comprehensive, production-grade monitoring of Microsoft Copilot Studio bots using their actual telemetry schema.

**✅ Status**: Complete and ready to deploy

**📅 Version**: 2.0.0 (Copilot Studio Schema)

**📆 Last Updated**: 2026-03-09

---

**Happy Monitoring! 📊🤖**
