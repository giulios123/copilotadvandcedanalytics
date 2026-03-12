# Dashboard Preview to PNG - Capture Instructions

## Overview
Three HTML dashboard preview files have been created to visualize how your Azure Data Explorer dashboards will appear once implemented.

## Files Created
1. **Preview-01-Overview-Dashboard.html** - Overview metrics and KPIs
2. **Preview-02-Performance-Dashboard.html** - Performance and dependency monitoring
3. **Preview-03-Conversation-Analytics-Dashboard.html** - Conversation patterns and user engagement

## Methods to Capture as PNG

### Option 1: Browser Screenshot (Easiest)

#### Chrome/Edge:
1. Open the HTML file in browser (double-click the file)
2. Press `F11` to enter fullscreen mode
3. Press `F12` to open DevTools
4. Press `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (Mac)
5. Type "Capture full size screenshot"
6. Select the option and the PNG will be saved to Downloads

#### Firefox:
1. Open the HTML file in browser
2. Press `Ctrl+Shift+S` (Windows) or `Cmd+Shift+S` (Mac)
3. Click "Save full page"
4. Choose location and save

### Option 2: Using PowerShell with Microsoft Edge

Run this PowerShell script from the `Dashboards` folder:

```powershell
# Capture Dashboard Screenshots
$dashboards = @(
    "Preview-01-Overview-Dashboard.html",
    "Preview-02-Performance-Dashboard.html",
    "Preview-03-Conversation-Analytics-Dashboard.html"
)

foreach ($dashboard in $dashboards) {
    $htmlPath = Join-Path $PSScriptRoot $dashboard
    $pngPath = $htmlPath -replace '\.html$', '.png'

    # Open in Edge and capture
    Start-Process msedge.exe -ArgumentList "--headless --screenshot=`"$pngPath`" --window-size=1920,1080 --default-background-color=0 `"$htmlPath`""
    Start-Sleep -Seconds 5

    Write-Host "Captured: $pngPath"
}

Write-Host "`nAll dashboards captured successfully!"
```

### Option 3: Online Screenshot Tools
1. Upload HTML files to online tools like:
   - https://www.web-capture.net/
   - https://htmlcsstoimage.com/
   - https://screenshot.guru/

### Option 4: Python with Selenium (Advanced)

```python
from selenium import webdriver
from selenium.webdriver.edge.service import Service
import time
import os

dashboards = [
    "Preview-01-Overview-Dashboard.html",
    "Preview-02-Performance-Dashboard.html",
    "Preview-03-Conversation-Analytics-Dashboard.html"
]

options = webdriver.EdgeOptions()
options.add_argument('--headless')
options.add_argument('--window-size=1920,1080')

driver = webdriver.Edge(options=options)

for dashboard in dashboards:
    file_path = f"file:///{os.path.abspath(dashboard)}"
    driver.get(file_path)
    time.sleep(2)

    png_name = dashboard.replace('.html', '.png')
    driver.save_screenshot(png_name)
    print(f"Captured: {png_name}")

driver.quit()
print("All dashboards captured!")
```

## Recommended Resolution
- **Width**: 1920px
- **Height**: 1080px or auto (for full page capture)
- **Format**: PNG with transparency support

## For Presentations
1. Capture all three dashboards as PNG
2. Import into PowerPoint/Google Slides
3. Add titles and annotations as needed
4. Use the dashboards to show:
   - **Overview**: High-level business metrics
   - **Performance**: Technical health and SLAs
   - **Analytics**: User behavior and engagement insights

## Customization
To customize the dashboards before capture:
1. Open the HTML files in a text editor
2. Modify the sample data in the HTML
3. Adjust colors, fonts, or layout as needed
4. Save and capture again

## Notes
- The HTML files are self-contained (no external dependencies)
- They work in all modern browsers
- Sample data is included for visualization purposes
- The actual Azure Data Explorer dashboards will use live KQL queries
