######
#
# Setup-Dev.ps1
#
# fdcastel@gmail.com
#
###

function Reload-Path {
    # Updates current session PATH reading the most updated one from Registry
    $env:Path =  (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path + ';' + `
                 (Get-ItemProperty 'HKCU:\Environment').Path
}

# Stop on any error
$ErrorActionPreference = 'Stop'

# Install Beyond Compare
choco install beyondcompare -y

# Install Git
choco install git -y
Reload-Path

# Remove Git Windows Explorer context menu entries
Remove-Item -Path "HKLM:\SOFTWARE\Classes\Directory\background\shell\git_gui" -Force -Recurse
Remove-Item -Path "HKLM:\SOFTWARE\Classes\Directory\background\shell\git_shell" -Force -Recurse
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_gui" -Force -Recurse
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_shell" -Force -Recurse
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\LibraryFolder\background\shell\git_gui" -Force -Recurse
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\LibraryFolder\background\shell\git_shell" -Force -Recurse

# Configure Git
git config --global user.email fdcastel@gmail.com
git config --global user.name F.D.Castel

# Install TortoiseGit
choco install tortoisegit -y

# Configure TortoiseGit menus
#   - Main: Clone, Pull, Push, Commit, Show log, Check for modifications, Switch/Checkout, Create Branch
#   - Shift pressed: Clone, Create repository here
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name 'ContextMenuEntries' -PropertyType 'DWORD' -Value 0x00120c84 | Out-Null
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name 'ContextMenuEntriesHigh' -PropertyType 'DWORD' -Value 0x00000038 | Out-Null
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name 'ContextMenuExtEntriesLow' -PropertyType 'DWORD' -Value 0x40000400 | Out-Null
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name 'ContextMenuExtEntriesHigh' -PropertyType 'DWORD' -Value 0x00012020 | Out-Null

# Configure TortoiseGit / Beyond Compare integration
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name Diff  -PropertyType String -Value '"C:\Program Files\Beyond Compare 5\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name Merge -PropertyType String -Value '"C:\Program Files\Beyond Compare 5\BComp.exe" %mine %theirs %base %merged /title1=%yname /title2=%tname /title3=%bname /title4=%mname' | Out-Null

# Install Visual Studio Code
choco install vscode -y
