######
#
# Setup-Dev.ps1
#
# fdcastel@gmail.com
#
###


#
# Functions
#

function Update-SessionPath {
    # Updates current session PATH reading the most updated one from Registry
    $env:Path =  (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment').Path + ';' + `
                 (Get-ItemProperty 'HKCU:\Environment').Path
}

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

function Save-JsonAsUtf8WithoutBom {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        $Data
    )

    $json = $Data | ConvertTo-Json -Depth 100
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($FilePath, @($json), $utf8NoBom)
}

function Merge-RemoteJsonIntoFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$JsonUrl
    )

    $defaultSettings = Invoke-WebRequest -Uri $JsonUrl -UseBasicParsing |
        Select-Object -ExpandProperty Content |
        ConvertFrom-Json

    if (Test-Path $FilePath) {
        $existingSettings = Get-Content -Path $FilePath -Raw | ConvertFrom-Json
        $mergedSettings = Merge-JsonObject -Base $existingSettings -Overlay $defaultSettings
    }
    else {
        $mergedSettings = $defaultSettings
    }

    Save-JsonAsUtf8WithoutBom -FilePath $FilePath -Data $mergedSettings
}



#
# Main
#

$ErrorActionPreference = 'Stop'             # Stop on any error
$ProgressPreference = 'SilentlyContinue'    # Disable progress bar.

# Install Powershell Core
choco upgrade powershell-core -y

# Install Beyond Compare
choco upgrade beyondcompare -y

# Install Git
choco upgrade git -y
Update-SessionPath

# Remove Git Windows Explorer context menu entries
Remove-Item -Path "HKLM:\SOFTWARE\Classes\Directory\background\shell\git_gui" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Classes\Directory\background\shell\git_shell" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_gui" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_shell" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\LibraryFolder\background\shell\git_gui" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\LibraryFolder\background\shell\git_shell" -Force -Recurse -ErrorAction SilentlyContinue

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

# Download Claude settings and merge them with the current user's settings
$claudeConfigDir = Join-Path -Path $env:USERPROFILE -ChildPath '.claude'
New-Item -Path $claudeConfigDir -ItemType Directory -Force | Out-Null
$claudeSettingsFile = Join-Path -Path $claudeConfigDir -ChildPath 'settings.json'
Merge-RemoteJsonIntoFile -FilePath $claudeSettingsFile -JsonUrl 'https://raw.githubusercontent.com/fdcastel/setup/master/claude/default-settings.json'

# Download VS Code default settings and merge with the current user's settings
$vsCodeUserDir = Join-Path -Path $env:APPDATA -ChildPath 'Code\User'
New-Item -Path $vsCodeUserDir -ItemType Directory -Force | Out-Null
$vsCodeSettingsFile = Join-Path -Path $vsCodeUserDir -ChildPath 'settings.json'
Merge-RemoteJsonIntoFile -FilePath $vsCodeSettingsFile -JsonUrl 'https://raw.githubusercontent.com/fdcastel/setup/master/vscode/default-settings.json'
