######
#
# Setup-Devel.ps1
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

cinst beyondcompare 

cinst git
Reload-Path
git config --global user.email fdcastel@gmail.com
git config --global user.name F.D.Castel

cinst TortoiseGit 
# Configure Beyond Compare integration
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name Diff  -PropertyType String -Value '"C:\Program Files (x86)\Beyond Compare 3\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseGit -Force -Name Merge -PropertyType String -Value '"C:\Program Files (x86)\Beyond Compare 3\BComp.exe" %mine %theirs %base %merged /title1=%yname /title2=%tname /title3=%bname /title4=%mname' | Out-Null

cinst sliksvn 
# Set Global Ignore Pattern:
New-Item HKCU:\Software\Tigris.org\Subversion\Config\miscellany -Force | Out-Null
New-ItemProperty HKCU:\Software\Tigris.org\Subversion\Config\miscellany -Force -Name global-ignores -PropertyType String -Value '*.exe *.bpl *.dcp *.dcu *.~* *.map *.rsm *.log *.$$$ *.dsk *.dti *.ddp *.bdsproj.local *.bdsgroup.local *.user *.identcache __history *.pdb *.Cache *.local' | Out-Null

cinst tortoisesvn 
# Configure Beyond Compare integration
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name DiffProps -PropertyType String -Value '"C:\Program Files (x86)\Beyond Compare 3\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name Diff      -PropertyType String -Value '"C:\Program Files (x86)\Beyond Compare 3\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name Merge     -PropertyType String -Value '"C:\Program Files (x86)\Beyond Compare 3\BComp.exe" %mine %theirs %base %merged /title1=%yname /title2=%tname /title3=%bname /title4=%mname' | Out-Null
