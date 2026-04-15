######
#
# Setup-Dev.ps1
#
# fdcastel@gmail.com
#
###

function Update-SessionPath {
    # Updates current session PATH reading the most updated one from Registry
    $env:Path =  (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path + ';' + `
                 (Get-ItemProperty 'HKCU:\Environment').Path
}

# Stop on any error
$ErrorActionPreference = 'Stop'

# Install Powershell Core
choco upgrade powershell-core -y

# Install Beyond Compare
choco upgrade beyondcompare -y

# Install Git
choco upgrade git -y
Update-SessionPath

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
choco upgrade tortoisegit -y

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

# Install Visual Studio Code, GitHub CLI and Claude Code
choco upgrade vscode gh claude-code -y



#
# Download Claude settings and merge them with the current user's settings
#
$claudeConfigDir = Join-Path -Path $env:USERPROFILE -ChildPath '.claude'
New-Item -Path $claudeConfigDir -ItemType Directory -Force | Out-Null

$claudeSettingsFile = Join-Path -Path $claudeConfigDir -ChildPath 'settings.json'
$ProgressPreference = 'SilentlyContinue'    # Disable progress bar.

function Merge-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Base,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Overlay
    )

    foreach ($overlayProperty in $Overlay.PSObject.Properties) {
        $propertyName = $overlayProperty.Name
        $overlayValue = $overlayProperty.Value
        $baseProperty = $Base.PSObject.Properties[$propertyName]

        if ($null -eq $baseProperty) {
            $Base | Add-Member -MemberType NoteProperty -Name $propertyName -Value $overlayValue
            continue
        }

        $baseValue = $baseProperty.Value
        if ( ($baseValue -is [pscustomobject]) -and ($overlayValue -is [pscustomobject]) ) {
            Merge-JsonObject -Base $baseValue -Overlay $overlayValue | Out-Null
        }
    }

    return $Base
}

$defaultSettings = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/fdcastel/setup/master/claude/default-settings.json' -UseBasicParsing |
    Select-Object -ExpandProperty Content |
    ConvertFrom-Json

if (Test-Path $claudeSettingsFile) {
    $existingSettings = Get-Content -Path $claudeSettingsFile -Raw | ConvertFrom-Json
    $mergedSettings = Merge-JsonObject -Base $existingSettings -Overlay $defaultSettings
}
else {
    $mergedSettings = $defaultSettings
}

$mergedSettingsJson = $mergedSettings | ConvertTo-Json -Depth 100
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)    # Write JSON without BOM
[System.IO.File]::WriteAllLines($claudeSettingsFile, @($mergedSettingsJson), $utf8NoBom)
