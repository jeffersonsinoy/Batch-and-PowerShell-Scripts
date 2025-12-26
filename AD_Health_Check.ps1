<# 
    DC Health Check Utility
    Created by: Iam Root
#>

$Global:ReportFolder = "$PSScriptRoot\Reports"
if (!(Test-Path $ReportFolder)) { New-Item -Path $ReportFolder -ItemType Directory | Out-Null }

function Export-ToHtml ($Title, $Content) {
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $file = "$ReportFolder\$Title-$timestamp.html"

    $htmlHeader = @"
<html>
<head>
<title>$Title</title>
<style>
body { font-family: Segoe UI, Arial; margin: 20px; }
h2 { color: #007ACC; }
table { border-collapse: collapse; width: 100%; }
td, th { border: 1px solid #ccc; padding: 6px; }
th { background: #007ACC; color: white; }
</style>
</head>
<body>
<h2>$Title – $timestamp</h2>
<pre>
"@

    $htmlFooter = @"
</pre>
</body>
</html>
"@

    $htmlContent = $htmlHeader + ($Content | Out-String) + $htmlFooter
    $htmlContent | Out-File -Encoding UTF8 $file

    Write-Host "`nHTML report generated: $file" -ForegroundColor Cyan
    Start-Process $file
}

function Show-SystemInfo {
    Clear-Host
    Write-Host "===== SYSTEM & AD SERVICES CHECK =====" -ForegroundColor Cyan

    $hostname = $env:COMPUTERNAME
    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1" } |
           Select-Object -First 1 -ExpandProperty IPAddress)
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptimeFormatted = "{0} days {1} hours {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

    Write-Host "`nHostname     : $hostname"
    Write-Host "IP Address   : $ip"
    Write-Host "OS Uptime    : $uptimeFormatted`n"

    Get-Service Netlogon, DNS, KDC, DFSR, NTDS, IsmServ |
        Select-Object Name, Status, StartType |
        Format-Table -AutoSize

    Write-Host "`nPress ENTER to return to menu..."
    Read-Host | Out-Null
}

function ReplicationCheck {
    Clear-Host
    Write-Host "===== CUSTOM DC REPLICATION CHECK =====" -ForegroundColor Yellow

    $SourceDC = Read-Host "Enter SOURCE DC Hostname"
    $DestDC   = Read-Host "Enter DESTINATION DC Hostname"

    Write-Host "`nRunning Replication from $SourceDC --> $DestDC..." -ForegroundColor Yellow
    $syncResult = repadmin /syncall $SourceDC $DestDC /AdeP
    $showRepl   = repadmin /showrepl $SourceDC

    # Export to HTML
    $htmlData = "Replication Sync Output:`n$syncResult `n`nReplication Detail:`n$showRepl"
    Export-ToHtml "Replication-$SourceDC-To-$DestDC" $htmlData

    Write-Host "`nPress ENTER to return to menu..."
    Read-Host | Out-Null
}

function Check-OverallReplication {
    Clear-Host
    Write-Host "===== OVERALL AD REPLICATION SUMMARY =====" -ForegroundColor Green

    $summary = repadmin /replsummary

    Export-ToHtml "AD-Replication-Summary" $summary

    Write-Host "`nPress ENTER to return to menu..."
    Read-Host | Out-Null
}

# ===== MAIN MENU =====
do {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "      Active Directory Health Menu        " -ForegroundColor Cyan
    Write-Host "========================================"
    Write-Host "1. Check Replication (Custom DC Input + HTML Export)"
    Write-Host "2. Check Overall Replication Summary (HTML Export)"
    Write-Host "3. Check AD Services & System Info"
    Write-Host "0. Exit"
    Write-Host "========================================"
    $choice = Read-Host "Enter Selection"

    switch ($choice) {
        "1" { ReplicationCheck }
        "2" { Check-OverallReplication }
        "3" { Show-SystemInfo }
        "0" { break }
        Default { Write-Host "Invalid Selection" -ForegroundColor Red; Start-Sleep 1 }
    }
} while ($true)
