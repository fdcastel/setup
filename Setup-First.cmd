@ECHO OFF
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command set-executionpolicy remotesigned -scope currentuser
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -Command "& '%~dpn0.ps1' %*"
