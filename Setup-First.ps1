######
#
# Setup-First.ps1
#
# fdcastel@gmail.com
#
###

[CmdletBinding()]
Param()

[string[]]$innerArguments = $MyInvocation.BoundParameters.GetEnumerator() | 
    ForEach-Object {
        if ($_.Value -is [Switch]) {
            "-$($_.Key)"
        } else {
            "-$($_.Key)", "$($_.Value)"
        }
    }
$innerArguments += $MyInvocation.UnboundArguments

[string[]]$outerArguments = @('-NoProfile', '-File', "`"$($MyInvocation.MyCommand.Path)`"")
$outerArguments += $innerArguments

function Requires-Elevation {
    # Restart script with administrative privileges, if needed
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)) {
        Write-Verbose 'Running without administrative privileges. Starting new (elevated) PowerShell session...'
        Write-Verbose "  Arguments: $($outerArguments)"
        Start-Process -FilePath PowerShell.exe -Verb Runas -WorkingDirectory $pwd -ArgumentList $outerArguments
        Exit
    }
    Write-Verbose 'Running with administrative privileges.'
    Write-Verbose "  Arguments: $($innerArguments)"
}

# Stop on any error
$ErrorActionPreference = 'Stop'

# Elevate (if needed)
Requires-Elevation

# Set execution policy
Set-ExecutionPolicy RemoteSigned -Force

# Allow Remote Desktop connections
try {
    (Get-WmiObject -Class 'Win32_TerminalServiceSetting' -Namespace root\cimv2\terminalservices).SetAllowTsConnections(1) | Out-Null
} 
catch {
    # SetAllowTsConnections can fail when running in a RDP session
    Write-Warning "Cannot enable Remote Desktop connections (running in a remote session?)."
}

# Enable Remote Desktop firewall rule
netsh advfirewall Firewall set rule group="Remote Desktop" new enable=yes | Out-Null

# Enable ICMP Echo Request (Ping) firewall rule (for IPv4 and IPv6)
Get-NetFirewallRule -Name 'FPS-ICMP*' | Set-NetFirewallRule -Enabled:True

# Console settings: Layout and buffer options, Consolas font, foreground color to green (ignored by Powershell)
('HKCU:\Console', 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe', 'HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe') | ForEach-Object {
    if (-not (Test-Path $_)) {
    	New-Item -Path $_ -Force | Out-Null
    }
    Set-ItemProperty -Path $_ -Name 'CursorSize' -Value 0x00000019
    Set-ItemProperty -Path $_ -Name 'FaceName' -Value 'Consolas'
    Set-ItemProperty -Path $_ -Name 'FontSize' -Value 0x000e0000
    Set-ItemProperty -Path $_ -Name 'HistoryBufferSize' -Value 0x000003e7
    Set-ItemProperty -Path $_ -Name 'QuickEdit' -Value 0x00000001
    Set-ItemProperty -Path $_ -Name 'ScreenBufferSize' -Value 0x03e70078
    Set-ItemProperty -Path $_ -Name 'ScreenColors' -Value 0x0000000a
    Set-ItemProperty -Path $_ -Name 'WindowSize' -Value 0x003c0078
}

# Autorun for cmd (set console foreground color to yellow if is admin)
$HKCUCommandProcessor = 'HKCU:\Software\Microsoft\Command Processor'
mkdir $HKCUCommandProcessor -Force | Out-Null    # Windows 1803 clean install doesn't have this key
Set-ItemProperty -path $HKCUCommandProcessor -Name 'AutoRun' -Value 'OPENFILES > NUL 2>&1 & IF NOT ERRORLEVEL 1 COLOR E'

# Autorun for PowerShell (set console foreground color to yellow if is admin)
New-Item $profile -ItemType File -Force | Out-Null
Add-Content $profile "if ( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator') ) { (Get-Host).UI.RawUI.ForegroundColor = 'Yellow' } else { (Get-Host).UI.RawUI.ForegroundColor = 'Green' }"

# Explorer settings: Show hidden files/folders, Don't hide extensions, Taskbar: combine when is full
$HKCUExplorerAdvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'Hidden' -Value 1
Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'HideFileExt' -Value 0
Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'TaskbarGlomLevel' -Value 1

# Do not hide system tray icons
$HKCUTrayNotify = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify'
Set-ItemProperty -path $HKCUTrayNotify -Name 'SystemTrayChevronVisibility' -Value 0

$WindowsVersion = [System.Environment]::OSVersion.Version.Major * 10 + [System.Environment]::OSVersion.Version.Minor
if ($WindowsVersion -ge 100) {
    # Windows 10: Open Explorer to "This PC" (instead of "Quick Access")
    Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'LaunchTo' -Value 1

    if ([System.Environment]::OSVersion.Version.Build -ge 22000) {
        # Windows 11: Set Windows Terminal as default
        #   https://support.microsoft.com/en-us/windows/command-prompt-and-windows-powershell-for-windows-11-6453ce98-da91-476f-8651-5c14d5777c20
        $HKCUStartup = 'HKCU:\Console\%%Startup'
        New-Item $HKCUStartup -Force | Out-Null
        Set-ItemProperty -Path $HKCUStartup -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}'
        Set-ItemProperty -Path $HKCUStartup -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}'

        # Windows 11: Remove Chat, Widgets and Task View from taskbar
        $HKCUExplorerAdvanced = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'TaskbarMn' -Value 0
        Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'TaskbarDa' -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'ShowTaskViewButton' -Value 0

        # Windows 11: Set taskbar alignment to "Left"
        Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'TaskbarAl' -Value 0
        
        # Windows 11: Hide search box in taskbar
        $HKCUExplorerAdvanced = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
        Set-ItemProperty -Path $HKCUExplorerAdvanced -Name 'SearchboxTaskbarMode' -Value 0        
    }
}

# Set the only Keyboard Layout to pt-BR/ABNT2
$langList = New-WinUserLanguageList pt-BR
$langList[0].InputMethodTips.Clear()
$langList[0].InputMethodTips.Add('0416:00010416')
Set-WinUserLanguageList $langList -Force

# Disable hotkeys for switching input layout/language
$HKCUInputMethodHotKeys104 = 'HKCU:\Control Panel\Input Method\Hot Keys\00000104'
Remove-Item -Path $HKCUInputMethodHotKeys104 -Recurse -ErrorAction 'SilentlyContinue'
$HKCUKeyboardLayoutToggle = 'HKCU:\Keyboard Layout\Toggle\'
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Language Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Layout Hotkey' -Value 3
Set-ItemProperty -Path $HKCUKeyboardLayoutToggle -Name 'Hotkey' -Value 3

# Enable desktop background on start (Windows 8.1 only)
$HKCUAccent = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
New-Item $HKCUAccent -Force | Out-Null
Set-ItemProperty -Path $HKCUAccent -Name 'MotionAccentId_v1.00' -Value 219 -Force



# Disable IPv6 Transition Technologies
netsh int teredo set state disabled
netsh int 6to4 set state disabled
netsh int isatap set state disabled



# Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
refreshenv



# Install 7Zip, Chrome and AnyDesk (if not in a server nor vm)
$osName = (Get-WmiObject -class Win32_OperatingSystem).Caption 
$boardManufacturer = (Get-WmiObject Win32_BaseBoard).Manufacturer

$isWindowsServer = $osName -like '*Server*'
$isVirtualMachine = $boardManufacturer -like '*Microsoft*'

if ( (-not $isWindowsServer) -and (-not $isVirtualMachine) ) {
    choco install 7zip GoogleChrome AnyDesk -y

    Set-Location ($PSScriptRoot)
    
    $postInstallScript = '.\Setup-First-Post-Install.ps1'
    if (Test-Path $postInstallScript) {
        & $postInstallScript
    }
}
