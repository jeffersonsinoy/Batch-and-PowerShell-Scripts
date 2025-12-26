# Get hostname
$hostname = $env:COMPUTERNAME
 
# Get IP address (IPv4, non-loopback)
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
       Select-Object -First 1 -ExpandProperty IPAddress)
 
# Get OS uptime
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptimeFormatted = "{0} days {1} hours {2} minutes {3} seconds" -f $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds
 
# Display system info
Write-Host "Hostname     : $hostname"
Write-Host "IP Address   : $ip"
Write-Host "OS Uptime    : $uptimeFormatted"
Write-Host ""
 
# Display service status
Get-Service Netlogon, DNS, KDC, DFSR, NTDS, IsmServ | Format-Table Name, Status