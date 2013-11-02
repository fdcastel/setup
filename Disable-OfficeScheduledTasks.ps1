# Disable all Microsoft Office scheduled tasks 
#   Must run with elevated privileges

SCHTASKS.EXE /QUERY /FO CSV | ConvertFrom-CSV | Where-Object {$_.TaskName -match 'office'} | Foreach  {SCHTASKS.EXE /CHANGE /TN $_.taskname /DISABLE}