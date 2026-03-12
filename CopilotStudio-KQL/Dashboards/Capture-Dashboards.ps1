# ===============================================================================
# Dashboard Screenshot Capture Script
# ===============================================================================
# Description: Captures all dashboard HTML previews as PNG images using Edge
# Requirements: Microsoft Edge browser
# Output: PNG files in the same directory
# ===============================================================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Dashboard Screenshot Capture Tool" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Dashboard files to capture
$Dashboards = @(
    @{
        File = "Preview-01-Overview-Dashboard.html"
        Name = "Overview Dashboard"
        Output = "Dashboard-01-Overview.png"
    },
    @{
        File = "Preview-02-Performance-Dashboard.html"
        Name = "Performance Dashboard"
        Output = "Dashboard-02-Performance.png"
    },
    @{
        File = "Preview-03-Conversation-Analytics-Dashboard.html"
        Name = "Conversation Analytics Dashboard"
        Output = "Dashboard-03-Conversation-Analytics.png"
    }
)

# Check if Edge is available
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $EdgePath)) {
    $EdgePath = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
}

if (-not (Test-Path $EdgePath)) {
    Write-Host "ERROR: Microsoft Edge not found!" -ForegroundColor Red
    Write-Host "Please install Microsoft Edge or use manual capture method." -ForegroundColor Yellow
    Write-Host "See CAPTURE-INSTRUCTIONS.md for alternative methods." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found Microsoft Edge: $EdgePath" -ForegroundColor Green
Write-Host ""

$SuccessCount = 0
$FailCount = 0

# Capture each dashboard
foreach ($Dashboard in $Dashboards) {
    $HtmlPath = Join-Path $ScriptDir $Dashboard.File
    $PngPath = Join-Path $ScriptDir $Dashboard.Output

    if (-not (Test-Path $HtmlPath)) {
        Write-Host "WARNING: $($Dashboard.File) not found, skipping..." -ForegroundColor Yellow
        $FailCount++
        continue
    }

    Write-Host "Capturing: $($Dashboard.Name)..." -ForegroundColor Cyan

    try {
        # Use Edge in headless mode to capture screenshot
        $Arguments = @(
            "--headless"
            "--disable-gpu"
            "--screenshot=`"$PngPath`""
            "--window-size=1920,1200"
            "--default-background-color=0"
            "--hide-scrollbars"
            "`"$HtmlPath`""
        )

        $Process = Start-Process -FilePath $EdgePath -ArgumentList $Arguments -PassThru -NoNewWindow
        $Process.WaitForExit(30000)  # Wait max 30 seconds

        if (Test-Path $PngPath) {
            $FileSize = (Get-Item $PngPath).Length / 1KB
            Write-Host "  ✓ Saved: $($Dashboard.Output) ($([Math]::Round($FileSize, 2)) KB)" -ForegroundColor Green
            $SuccessCount++
        } else {
            Write-Host "  ✗ Failed to create screenshot" -ForegroundColor Red
            $FailCount++
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        $FailCount++
    }

    # Small delay between captures
    Start-Sleep -Milliseconds 500
}

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Capture Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($SuccessCount -gt 0) {
    Write-Host "PNG files saved in: $ScriptDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use these PNG files in your presentations!" -ForegroundColor Cyan
}

# Option to open the folder
$OpenFolder = Read-Host "Would you like to open the output folder? (Y/N)"
if ($OpenFolder -eq "Y" -or $OpenFolder -eq "y") {
    Start-Process explorer.exe -ArgumentList $ScriptDir
}
