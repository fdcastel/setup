######
#
# Remove-Edge.ps1
#
# Source: https://github.com/LeDragoX/Win-Debloat-Tools/blob/main/src/scripts/Remove-MSEdge.ps1
#
###

[CmdletBinding()]
Param()

Get-Process 'msedge' -ErrorAction SilentlyContinue | Stop-Process

If ( (Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge\Application") -or 
     (Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeWebView\Application") ) {
    ForEach ($FullName in (Get-ChildItem -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge*\Application\*\Installer\setup.exe").FullName) {
        Start-Process -FilePath $FullName -ArgumentList "--uninstall", "--msedgewebview", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
    }
}

If (Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeCore") {
    ForEach ($FullName in (Get-ChildItem -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeCore\*\Installer\setup.exe").FullName) {
        Start-Process -FilePath $FullName -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
    }
}

Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Microsoft.MicrosoftEdge*" | Remove-AppxProvisionedPackage -Online -AllUsers

# Remove Start Menu link
Remove-Item -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"

# Cleanup
Get-Process 'widgets' -ErrorAction SilentlyContinue | Stop-Process
Remove-Item -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge*" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge*_*" -Recurse -Force

# Prevents Edge from reinstalling
$HKLMEdgeUpdate = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
New-Item -Path $HKLMEdgeUpdate -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path $HKLMEdgeUpdate -Name "DoNotUpdateToEdgeWithChromium" -Value 1
