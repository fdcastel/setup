######
#
# Setup-Python.ps1
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

# Install Python 
choco install python -y
Reload-Path

# Update Pip
python.exe -m pip install --upgrade pip

# Install uv
choco install uv -y
