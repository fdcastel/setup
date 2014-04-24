
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

# Stop on any error
$ErrorActionPreference = 'Stop'

# Elevate (if needed)
Requires-Elevation

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI' -Name 'LogPixels' -Value 96

Write-Output 'Logging off in 5 seconds. Press Ctrl-C to abort...'
Start-Sleep 10
logoff.exe