######
#
# Setup-Svn.ps1
#
# fdcastel@gmail.com
#
###

# Stop on any error
$ErrorActionPreference = 'Stop'

choco install beyondcompare -y

choco install svn -y
# Set Global Ignore Pattern:
New-Item HKCU:\Software\Tigris.org\Subversion\Config\miscellany -Force | Out-Null
New-ItemProperty HKCU:\Software\Tigris.org\Subversion\Config\miscellany -Force -Name global-ignores -PropertyType String -Value '*.exe *.bpl *.dcp *.dcu *.~* *.map *.rsm *.log *.$$$ *.dsk *.dti *.ddp *.bdsproj.local *.bdsgroup.local *.user *.identcache __history *.pdb *.Cache *.local' | Out-Null

choco install tortoisesvn -y
# Configure Beyond Compare integration
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name DiffProps -PropertyType String -Value '"C:\Program Files\Beyond Compare 4\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name Diff      -PropertyType String -Value '"C:\Program Files\Beyond Compare 4\BComp.exe" %base %mine /title1=%bname /title2=%yname /leftreadonly' | Out-Null
New-ItemProperty HKCU:\Software\TortoiseSVN -Force -Name Merge     -PropertyType String -Value '"C:\Program Files\Beyond Compare 4\BComp.exe" %mine %theirs %base %merged /title1=%yname /title2=%tname /title3=%bname /title4=%mname' | Out-Null
