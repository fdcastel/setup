######
#
# Setup-Python.ps1
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

# Install Python 
choco upgrade python uv -y
Update-SessionPath

# Update Pip
python.exe -m pip install --upgrade pip
