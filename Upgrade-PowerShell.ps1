#requires -RunAsAdministrator

[CmdletBinding()]
Param()

$ErrorActionPreference = 'Stop'

function Get-LatestPowerShellRelease {
    $uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    $headers = @{ 'User-Agent' = 'PowerShell' }
    Write-Verbose "Querying latest PowerShell release from GitHub: $uri"
    Invoke-RestMethod -Uri $uri -Headers $headers -UseBasicParsing
}

function Get-MsiAssetForRelease {
    param(
        [Parameter(Mandatory = $true)]
        $Release,

        [Parameter(Mandatory = $true)]
        [ValidateSet('x64','x86')]
        [string]$Architecture
    )

    $pattern = "win-$Architecture\.msi$"
    $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1
}

function Download-Asset {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Write-Host "Downloading PowerShell installer to: $Destination"

    # Suppress slow progress bar updates for PowerShell 5 and earlier
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $ProgressPreference = 'SilentlyContinue'
    }

    Invoke-WebRequest -Uri $Url -Headers @{ 'User-Agent' = 'PowerShell' } -OutFile $Destination -UseBasicParsing
}

function Install-MsiSilently {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MsiPath
    )

    if (-not (Test-Path $MsiPath)) {
        throw "MSI installer not found: $MsiPath"
    }

    Write-Host "Installing PowerShell from MSI: $MsiPath"
    $arguments = "/i", "$MsiPath", "/qn", "/norestart"
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -Passthru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        throw "PowerShell installer exited with code $($process.ExitCode)."
    }
}

$release = Get-LatestPowerShellRelease
if (-not $release) {
    throw 'Unable to retrieve the latest PowerShell release information.'
}

$architecture = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }
$asset = Get-MsiAssetForRelease -Release $release -Architecture $architecture

if (-not $asset) {
    throw "Unable to find a PowerShell MSI asset for architecture '$architecture' in release $($release.tag_name)."
}

$destinationPath = Join-Path -Path $env:TEMP -ChildPath $asset.name
Download-Asset -Url $asset.browser_download_url -Destination $destinationPath
Install-MsiSilently -MsiPath $destinationPath

Write-Host "PowerShell $($release.tag_name) installation completed successfully."
