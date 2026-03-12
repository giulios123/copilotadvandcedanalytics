# KQL Quick Reference for Copilot Studio Monitoring

## 🎯 Copilot Studio Telemetry Schema

### Essential Fields

**Direct Fields:**
```kql
customEvents
| project
    timestamp,              // Event timestamp (UTC)
    name,                   // Event name: BotMessageSend, TopicStart, TopicEnd
    itemType,               // customEvent
    user_Id,                // User identifier
    cloud_RoleName,         // Microsoft Copilot Studio
    cloud_RoleInstance,     // Agent name
    itemCount              // Count
```

**Custom Dimensions:**
```kql
customEvents
| extend
    messageText = tostring(customDimensions['message']),      // Message text content
    isDesignMode = tostring(customDimensions['designMode'])   // "True" (test) / "False" (production)
```

### Always Exclude Test Canvas

```kql
customEvents
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"  // Production data only!
```

## 📊 Common Queries by Use Case

### Daily Health Check

```kql
// Quick overview of last 24 hours
let queryStartDate = ago(24h);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    name = tostring(customDimensions['type']),
    user_Id = tostring(customDimensions['user_Id'])
| where isDesignMode == "False" and name == "message"
| summarize
    TotalMessages = count(),
    UniqueUsers = dcount(user_Id),
    UniqueConversations = dcount(tostring(customDimensions['conversationId']))
| project
    Period = "Last 24 Hours",
    TotalMessages,
    UniqueUsers,
    UniqueConversations
```

### Find Most Active Users

```kql
// Top 20 users by message count (14 days)
let queryStartDate = ago(14d);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    name = tostring(customDimensions['type']),
    user_Id = tostring(customDimensions['user_Id']),
    fromName = tostring(customDimensions['fromName'])
| where isDesignMode == "False" and name == "message"
| summarize MessageCount = count() by user_Id, fromName
| order by MessageCount desc
| take 20
```

### Track Specific User Journey

```kql
// Follow a specific user's interactions
let userId = "user-123";  // Replace with actual user ID
let queryStartDate = ago(7d);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    user_Id = tostring(customDimensions['user_Id']),
    name = tostring(customDimensions['type']),
    text = tostring(customDimensions['message']),
    cloud_RoleInstance = tostring(customDimensions['cloud_RoleInstance'])
| where isDesignMode == "False" and user_Id == userId
| project
    Timestamp = timestamp,
    ActivityType = name,
    MessageText = text,
    Channel = cloud_RoleInstance,
    ConversationId = tostring(customDimensions['conversationId'])
| order by Timestamp asc
```

### Detect Activity Drop

```kql
// Compare current hour to baseline
let currentHour = customEvents
| where timestamp > ago(1h)
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"
| summarize CurrentCount = count();

let yesterdayHour = customEvents
| where timestamp between (ago(25h) .. ago(24h))
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"
| summarize YesterdayCount = count();

currentHour
| extend dummy = 1
| join (yesterdayHour | extend dummy = 1) on dummy
| project
    CurrentCount,
    YesterdayCount,
    ChangePercent = round(((todouble(CurrentCount) - todouble(YesterdayCount)) / todouble(YesterdayCount)) * 100, 2),
    Status = case(
        ((todouble(CurrentCount) - todouble(YesterdayCount)) / todouble(YesterdayCount)) < -0.5, "⚠️ Significant Drop",
        ((todouble(CurrentCount) - todouble(YesterdayCount)) / todouble(YesterdayCount)) < -0.2, "⚡ Decreased",
        ((todouble(CurrentCount) - todouble(YesterdayCount)) / todouble(YesterdayCount)) > 0.2, "📈 Increased",
        "✅ Normal"
    )
```

### Find Long Conversations

```kql
// Conversations with 10+ messages
let queryStartDate = ago(7d);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    name = tostring(customDimensions['type']),
    conversationId = tostring(customDimensions['conversationId'])
| where isDesignMode == "False" and name == "message"
| where isnotempty(conversationId)
| summarize
    MessageCount = count(),
    StartTime = min(timestamp),
    EndTime = max(timestamp)
    by conversationId
| where MessageCount >= 10
| extend DurationMinutes = datetime_diff('minute', EndTime, StartTime)
| project conversationId, MessageCount, DurationMinutes, StartTime, EndTime
| order by MessageCount desc
```

## 🔍 Filtering Cheat Sheet

### Time Ranges

