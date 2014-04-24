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
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Verbose 'Running without administrative privileges. Starting new (elevated) PowerShell session...'
        Write-Verbose "  Arguments: $($outerArguments)"
        Start-Process -FilePath PowerShell.exe -Verb Runas -WorkingDirectory $pwd -ArgumentList $outerArguments
        Exit
    }
    Write-Verbose 'Running with administrative privileges.'
    Write-Verbose "  Arguments: $($innerArguments)"
}

function Reload-Path {
    # Updates current session PATH reading the most updated one from Registry
    $env:Path =  (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path + ';' + `
                 (Get-ItemProperty 'HKCU:\Environment').Path
}

# Stop on any error
$ErrorActionPreference = 'Stop'

# Elevate (if needed)
Requires-Elevation

# Set execution policy
Set-ExecutionPolicy RemoteSigned -Force

# Allow Remote Desktop connections, Allow low-security connections, Enable firewall rule
(Get-WmiObject -Class 'Win32_TerminalServiceSetting' -Namespace root\cimv2\terminalservices).SetAllowTsConnections(1) | out-null
(Get-WmiObject -class 'Win32_TSGeneralSetting' -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | out-null
netsh advfirewall Firewall set rule group="Remote Desktop" new enable=yes | out-null

# Console settings: Layout and buffer options, Consolas font, foreground color to green (ignored by PowerShell)
#   PowerShell: Not works in Windows 7
('HKCU:\Console', 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe', 'HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe') | ForEach-Object {
    if (-not (Test-Path $_)) {
    	New-Item -Path $_ -Force
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
Set-ItemProperty -path $HKCUCommandProcessor -name 'AutoRun' -value 'OPENFILES > NUL 2>&1 & IF NOT ERRORLEVEL 1 COLOR E'

# Autorun for PowerShell (set console foreground color to yellow if is admin)
New-Item $profile -ItemType File -Force | Out-Null
Add-Content $profile "if ( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator') ) { (Get-Host).UI.RawUI.ForegroundColor = 'Yellow' }"

# Explorer settings: Show hidden files/folders, Don't hide extensions, Taskbar: combine when is full
$HKCUExplorerAdvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -path $HKCUExplorerAdvanced -name 'Hidden' -value 1
Set-ItemProperty -path $HKCUExplorerAdvanced -name 'HideFileExt' -value 0
Set-ItemProperty -path $HKCUExplorerAdvanced -name 'TaskbarGlomLevel' -value 1

# Determine Windows version
$WindowsVersion = [System.Environment]::OSVersion.Version.Major * 10 + [System.Environment]::OSVersion.Version.Minor

if ($WindowsVersion -ge 62)
{
    # Windows 8 or higher: Set the only Keyboard Layout to pt-BR/ABNT2
    $langList = New-WinUserLanguageList pt-BR
    $langList[0].InputMethodTips.Clear()
    $langList[0].InputMethodTips.Add('0416:00010416')
    Set-WinUserLanguageList $langList -Force

	if ($WindowsVersion -ge 63) {
	    # Windows 8.1 only: Enable desktop background on start

        $HKCUAccent = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
        New-Item $HKCUAccent -Force
	    Set-ItemProperty -Path $HKCUAccent -Name 'MotionAccentId_v1.00' -Value 219 -Force
	}
} else {
    # Windows 7 or lower: Set the only Keyboard Layout to pt-BR/ABNT2
    $HKCUKeyboardPreload = 'HKCU:\Keyboard Layout\Preload'
    $HKCUKeyboardSubstitutes = 'HKCU:\Keyboard Layout\Substitutes'
    Remove-ItemProperty $HKCUKeyboardPreload -Name (Get-Item $HKCUKeyboardPreload).Property    # Remove all (dumb?) 
    Remove-ItemProperty $HKCUKeyboardSubstitutes -Name (Get-Item $HKCUKeyboardSubstitutes).Property
    Set-ItemProperty -path $HKCUKeyboardPreload -name '1' -value '00000416'
    Set-ItemProperty -path $HKCUKeyboardSubstitutes -name '00000416' -value '00010416'
}

# Install Chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
Reload-Path