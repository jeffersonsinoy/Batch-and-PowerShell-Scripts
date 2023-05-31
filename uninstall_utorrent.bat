powershell -c "Stop-Process -Name utorrent -force"
%userprofile%\appdata\Roaming\utorrent\uTorrent.exe /uninstall /s
powershell -c (Remove-Item -Path "C:\Users\*\AppData\Roaming\utorrent" -Force -Recurse)
reg delete HKEY_CURRENT_USER\software\BitTorrent /f
reg delete HKEY_CURRENT_USER\software\BitTorrent\uTorrent /f
reg delete HKEY_CLASSES_ROOT\.torrent /f
reg delete HKEY_CLASSES_ROOT\Applications\uTorrent.exe /f
reg delete HKEY_CLASSES_ROOT\uTorrent /f
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v uTorrent /f