```kql
| where timestamp > ago(1h)                  // Last hour
| where timestamp > ago(24h)                 // Last 24 hours
| where timestamp > ago(7d)                  // Last 7 days
| where timestamp > ago(14d)                 // Last 14 days
| where timestamp > ago(30d)                 // Last 30 days
| where timestamp > startofday(now())        // Today
| where timestamp > startofweek(now())       // This week
| where timestamp between (ago(7d) .. ago(1d)) // 1-7 days ago
```

### Channel Filtering

```kql
// Specific channel
| where cloud_RoleInstance == "msteams"           // Microsoft Teams only
| where cloud_RoleInstance == "webchat"           // Web Chat only
| where cloud_RoleInstance == "directline"        // Direct Line only

// Multiple channels
| where cloud_RoleInstance in ("msteams", "webchat")

// Exclude emulator
| where cloud_RoleInstance != "emulator"
```

### Activity Type Filtering

```kql
// Messages only
| where name == "message"

// Conversation updates only
| where name == "conversationUpdate"

// Multiple types
| where name in ("message", "event")
```

### Locale Filtering

```kql
// English speakers
| where locale in ("en-us", "en-gb", "en-GB", "en-US")

// Non-English
| where locale !startswith "en-"

// Specific locale
| where locale == "zh-cn"  // Chinese (China)
```

### Text Content Filtering

```kql
// Messages containing specific text
| where text contains "help"

// Questions only
| where text contains "?"

// Empty messages
| where isempty(text) or text == ""

// Non-empty messages
| where isnotempty(text)
```

## 📈 Aggregation Patterns

### Count & Distinct Count

```kql
| summarize
    TotalEvents = count(),
    UniqueUsers = dcount(user_Id),
    UniqueConversations = dcount(conversationId),
    UniqueChannels = dcount(cloud_RoleInstance)
    by bin(timestamp, 1d)
```

### Conditional Aggregations

```kql
| summarize
    TotalMessages = count(),
    QuestionMessages = countif(text contains "?"),
    LongMessages = countif(strlen(text) > 100),
    TeamsMessages = countif(cloud_RoleInstance == "msteams")
```

### Statistical Functions

```kql
| summarize
    AvgMessageLength = avg(strlen(text)),
    MinLength = min(strlen(text)),
    MaxLength = max(strlen(text)),
    StdDevLength = stdev(strlen(text))
```

### Group By Multiple Dimensions

```kql
| summarize
    MessageCount = count(),
    UniqueUsers = dcount(user_Id)
    by cloud_RoleInstance, locale, bin(timestamp, 1d)
| order by MessageCount desc
```

## 🎨 Visualization Commands

### Time Charts

```kql
| render timechart
    with (
        title="Message Volume Over Time",
        xtitle="Date",
        ytitle="Message Count"
    )
```

### Bar Charts

```kql
| render barchart
    with (
        title="Top Channels",
        xcolumn=cloud_RoleInstance,
        ycolumns=MessageCount
    )
```

### Pie Charts

```kql
| render piechart
    with (title="Channel Distribution")
```

### Column Charts

```kql
| render columnchart
    with (title="Hourly Distribution")
```

## 🔧 Common Transformations

### Extract from Custom Dimensions

```kql
| extend
    name = tostring(customDimensions['type']),
    cloud_RoleInstance = tostring(customDimensions['cloud_RoleInstance']),
    user_Id = tostring(customDimensions['user_Id']),
    fromName = tostring(customDimensions['fromName']),
    locale = tostring(customDimensions['locale']),
    text = tostring(customDimensions['message']),
    isDesignMode = tostring(customDimensions['designMode']),
    conversationId = tostring(customDimensions['conversationId'])
```

### Date/Time Manipulation

```kql
| extend
    HourOfDay = hourofday(timestamp),          // 0-23
    DayOfWeek = dayofweek(timestamp),          // 0=Sunday, 6=Saturday
    DayOfMonth = dayofmonth(timestamp),        // 1-31
    Date = bin(timestamp, 1d),                 // Daily bucket
    WeekStart = startofweek(timestamp),        // Start of week
    MonthStart = startofmonth(timestamp)       // Start of month
```

### String Operations

```kql
| extend
    TextLength = strlen(text),
    TextUpper = toupper(text),
    TextLower = tolower(text),
    WordCount = array_length(split(text, " ")),
    HasQuestion = text contains "?",
    HasGreeting = text contains "hello" or text contains "hi"
```

### Conditional Logic

