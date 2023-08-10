######
#
# Remove-OneDrive.ps1
#
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-OneDrive.ps1
#
###

[CmdletBinding()]
Param()

Get-Process 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process
& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall

Remove-Item -Recurse -Force "$env:localappdata\Microsoft\OneDrive" -ErrorAction SilentlyContinue 
Remove-Item -Recurse -Force "$env:programdata\Microsoft OneDrive" -ErrorAction SilentlyContinue 

# Remove new users hook (Matthew Israelsson)
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

# Remove Start Menu link
Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

# Remove OneDrive user folder (if empty)
Remove-Item "$env:userprofile\OneDrive" -Force -ErrorAction SilentlyContinue