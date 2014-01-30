######
#
# Cleanup-Disks.ps1
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

# Must run with elevated privileges
Requires-Elevation

# Add StateFlags1337 for each handler (http://msdn.microsoft.com/en-us/library/bb776782(v=vs.85).aspx)
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" | ForEach-Object {
    Set-ItemProperty $_.PSPath -Name StateFlags1337 -Value 2 -Type DWord -Force | Out-Null
}

# Run Disk Cleanup
CLEANMGR.EXE /SAGERUN:1337