```kql
| extend
    MessageType = case(
        text contains "?", "Question",
        text contains "thank", "Gratitude",
        text contains "help", "Help Request",
        "General"
    ),
    ConversationLength = case(
        MessageCount == 1, "Single",
        MessageCount <= 5, "Short",
        MessageCount <= 15, "Medium",
        "Long"
    )
```

## 🎯 Advanced Patterns

### Moving Average

```kql
let queryStartDate = ago(7d);
customEvents
| where timestamp > queryStartDate
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"
| summarize Count = count() by bin(timestamp, 1h)
| order by timestamp asc
| serialize
| extend MovingAvg3h = (Count + prev(Count, 1) + prev(Count, 2)) / 3
| render timechart
```

### Rate Calculation

```kql
| summarize Total = count(), Questions = countif(text contains "?")
| extend QuestionRate = round((todouble(Questions) / todouble(Total)) * 100, 2)
```

### Conversation Flow Analysis

```kql
let queryStartDate = ago(7d);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    name = tostring(customDimensions['type']),
    conversationId = tostring(customDimensions['conversationId'])
| where isDesignMode == "False" and isnotempty(name)
| order by conversationId asc, timestamp asc
| serialize
| extend
    PreviousType = prev(name, 1),
    PreviousConversation = prev(conversationId, 1)
| where conversationId == PreviousConversation and name != PreviousType
| summarize TransitionCount = count() by FromType = PreviousType, ToType = name
| order by TransitionCount desc
```

### User Engagement Score

```kql
let queryStartDate = ago(30d);
customEvents
| where timestamp > queryStartDate
| extend
    isDesignMode = tostring(customDimensions['designMode']),
    name = tostring(customDimensions['type']),
    user_Id = tostring(customDimensions['user_Id']),
    conversationId = tostring(customDimensions['conversationId'])
| where isDesignMode == "False" and name == "message"
| summarize
    MessageCount = count(),
    ConversationCount = dcount(conversationId),
    DaysActive = dcount(bin(timestamp, 1d))
    by user_Id
| extend EngagementScore = (MessageCount * 0.4) + (ConversationCount * 0.3) + (DaysActive * 0.3)
| extend EngagementLevel = case(
    EngagementScore >= 50, "High",
    EngagementScore >= 20, "Medium",
    "Low"
)
| order by EngagementScore desc
| take 50
```

## 💡 Pro Tips

1. **Always exclude test canvas**
   ```kql
   | extend isDesignMode = tostring(customDimensions['designMode'])
   | where isDesignMode == "False"
   ```

2. **Use `let` for reusable values**
   ```kql
   let queryStartDate = ago(7d);
   let queryEndDate = now();
   let targetChannel = "msteams";
   ```

3. **Project early to reduce data**
   ```kql
   customEvents
   | project timestamp, customDimensions, name
   | extend ...
   ```

4. **Filter by activity type for performance**
   ```kql
   | where name == "message"  // Reduces data by ~60%
   ```

5. **Use `take` for quick testing**
   ```kql
   | take 10  // Test query logic quickly
   ```

6. **Format for readability**
   ```kql
   | extend MessageLength = strlen(text)
   | project-rename ["Message Length"] = MessageLength
   ```

## 📊 Performance Benchmarks

### Response Time Targets (Dependencies)
| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Average | < 500ms | > 1000ms |
| P95 | < 1000ms | > 2000ms |
| P99 | < 2000ms | > 3000ms |

### Usage Targets
| Metric | Healthy Range |
|--------|---------------|
| Avg Messages/Conversation | 3-10 |
| Avg Conversation Duration | 2-15 minutes |
| User Retention (30d) | > 30% |

## 🚨 Alert Query Templates

### Simple Activity Threshold

```kql
let _startTime = ago(5m);
customEvents
| where timestamp > _startTime
| extend isDesignMode = tostring(customDimensions['designMode'])
| where isDesignMode == "False"
| summarize EventCount = count()
| where EventCount < 5  // Alert if fewer than 5 events in 5 min
```

### Exception Rate Alert

```kql
let _startTime = ago(1h);
let _threshold = 10;
exceptions
| where timestamp > _startTime
| where cloud_RoleName contains "copilot" or cloud_RoleName contains "bot"
| summarize ExceptionCount = count()
| where ExceptionCount > _threshold
```

---

**Last Updated**: 2026-03-09
**Version**: 2.0.0
**Optimized for**: Copilot Studio with Application Insights
