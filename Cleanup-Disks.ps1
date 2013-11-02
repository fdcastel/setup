# Execute all disk cleanup tasks for all disks
#   Must run with elevated privileges

# Add StateFlags1337 for each area
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" | ForEach-Object {
    Get-ItemProperty $_.PSPath -Name StateFlags | ForEach-Object {
        Set-ItemProperty $_.PSPath -Name StateFlags1337 -Value 2 -Type DWord -Force | Out-Null
    }
}

# Run Disk Cleanup
CLEANMGR.EXE /SAGERUN:1337